-- Base de datos KraenBarberShop
CREATE DATABASE KraenBarberShop;
GO
USE KraenBarberShop;
GO

-- ############################
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <28 de septiembre del 2024>
-- Description: <Crear Base de datos>
-- ############################

-- Tabla de Roles (Empleado, Administrador, Cliente)
CREATE TABLE BSK_Rol (
    id INT IDENTITY(1,1) PRIMARY KEY,  
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Tabla de Tienda (Información de las barberías)
CREATE TABLE BSK_Tienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    imagen VARCHAR(255) NOT NULL, 
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    horarioApertura TIME NOT NULL,
    horarioCierre TIME NOT NULL,
    clienteId INT NOT NULL
);

-- Tabla de DireccionTienda (Direcciones de las barberías)
CREATE TABLE BSK_DireccionTienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    CP VARCHAR(5) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,   
    tipoVivienda VARCHAR(50) NOT NULL,
    municipio VARCHAR(50) NOT NULL,       
    estado VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    noExterior VARCHAR(10) NOT NULL,
    telefono VARCHAR(10) NOT NULL, 
    referencia VARCHAR(255),
    tiendaId INT NOT NULL,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE()
);

-- Tabla de Cliente (Informacion personal de los clientes/usuarios)
CREATE TABLE BSK_Cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidoPaterno VARCHAR(50) NOT NULL,
    apellidoMaterno VARCHAR(50),
    rolId INT NOT NULL,
    direccionId INT,
    tiendaId INT,
    estado VARCHAR(10) NOT NULL DEFAULT 'Activo',
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(), 
    FOREIGN KEY (rolId) REFERENCES BSK_Rol(id)
);

-- Tabla de Autenticacion (solo autenticacion)
CREATE TABLE BSK_Autenticacion (
    id INT IDENTITY(1,1) PRIMARY KEY,       
    correo VARCHAR(100) NOT NULL UNIQUE,    
    contrasena VARCHAR(255) NOT NULL,      
    clienteId INT NOT NULL,               
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id)
);

CREATE UNIQUE INDEX IX_BSK_Autenticacion_Correo ON BSK_Autenticacion(correo);

-- Insertar roles
INSERT INTO BSK_Rol (nombre)
VALUES 
('Administrador'),
('Empleado'),
('Cliente');

-- Tabla de Estilos (Estilos de las barberías)
CREATE TABLE BSK_EstilosTienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,   
    imagen VARCHAR(255) NOT NULL, 
	descripcion VARCHAR(255), 
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    tiendaId INT  NOT NULL
);

-- Tabla Calificaciones de las Tiendas
CREATE TABLE BSK_CalificacionTienda (
    id INT PRIMARY KEY IDENTITY(1,1),
    tiendaId INT NOT NULL,
    clienteId INT NOT NULL,
    calificacion INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    fechaCalificacion DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id),
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id)
);

-- Tabla de Citas (Citas agendadas para estilos de las barberías)
CREATE TABLE BSK_Citas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    clienteId INT NOT NULL, 
    tiendaId INT NOT NULL, 
	direccionId INT NOT NULL,
    empleadoId INT NOT NULL,
    fechaCita VARCHAR(20) NOT NULL,
    horaCita TIME NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente', -- Estado de la cita (Pendiente, Confirmada, Cancelada)
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(), 
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id),
    FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id),
    FOREIGN KEY (direccionId) REFERENCES BSK_DireccionTienda(id),
    FOREIGN KEY (empleadoId) REFERENCES BSK_Cliente(id)
);

-- Tabla de Favoritos (Tiendas favoritas de los clientes)
CREATE TABLE BSK_FavoritosTienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    clienteId INT NOT NULL,
    tiendaId INT NOT NULL,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id),
    FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id),
    CONSTRAINT UC_BSK_FavoritosTienda UNIQUE (clienteId, tiendaId) -- Evita duplicados en favoritos
);

-- Tabla para Tokens de Recuperación de Contraseña
CREATE TABLE BSK_PasswordResetTokens (
    id INT IDENTITY(1,1) PRIMARY KEY,
    clienteId INT NOT NULL,                    -- Referencia al cliente que solicitó el restablecimiento
    token UNIQUEIDENTIFIER NOT NULL,           -- Token único generado para el restablecimiento
    expiration DATETIME NOT NULL,              -- Fecha de expiración del token
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id) 
);

-- Crear índices para mejorar el rendimiento en consultas
CREATE INDEX IX_BSK_Citas_FechaCita ON BSK_Citas(fechaCita);
CREATE INDEX IX_BSK_Citas_ClienteId ON BSK_Citas(clienteId);
CREATE INDEX IX_BSK_Citas_TiendaId ON BSK_Citas(tiendaId);
CREATE INDEX IX_BSK_FavoritosTienda_ClienteId ON BSK_FavoritosTienda(clienteId);
CREATE INDEX IX_BSK_FavoritosTienda_TiendaId ON BSK_FavoritosTienda(tiendaId);
CREATE INDEX IX_BSK_PasswordResetTokens_Token ON BSK_PasswordResetTokens(token);

-- ############################
-- Añadir claves foráneas tras la creación de las tablas
-- ############################

-- Añadir claves foráneas a BSK_Cliente
ALTER TABLE BSK_Cliente
ADD CONSTRAINT FK_BSK_Cliente_Tienda FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id);

ALTER TABLE BSK_Cliente
ADD CONSTRAINT FK_BSK_Cliente_Direccion FOREIGN KEY (direccionId) REFERENCES BSK_DireccionTienda(id);

-- Añadir clave foránea a BSK_Tienda
ALTER TABLE BSK_Tienda
ADD CONSTRAINT FK_BSK_Tienda_Cliente FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id);

-- Añadir clave foránea a BSK_DireccionTienda
ALTER TABLE BSK_DireccionTienda
ADD CONSTRAINT FK_BSK_DireccionTienda_Tienda FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id);

-- Añadir clave foránea a BSK_EstilosTienda
ALTER TABLE BSK_EstilosTienda
ADD CONSTRAINT FK_BSK_EstilosTienda_Tienda FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id);

-- Añadir restricción única en la columna token para evitar duplicados
ALTER TABLE BSK_PasswordResetTokens
ADD CONSTRAINT UQ_BSK_PasswordResetTokens_Token UNIQUE (token);
