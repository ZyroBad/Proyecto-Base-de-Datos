const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const dotenv = require('dotenv');
const session = require('express-session');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.set('trust proxy', 1);
app.use(
    session({
        secret: process.env.SESSION_SECRET || 'dev_session_secret',
        resave: false,
        saveUninitialized: false,
        cookie: {
            httpOnly: true,
            sameSite: 'lax',
        },
    })
);

const pool = new Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
});

function requireAuth(req, res, next) {
    if (req.session && req.session.user) return next();
    return res.status(401).json({ error: 'No autenticado' });
}

function requireRoles(rolesPermitidos) {
    return (req, res, next) => {
        const rol = req.session?.user?.rol;
        if (!rol) return res.status(401).json({ error: 'No autenticado' });
        if (rolesPermitidos.includes(rol)) return next();
        return res.status(403).json({ error: 'No autorizado' });
    };
}

function appRoleToDbRole(appRol) {
    const map = {
        admin: 'rol_admin',
        gerente: 'rol_gerente',
        ventas: 'rol_ventas',
        inventario: 'rol_inventario',
        auditor: 'rol_auditor',
    };
    return map[appRol] || null;
}

async function queryAsRole(req, text, params) {
    const dbRole = appRoleToDbRole(req.session?.user?.rol);
    if (!dbRole) {
        const err = new Error('Rol inválido');
        err.statusCode = 400;
        throw err;
    }
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(`SET LOCAL ROLE ${dbRole}`);
        const result = await client.query(text, params);
        await client.query('COMMIT');
        return result;
    } catch (err) {
        try {
            await client.query('ROLLBACK');
        } catch (_) {
            // ignore
        }
        throw err;
    } finally {
        client.release();
    }
}

// HEALTH CHECK
app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

