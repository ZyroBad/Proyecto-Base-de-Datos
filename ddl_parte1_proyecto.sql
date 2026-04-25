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

-- TABLA PRODUCTO_PROVEEDOR (relación N:N entre producto y proveedor)
CREATE TABLE producto_proveedor (
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL CHECK (precio_compra >= 0),
    fecha_compra DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_producto, id_proveedor, fecha_compra),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- TABLA HISTORIAL_STOCK (auditoría de cambios en el stock)
CREATE TABLE historial_stock (
    id_historial SERIAL PRIMARY KEY,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada', 'salida', 'ajuste')),
    cantidad INT NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_producto INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);