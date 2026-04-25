--David Sebastian Lemus Nitsch
--Índices definidos explícitamente (CREATE INDEX) en al menos 2 columnas justificadas 

-- ÍNDICE 1: Para búsqueda de productos por nombre
-- Justificación: La tienda frecuentemente busca productos por su nombre
-- para mostrar en el catálogo, para ventas o para búsquedas en la UI.
-- Un índice aquí acelera las búsquedas con LIKE o =.
CREATE INDEX idx_producto_nombre ON producto(nombre);

-- ÍNDICE 2: Para búsqueda de clientes por email
-- Justificación: El email se usa para autenticación (si implementás login)
-- y para buscar clientes rápidamente en el sistema de ventas.
CREATE INDEX idx_cliente_email ON cliente(email);

-- ÍNDICE 3: Para ordenar ventas por fecha
-- Justificación: Los reportes de ventas diarias, mensuales o por rango
-- de fechas son muy comunes en cualquier negocio.
CREATE INDEX idx_venta_fecha ON venta(fecha);

-- ÍNDICE 4: Para buscar detalles de venta por producto
-- Justificación: Para consultar qué productos son los más vendidos
-- (popularidad) se necesita agrupar por id_producto en detalle_venta.
CREATE INDEX idx_detalle_producto ON detalle_venta(id_producto);

-- ÍNDICE 5: Para buscar historial de stock por producto
-- Justificación: Para auditoría y reportes de movimientos de inventario
-- de un producto específico.
CREATE INDEX idx_historial_producto ON historial_stock(id_producto);