// AUTH (login/logout con sesión)
app.post('/api/auth/login', async(req, res) => {
    const { username, password } = req.body || {};
    if (!username || !password) return res.status(400).json({ error: 'username y password requeridos' });
    try {
        const result = await pool.query(
            `
            SELECT id_usuario, username, rol
            FROM app_usuario
            WHERE activo = TRUE
              AND username = $1
              AND password_hash = crypt($2, password_hash)
            `,
            [username, password]
        );
        if (result.rows.length === 0) return res.status(401).json({ error: 'Credenciales inválidas' });
        const user = result.rows[0];
        req.session.user = { id_usuario: user.id_usuario, username: user.username, rol: user.rol };
        return res.json({ ok: true, user: req.session.user });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
});

app.post('/api/auth/logout', (req, res) => {
    if (!req.session) return res.json({ ok: true });
    req.session.destroy((_) => res.json({ ok: true }));
});

app.get('/api/auth/me', (req, res) => {
    res.json({ user: req.session?.user || null });
});

// Proteger todo /api (excepto /api/auth/*)
app.use('/api', (req, res, next) => {
    if (req.path.startsWith('/auth/')) return next();
    return requireAuth(req, res, next);
});

// 1. JOIN: Ventas con cliente y empleado
app.get('/api/ventas', requireRoles(['admin', 'gerente', 'ventas', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT v.id_venta, v.fecha, v.total,
                   c.nombre AS cliente_nombre,
                   c.apellido AS cliente_apellido,
                   e.nombre AS empleado_nombre,
                   e.cargo
            FROM venta v
            JOIN cliente c ON v.id_cliente = c.id_cliente
            JOIN empleado e ON v.id_empleado = e.id_empleado
            ORDER BY v.fecha DESC
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. JOIN: Detalle completo de ventas (productos, cantidades)
app.get('/api/detalle-ventas', requireRoles(['admin', 'gerente', 'ventas', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                v.id_venta,
                v.fecha,
                c.nombre AS cliente,
                p.nombre AS producto,
                dv.cantidad,
                dv.precio_unitario,
                dv.subtotal
            FROM detalle_venta dv
            JOIN venta v ON dv.id_venta = v.id_venta
            JOIN producto p ON dv.id_producto = p.id_producto
            JOIN cliente c ON v.id_cliente = c.id_cliente
            ORDER BY v.fecha DESC
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. JOIN: Productos con categoría y proveedor
app.get('/api/productos-completos', requireRoles(['admin', 'gerente', 'ventas', 'inventario', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                p.id_producto,
                p.nombre AS producto,
                p.precio_base,
                p.stock,
                c.nombre AS categoria,
                prov.nombre AS proveedor
            FROM producto p
            JOIN categoria c ON p.id_categoria = c.id_categoria
            JOIN producto_proveedor pp ON p.id_producto = pp.id_producto
            JOIN proveedor prov ON pp.id_proveedor = prov.id_proveedor
            ORDER BY p.nombre
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 4. Subquery: Clientes que gastaron más del promedio
app.get('/api/clientes-top', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                c.id_cliente,
                c.nombre,
                c.apellido,
                SUM(v.total) AS total_gastado
            FROM cliente c
            JOIN venta v ON c.id_cliente = v.id_cliente
            GROUP BY c.id_cliente, c.nombre, c.apellido
            HAVING SUM(v.total) > (
                SELECT AVG(total_gastado)
                FROM (
                    SELECT SUM(v2.total) AS total_gastado
                    FROM venta v2
                    GROUP BY v2.id_cliente
                ) AS promedios
            )
            ORDER BY total_gastado DESC
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 5. Subquery: Productos nunca vendidos
app.get('/api/productos-no-vendidos', requireRoles(['admin', 'gerente', 'inventario', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                id_producto,
                nombre,
                precio_base,
                stock
            FROM producto p
            WHERE NOT EXISTS (
                SELECT 1
                FROM detalle_venta dv
                WHERE dv.id_producto = p.id_producto
            )
            ORDER BY nombre
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 6. GROUP BY + HAVING: Ventas por cliente (más de 2 compras)
app.get('/api/estadisticas-clientes', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                c.id_cliente,
                c.nombre,
                c.apellido,
                COUNT(v.id_venta) AS cantidad_compras,
                SUM(v.total) AS total_gastado,
                ROUND(AVG(v.total), 2) AS promedio_compra
            FROM cliente c
            JOIN venta v ON c.id_cliente = v.id_cliente
            GROUP BY c.id_cliente, c.nombre, c.apellido
            HAVING COUNT(v.id_venta) > 2
            ORDER BY total_gastado DESC
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 7. GROUP BY: Productos más vendidos (top 10)
app.get('/api/productos-top', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT 
                p.id_producto,
                p.nombre,
                SUM(dv.cantidad) AS total_vendido,
                COUNT(DISTINCT dv.id_venta) AS veces_vendido,
                p.stock AS stock_actual
            FROM producto p
            JOIN detalle_venta dv ON p.id_producto = dv.id_producto
            GROUP BY p.id_producto, p.nombre, p.stock
            ORDER BY total_vendido DESC
            LIMIT 10
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 8. CTE: Ventas mensuales con acumulado
app.get('/api/ventas-mensuales', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            WITH ventas_por_mes AS (
                SELECT 
                    EXTRACT(YEAR FROM fecha) AS anio,
                    EXTRACT(MONTH FROM fecha) AS mes,
                    SUM(total) AS ventas_mes
                FROM venta
                GROUP BY EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)
                ORDER BY anio, mes
            )
            SELECT 
                anio,
                mes,
                ventas_mes,
                SUM(ventas_mes) OVER (ORDER BY anio, mes) AS ventas_acumuladas
            FROM ventas_por_mes
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 9. VIEW: Ventas por categoría
app.get('/api/ventas-por-categoria', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `SELECT * FROM vista_ventas_por_categoria`);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 10. TRANSACCIÓN: Registrar venta con ROLLBACK
app.post('/api/registrar-venta', requireRoles(['admin', 'gerente', 'ventas']), async(req, res) => {
    const { id_cliente, id_empleado, productos } = req.body;
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        const dbRole = appRoleToDbRole(req.session?.user?.rol);
        await client.query(`SET LOCAL ROLE ${dbRole}`);

        const ventaResult = await client.query(
            `INSERT INTO venta (fecha, total, id_cliente, id_empleado)
             VALUES (CURRENT_DATE, 0, $1, $2) RETURNING id_venta`, [id_cliente, id_empleado]
        );
        const id_venta = ventaResult.rows[0].id_venta;
        let total = 0;

        for (const prod of productos) {
            const prodResult = await client.query(
                `SELECT precio_base, stock FROM producto WHERE id_producto = $1 FOR UPDATE`, [prod.id_producto]
            );

            if (prodResult.rows.length === 0) {
                throw new Error(`Producto ${prod.id_producto} no existe`);
            }

            const { precio_base, stock } = prodResult.rows[0];
            if (stock < prod.cantidad) {
                throw new Error(`Stock insuficiente para producto ${prod.id_producto}`);
            }

            const subtotal = precio_base * prod.cantidad;
            total += subtotal;

            await client.query(
                `INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal)
                 VALUES ($1, $2, $3, $4, $5)`, [id_venta, prod.id_producto, prod.cantidad, precio_base, subtotal]
            );

            await client.query(
                `UPDATE producto SET stock = stock - $1 WHERE id_producto = $2`, [prod.cantidad, prod.id_producto]
            );

            await client.query(
                `INSERT INTO historial_stock (tipo_movimiento, cantidad, descripcion, id_producto)
                 VALUES ('salida', $1, 'Venta #' || $2, $3)`, [prod.cantidad, id_venta, prod.id_producto]
            );
        }

        await client.query(`UPDATE venta SET total = $1 WHERE id_venta = $2`, [total, id_venta]);
        await client.query('COMMIT');
        res.json({ success: true, id_venta, total });
    } catch (err) {
        await client.query('ROLLBACK');
        res.status(500).json({ success: false, error: err.message });
    } finally {
        client.release();
    }
});

// ENDPOINTS ADICIONALES
// Listar clientes para el formulario
app.get('/api/clientes', requireRoles(['admin', 'gerente', 'ventas']), async(req, res) => {
    try {
        const result = await queryAsRole(req, 'SELECT id_cliente, nombre, apellido FROM cliente ORDER BY nombre');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Listar empleados para el formulario
app.get('/api/empleados', requireRoles(['admin', 'gerente', 'ventas']), async(req, res) => {
    try {
        const result = await queryAsRole(req, 'SELECT id_empleado, nombre, apellido FROM empleado ORDER BY nombre');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Listar productos para el formulario (solo con stock disponible)
app.get('/api/productos-lista', requireRoles(['admin', 'gerente', 'ventas', 'inventario']), async(req, res) => {
    try {
        const result = await queryAsRole(req, `
            SELECT id_producto, nombre, precio_base, stock 
            FROM producto 
            WHERE stock > 0 
            ORDER BY nombre
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Stats para las tarjetas del dashboard
app.get('/api/categorias-stats', requireRoles(['admin', 'gerente', 'auditor']), async(req, res) => {
    try {
        const result = await queryAsRole(req, 'SELECT COUNT(*) as total FROM categoria');
        res.json([{ total: parseInt(result.rows[0].total) }]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// INICIAR SERVIDOR
const PORT = process.env.BACKEND_PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`API de ventas: http://localhost:${PORT}/api/ventas`);
});
