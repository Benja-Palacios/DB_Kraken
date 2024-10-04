-- Base de datos KraenBarberShop
CREATE DATABASE KraenBarberShop;
USE KraenBarberShop;
GO

-- ############################
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 de septiembre del 2024>
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
