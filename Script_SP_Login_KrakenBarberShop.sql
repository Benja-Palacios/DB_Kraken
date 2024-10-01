-- STORE PROCEDURE DE INICIO DE SESION
USE [KraenBarberShop]
GO

-- ############################
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 de septiembre del 2024>
-- Description: <Autenticacion del Usuario>
-- ############################
ALTER PROCEDURE [dbo].[sp_iniciar_sesion]
    @correo VARCHAR(100),               
    @contrasena VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

		DECLARE @tipoError INT;
		DECLARE @mensaje VARCHAR(255);

    BEGIN TRY
        -- Inicialización de variables de salida

        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @correo IS NULL OR @correo = '' OR @contrasena IS NULL OR @contrasena = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos correo y contraseña son obligatorios';
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        DECLARE @contrasena_bd VARCHAR(64);
        DECLARE @clienteId INT;             

        -- Verificar si el correo existe y obtener la contraseña y el ID del cliente
        SELECT @contrasena_bd = contrasena, @clienteId = clienteId
        FROM BSK_Autenticacion 
        WHERE correo = @correo;

        -- Comparar la contraseña y manejar los errores
        IF @contrasena_bd IS NULL
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'El correo no está registrado';
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Comparar contraseñas (usando el hash de la contraseña)
        IF @contrasena_bd != CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', @contrasena))
        BEGIN
            SET @tipoError = 2; 
            SET @mensaje = 'Contraseña incorrecta';
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Si la contraseña coincide, obtener los datos del usuario
		SET @tipoError = 0; 
        SET @mensaje = 'Operación correcta';

        SELECT
			[id] = id,
            [nombre] = nombre,
            [rolId] = rolId,
			@tipoError AS tipoError,
			@mensaje AS mensaje
        FROM BSK_Cliente
        WHERE id = @clienteId;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

		SELECT 
			0 AS Id, 
			NULL AS Nombre, 
			0 AS RolId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;

    END CATCH
END
