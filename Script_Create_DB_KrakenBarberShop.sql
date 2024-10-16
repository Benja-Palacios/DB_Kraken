-- Base de datos KraenBarberShop
CREATE DATABASE KraenBarberShop;
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

-- Tabla de Customer (Informacion personal de los clientes/usuarios)
CREATE TABLE BSK_Cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidoPaterno VARCHAR(50) NOT NULL,
    apellidoMaterno VARCHAR(50),
    rolId INT NOT NULL,
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


INSERT INTO BSK_Rol (nombre)
VALUES 
('Administrador'),
('Empleado'),
('Cliente');

-- ############################
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <6 de octubre del 2024>
-- Description: <Crear tabla Tienda y DireccionTienda>
-- ############################

-- Tabla de Tienda (Información de las barberías)
CREATE TABLE BSK_Tienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    imagen VARCHAR(255) NOT NULL, 
    clienteId INT NOT NULL, 
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(), 
    FOREIGN KEY (clienteId) REFERENCES BSK_Cliente(id) 
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
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(), 
    FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id)
);

-- Tabla de Estilos (Estilos de las barberías)
CREATE TABLE BSK_EstilosTienda (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,   
    imagen VARCHAR(255) NOT NULL, 
	descripcion VARCHAR(255), 
    tiendaId INT NOT NULL, 
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(), 
    FOREIGN KEY (tiendaId) REFERENCES BSK_Tienda(id)
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