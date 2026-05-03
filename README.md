# NEKI - Sistema de Gestión de Ventas

**Proyecto 2 - Base de Datos**
**Nombre:** David Sebastián Lemus Nitsch
**Carnet:** 241155


## Requisitos Previos

Antes de empezar, asegurate de tener instalado:
* Docker y Docker Compose
* Git (opcional, para clonar el repositorio)


## Instalación y Ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/ZyroBad/Proyecto-Base-de-Datos.git
cd Proyecto-Base-de-Datos
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

### 3. Levantar los servicios

```bash
docker compose up --build
```

### 4. Acceder a la aplicación

* **Frontend:** http://localhost:8080
* **Backend API:** http://localhost:3000



## Credenciales

| Servicio      | Usuario | Contraseña |
| ------------- | ------- | ---------- |
| Base de datos | proy2   | secret     |

---

## Endpoints de la API

| Método | Endpoint                     | Descripción                          |
| ------ | ---------------------------- | ------------------------------------ |
| GET    | `/health`                    | Verificar estado del servidor        |
| GET    | `/api/ventas`                | Lista todas las ventas (JOIN)        |
| GET    | `/api/detalle-ventas`        | Detalle completo de ventas           |
| GET    | `/api/productos-completos`   | Productos con categoría y proveedor  |
| GET    | `/api/clientes-top`          | Clientes que gastaron sobre promedio |
| GET    | `/api/productos-no-vendidos` | Productos nunca vendidos             |
| GET    | `/api/estadisticas-clientes` | Estadísticas por cliente             |
| GET    | `/api/productos-top`         | Top 10 productos más vendidos        |
| GET    | `/api/ventas-mensuales`      | Ventas mensuales con acumulado (CTE) |
| GET    | `/api/ventas-por-categoria`  | Ventas por categoría (VIEW)          |
| POST   | `/api/registrar-venta`       | Registrar nueva venta (transacción)  |
| GET    | `/api/clientes`              | Lista de clientes                    |
| GET    | `/api/empleados`             | Lista de empleados                   |
| GET    | `/api/productos-lista`       | Productos disponibles                |
| GET    | `/api/categorias-stats`      | Estadísticas de categorías           |

---

## Estructura del Proyecto

```
Proyecto-Base-de-Datos/
├── docker-compose.yml
├── .env
├── .env.example
├── README.md
├── ddl_parte1_proyecto.sql
├── datos_prueba_proyecto.sql
├── indices_definidos.sql
├── Normalización_Proyecto_Base.xlsx
├── Proyecto 2 Base de Datos.pdf
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── db/
│       └── init.sql
└── frontend/
    ├── Dockerfile
    └── html/
        └── index.html
```


## Tecnologías Utilizadas

* PostgreSQL 15 (Base de datos)
* Node.js 18 + Express (Backend)
* HTML5 + CSS3 + JavaScript (Frontend)
* Docker & Docker Compose (Contenedores)

---

## Características del Proyecto

* Base de datos normalizada hasta **3FN**
* Uso de **JOINs, subqueries, CTE y VIEW**
* Manejo de transacciones (**BEGIN / COMMIT / ROLLBACK**)
* CRUD completo de ventas
* Exportación de reportes a CSV
* Dashboard con estadísticas en tiempo real
* Interfaz moderna y responsive


