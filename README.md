# NEKI - Sistema de Gestión de Ventas

**Proyecto 3 - Base de Datos**  
Extensión del Proyecto 2 para incorporar **seguridad y roles en PostgreSQL** y **autenticación con sesión**.

## Requisitos previos

- Docker + Docker Compose

## Levantar el proyecto

1) Crear `.env`:

```bash
cp .env.example .env
```

2) Construir y levantar servicios:

```bash
docker compose up --build
```

## Accesos

- Frontend: `http://localhost:8080`
- Backend API: `http://localhost:3000`

## Credenciales (requeridas para calificación)

| Servicio | Usuario | Contraseña |
|---|---|---|
| Base de datos | `proy3` | `secret` |

## I. Seguridad y roles

### Roles en PostgreSQL (DBMS)

Los roles se crean en `backend/db/init.sql` con `CREATE ROLE`:

- `rol_admin`: acceso total (CRUD sobre todas las tablas).
- `rol_gerente`: lectura total + CRUD en `cliente` y `empleado`.
- `rol_ventas`: consultar catálogos (`cliente`, `empleado`, `producto`, `categoria`) y registrar ventas (`venta`, `detalle_venta`), actualiza `producto.stock` y registra `historial_stock`.
- `rol_inventario`: CRUD de `producto`, `categoria`, `proveedor`, `producto_proveedor` + registro de `historial_stock`.
- `rol_auditor`: solo lectura (reportes/consultas).

El backend usa un único usuario de conexión (`proy3`) y aplica **`SET LOCAL ROLE`** por request según el rol del usuario autenticado, para que la base de datos haga cumplir permisos.

### Usuarios de prueba (uno por rol)

Incluidos en `backend/db/init.sql` (tabla `app_usuario`), para login con sesión:

| Rol app | Usuario | Contraseña |
|---|---|---|
| `admin` | `admin` | `admin123` |
| `gerente` | `gerente` | `gerente123` |
| `ventas` | `ventas` | `ventas123` |
| `inventario` | `inventario` | `inventario123` |
| `auditor` | `auditor` | `auditor123` |

### Rutas/UI protegidas

- Backend: endpoints `/api/*` requieren sesión (excepto `/api/auth/*`).
- Frontend: el dashboard muestra/oculta pestañas según el rol autenticado.

## Endpoints de autenticación

- `POST /api/auth/login` `{ "username": "...", "password": "..." }`
- `POST /api/auth/logout`
- `GET /api/auth/me`

## Endpoints del Proyecto 2 (protegidos por rol)

- `GET /api/ventas`
- `GET /api/detalle-ventas`
- `GET /api/productos-completos`
- `GET /api/clientes-top`
- `GET /api/productos-no-vendidos`
- `GET /api/estadisticas-clientes`
- `GET /api/productos-top`
- `GET /api/ventas-mensuales`
- `GET /api/ventas-por-categoria`
- `POST /api/registrar-venta`
- `GET /api/clientes`
- `GET /api/empleados`
- `GET /api/productos-lista`
- `GET /api/categorias-stats`

