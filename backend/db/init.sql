-- PROYECTO 2 
-- DDL COMPLETO
-- David Sebastian Lemus Nitsch 241155

-- TABLA CATEGORIA
CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- TABLA PROVEEDOR
CREATE TABLE proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    direccion TEXT
);

-- TABLA PRODUCTO
CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10,2) NOT NULL CHECK (precio_base >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- TABLA CLIENTE
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

-- TABLA EMPLEADO
CREATE TABLE empleado (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cargo VARCHAR(50) NOT NULL
);

-- TABLA VENTA
CREATE TABLE venta (
    id_venta SERIAL PRIMARY KEY,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    total DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
);

-- TABLA DETALLE_VENTA
CREATE TABLE detalle_venta (
    id_detalle SERIAL PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    FOREIGN KEY (id_venta) REFERENCES venta(id_venta) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

-- TABLA PRODUCTO_PROVEEDOR (relaciÃ³n N:N entre producto y proveedor)
CREATE TABLE producto_proveedor (
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL CHECK (precio_compra >= 0),
    fecha_compra DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_producto, id_proveedor, fecha_compra),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- TABLA HISTORIAL_STOCK (auditorÃ­a de cambios en el stock)
CREATE TABLE historial_stock (
    id_historial SERIAL PRIMARY KEY,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada', 'salida', 'ajuste')),
    cantidad INT NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);
 -- DATOS DE PRUEBA 
 -- David Sebastian Lemus Nitsch 


-- CATEGORIA (5 registros)
INSERT INTO categoria (nombre, descripcion) VALUES
('ElectrÃ³nica', 'Productos electrÃ³nicos: computadoras, tablets, audÃ­fonos'),
('Ropa', 'Prendas de vestir para hombre, mujer y niÃ±os'),
('Hogar', 'ArtÃ­culos para el hogar y decoraciÃ³n'),
('Deportes', 'Equipo deportivo y accesorios'),
('Libros', 'Libros y material educativo');

-- PROVEEDOR (5 registros)
INSERT INTO proveedor (nombre, telefono, email, direccion) VALUES
('Insumos S.A.', '50212345678', 'ventas@insumos.com', 'Zona 10, Guatemala'),
('TecnoStore', '50287654321', 'info@tecnostore.com', 'Zona 14, Guatemala'),
('Moda Express', '50255667788', 'contacto@modaexpress.com', 'Mixco, Guatemala'),
('Hogar Ideal', '50244332211', 'hogar@ideal.com', 'Villa Nueva, Guatemala'),
('Distribuidora Deportiva', '50299887766', 'deportes@distribuidora.com', 'Zona 1, Guatemala');

-- PRODUCTO (25 registros)
INSERT INTO producto (nombre, descripcion, precio_base, stock, id_categoria) VALUES
('Laptop Lenovo', 'Laptop 16GB RAM, 512GB SSD', 4500.00, 10, 1),
('Mouse InalÃ¡mbrico', 'Mouse ergonÃ³mico', 150.00, 50, 1),
('Teclado MecÃ¡nico', 'Teclado RGB mecÃ¡nico', 350.00, 30, 1),
('AudÃ­fonos Bluetooth', 'AudÃ­fonos con cancelaciÃ³n de ruido', 250.00, 25, 1),
('Monitor 24"', 'Monitor Full HD 75Hz', 1200.00, 15, 1),
('Camiseta Deportiva', 'Camiseta talla M', 80.00, 100, 2),
('PantalÃ³n Jeans', 'PantalÃ³n mezclilla azul', 200.00, 60, 2),
('Chaqueta Impermeable', 'Chaqueta para lluvia', 350.00, 30, 2),
('Gorra Deportiva', 'Gorra ajustable', 50.00, 80, 2),
('Zapatos Casuales', 'Zapatos de tela', 180.00, 40, 2),
('LÃ¡mpara LED', 'LÃ¡mpara de escritorio', 120.00, 45, 3),
('Mesa Plegable', 'Mesa para exteriores', 450.00, 20, 3),
('Silla ErgonÃ³mica', 'Silla para oficina', 800.00, 12, 3),
('Almohada Memory', 'Almohada ortopÃ©dica', 150.00, 35, 3),
('Juego de SÃ¡banas', 'SÃ¡banas 2 plazas', 180.00, 28, 3),
('Pelota de FÃºtbol', 'Pelota oficial talla 5', 120.00, 55, 4),
('Raqueta Tenis', 'Raqueta profesional', 350.00, 15, 4),
('Guantes Boxeo', 'Guantes 12oz', 250.00, 20, 4),
('Rodilleras', 'ProtecciÃ³n para rodillas', 80.00, 40, 4),
('Cuerda Saltar', 'Cuerda ajustable', 45.00, 60, 4),
('ProgramaciÃ³n en Python', 'Libro para principiantes', 180.00, 25, 5),
('SQL Avanzado', 'Libro de bases de datos', 220.00, 20, 5),
('JavaScript Moderno', 'Libro ES6+', 190.00, 18, 5),
('Docker PrÃ¡ctico', 'GuÃ­a de contenedores', 210.00, 15, 5),
('Inteligencia Artificial', 'Fundamentos de IA', 250.00, 12, 5);

-- PRODUCTO_PROVEEDOR (relaciones producto-proveedor)
INSERT INTO producto_proveedor (id_producto, id_proveedor, precio_compra, fecha_compra) VALUES
(1, 2, 3800.00, '2026-01-15'),
(2, 1, 120.00, '2026-01-10'),
(3, 1, 280.00, '2026-01-10'),
(4, 2, 200.00, '2026-01-15'),
(5, 2, 1000.00, '2026-01-15'),
(6, 3, 60.00, '2026-02-01'),
(7, 3, 150.00, '2026-02-01'),
(8, 3, 280.00, '2026-02-01'),
(9, 3, 35.00, '2026-02-01'),
(10, 3, 140.00, '2026-02-01'),
(11, 4, 90.00, '2026-02-15'),
(12, 4, 350.00, '2026-02-15'),
(13, 4, 600.00, '2026-02-15'),
(14, 4, 110.00, '2026-02-15'),
(15, 4, 130.00, '2026-02-15'),
(16, 5, 90.00, '2026-03-01'),
(17, 5, 280.00, '2026-03-01'),
(18, 5, 200.00, '2026-03-01'),
(19, 5, 60.00, '2026-03-01'),
(20, 5, 30.00, '2026-03-01'),
(21, 1, 140.00, '2026-03-10'),
(22, 1, 170.00, '2026-03-10'),
(23, 1, 150.00, '2026-03-10'),
(24, 1, 160.00, '2026-03-10'),
(25, 1, 190.00, '2026-03-10');

-- CLIENTE (25 registros)
INSERT INTO cliente (nombre, apellido, email, telefono, direccion) VALUES
('Carlos', 'PÃ©rez', 'carlos.perez@mail.com', '50211112222', 'Zona 1, Guatemala'),
('Ana', 'GarcÃ­a', 'ana.garcia@mail.com', '50222223333', 'Zona 2, Guatemala'),
('Luis', 'MartÃ­nez', 'luis.martinez@mail.com', '50233334444', 'Zona 3, Guatemala'),
('MarÃ­a', 'LÃ³pez', 'maria.lopez@mail.com', '50244445555', 'Zona 4, Guatemala'),
('JosÃ©', 'RodrÃ­guez', 'jose.rodriguez@mail.com', '50255556666', 'Zona 5, Guatemala'),
('Laura', 'FernÃ¡ndez', 'laura.fernandez@mail.com', '50266667777', 'Zona 6, Guatemala'),
('Pedro', 'GonzÃ¡lez', 'pedro.gonzalez@mail.com', '50277778888', 'Zona 7, Guatemala'),
('SofÃ­a', 'DÃ­az', 'sofia.diaz@mail.com', '50288889999', 'Zona 8, Guatemala'),
('AndrÃ©s', 'SÃ¡nchez', 'andres.sanchez@mail.com', '50299990000', 'Zona 9, Guatemala'),
('Valentina', 'RamÃ­rez', 'valentina.ramirez@mail.com', '50210101010', 'Zona 10, Guatemala'),
('Diego', 'Torres', 'diego.torres@mail.com', '50220202020', 'Mixco, Guatemala'),
('Camila', 'Flores', 'camila.flores@mail.com', '50230303030', 'Villa Nueva, Guatemala'),
('Juan', 'Morales', 'juan.morales@mail.com', '50240404040', 'Santa Catarina, Guatemala'),
('Paula', 'Castro', 'paula.castro@mail.com', '50250505050', 'San Miguel, Guatemala'),
('Ricardo', 'Ortega', 'ricardo.ortega@mail.com', '50260606060', 'Zona 11, Guatemala'),
('Daniela', 'Mendoza', 'daniela.mendoza@mail.com', '50270707070', 'Zona 12, Guatemala'),
('Fernando', 'Rojas', 'fernando.rojas@mail.com', '50280808080', 'Zona 13, Guatemala'),
('Natalia', 'Silva', 'natalia.silva@mail.com', '50290909090', 'Zona 14, Guatemala'),
('Javier', 'Herrera', 'javier.herrera@mail.com', '50201020304', 'Zona 15, Guatemala'),
('Gabriela', 'Medina', 'gabriela.medina@mail.com', '50202030405', 'Zona 16, Guatemala'),
('Manuel', 'Vargas', 'manuel.vargas@mail.com', '50203040506', 'Zona 17, Guatemala'),
('Isabella', 'Cruz', 'isabella.cruz@mail.com', '50204050607', 'Zona 18, Guatemala'),
('SebastiÃ¡n', 'GuzmÃ¡n', 'sebastian.guzman@mail.com', '50205060708', 'Zona 19, Guatemala'),
('Valeria', 'Reyes', 'valeria.reyes@mail.com', '50206070809', 'Zona 20, Guatemala'),
('Alejandro', 'PeÃ±a', 'alejandro.pena@mail.com', '50207080900', 'San JosÃ©, Guatemala');

-- EMPLEADO (5 registros)
INSERT INTO empleado (nombre, apellido, email, cargo) VALUES
('Juan', 'PÃ©rez', 'jperez@tienda.com', 'Vendedor'),
('MarÃ­a', 'GarcÃ­a', 'mgarcia@tienda.com', 'Cajera'),
('Luis', 'MartÃ­nez', 'lmartinez@tienda.com', 'Supervisor'),
('Ana', 'RodrÃ­guez', 'arodriguez@tienda.com', 'Vendedora'),
('Carlos', 'LÃ³pez', 'clopez@tienda.com', 'Gerente');

-- VENTA (25 registros)
INSERT INTO venta (fecha, total, id_cliente, id_empleado) VALUES
('2026-03-01', 500.00, 1, 1),
('2026-03-03', 350.00, 2, 2),
('2026-03-05', 1200.00, 3, 1),
('2026-03-07', 80.00, 4, 3),
('2026-03-09', 450.00, 5, 2),
('2026-03-11', 680.00, 6, 1),
('2026-03-13', 230.00, 7, 4),
('2026-03-15', 890.00, 8, 2),
('2026-03-17', 150.00, 9, 1),
('2026-03-19', 2100.00, 10, 3),
('2026-03-21', 320.00, 11, 1),
('2026-03-22', 540.00, 12, 2),
('2026-03-23', 120.00, 13, 4),
('2026-03-24', 670.00, 14, 1),
('2026-03-25', 430.00, 15, 2),
('2026-03-26', 950.00, 16, 3),
('2026-03-27', 280.00, 17, 1),
('2026-03-27', 760.00, 18, 2),
('2026-03-28', 310.00, 19, 4),
('2026-03-28', 1120.00, 20, 1),
('2026-03-29', 200.00, 21, 2),
('2026-03-29', 540.00, 22, 3),
('2026-03-30', 380.00, 23, 1),
('2026-03-30', 690.00, 24, 2),
('2026-03-31', 450.00, 25, 4);

-- DETALLE_VENTA (mÃ¡s de 25 registros)
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 4500.00, 4500.00),
(1, 2, 2, 150.00, 300.00),
(2, 3, 1, 350.00, 350.00),
(3, 4, 2, 250.00, 500.00),
(3, 5, 1, 1200.00, 1200.00),
(4, 6, 3, 80.00, 240.00),
(5, 7, 2, 200.00, 400.00),
(5, 8, 1, 350.00, 350.00),
(6, 9, 4, 50.00, 200.00),
(6, 10, 2, 180.00, 360.00),
(7, 11, 3, 120.00, 360.00),
(8, 12, 1, 450.00, 450.00),
(8, 13, 1, 800.00, 800.00),
(9, 14, 5, 150.00, 750.00),
(10, 15, 2, 180.00, 360.00),
(10, 16, 3, 120.00, 360.00),
(11, 17, 1, 350.00, 350.00),
(12, 18, 2, 250.00, 500.00),
(12, 19, 3, 80.00, 240.00),
(13, 20, 4, 45.00, 180.00),
(14, 21, 1, 180.00, 180.00),
(15, 22, 2, 220.00, 440.00),
(15, 23, 1, 190.00, 190.00),
(16, 24, 1, 210.00, 210.00),
(16, 25, 2, 250.00, 500.00),
(17, 1, 1, 4500.00, 4500.00),
(18, 2, 1, 150.00, 150.00),
(19, 3, 1, 350.00, 350.00),
(20, 4, 2, 250.00, 500.00);

-- HISTORIAL_STOCK (auditorÃ­a de movimientos de stock)
INSERT INTO historial_stock (tipo_movimiento, cantidad, descripcion, fecha, id_producto) VALUES
('entrada', 10, 'Compra inicial', '2026-01-15 10:00:00', 1),
('entrada', 50, 'Compra inicial', '2026-01-10 11:00:00', 2),
('entrada', 30, 'Compra inicial', '2026-01-10 11:30:00', 3),
('entrada', 25, 'Compra inicial', '2026-01-15 14:00:00', 4),
('entrada', 15, 'Compra inicial', '2026-01-15 14:30:00', 5),
('salida', 1, 'Venta #1', '2026-03-01 15:00:00', 1),
('salida', 2, 'Venta #1', '2026-03-01 15:00:00', 2),
('salida', 1, 'Venta #2', '2026-03-03 10:30:00', 3),
('salida', 2, 'Venta #3', '2026-03-05 11:00:00', 4),
('salida', 1, 'Venta #3', '2026-03-05 11:00:00', 5),
('salida', 3, 'Venta #4', '2026-03-07 14:00:00', 6),
('entrada', 20, 'Reabastecimiento', '2026-03-20 09:00:00', 1),
('ajuste', 5, 'Ajuste por inventario fÃ­sico', '2026-03-25 16:00:00', 2);

CREATE OR REPLACE VIEW vista_ventas_por_categoria AS
SELECT
    c.nombre AS categoria,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.subtotal) AS ingresos_totales
FROM categoria c
JOIN producto p ON c.id_categoria = p.id_categoria
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
JOIN venta v ON dv.id_venta = v.id_venta
GROUP BY c.id_categoria, c.nombre;
