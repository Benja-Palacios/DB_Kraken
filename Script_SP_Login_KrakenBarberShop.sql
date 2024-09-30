-- STORE PROCEDURE DE INICIO DE SESION
USE [KraenBarberShop]
GO

-- ############################
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 de septiembre del 2024>
-- Description: <Autenticacion del Usuario>
-- ############################
ALTER PROCEDURE sp_iniciar_sesion
    @correo VARCHAR(100),               
    @contrasena VARCHAR(255),
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicializaci�n de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validaci�n de datos de entrada
        IF @correo IS NULL OR @correo = '' OR @contrasena IS NULL OR @contrasena = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos correo y contrase�a son obligatorios';
			SELECT NULL AS Id, NULL AS Nombre, NULL AS RolId
            RETURN;
        END

        DECLARE @contrasena_bd VARCHAR(64);
        DECLARE @clienteId INT;             

        -- Verificar si el correo existe y obtener la contrase�a y el ID del cliente
        SELECT @contrasena_bd = contrasena, @clienteId = clienteId
        FROM BSK_Autenticacion 
        WHERE correo = @correo;

        -- Comparar la contrase�a y manejar los errores
        IF @contrasena_bd IS NULL
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'El correo no est� registrado';
			SELECT NULL AS Id, NULL AS Nombre, NULL AS RolId
            RETURN;
        END

        -- Comparar contrase�as (usando el hash de la contrase�a)
        IF @contrasena_bd != CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', @contrasena))
        BEGIN
            SET @tipoError = 2; 
            SET @mensaje = 'Contrase�a incorrecta';
			SELECT NULL AS Id, NULL AS Nombre, NULL AS RolId
            RETURN;
        END

        -- Si la contrase�a coincide, obtener los datos del usuario
        SELECT
			[id] = id,
            [nombre] = nombre,
            [rolId] = rolId
        FROM BSK_Cliente
        WHERE id = @clienteId;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();
    END CATCH

    -- Si hubo un error, devuelve el tipo de error y el mensaje
    IF @tipoError <> 0
    BEGIN
        SELECT 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END
END
