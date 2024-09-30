USE [KraenBarberShop]
GO

-- ############################
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 de septiembre del 2024>
-- Description: <Crear un nuevo usuario con un rol en específico>
-- ############################

ALTER PROCEDURE [dbo].[sp_registrar_cliente]
    @nombre VARCHAR(50),               
    @apellidoPaterno VARCHAR(50),      
    @apellidoMaterno VARCHAR(50),      
    @correo VARCHAR(100),              
    @contrasena VARCHAR(255),          
    @rolId INT,                        
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @tipoError = 0;
    SET @mensaje = '';

    BEGIN TRY
        -- Comienza la transacción
        BEGIN TRANSACTION;

        -- Validación del correo electrónico
        IF dbo.fn_validar_correo(@correo) = 0
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'Formato de correo inválido';
            ROLLBACK TRANSACTION;
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el correo ya está registrado
        IF EXISTS (SELECT 1 FROM BSK_Autenticacion WHERE correo = @correo)
        BEGIN
            SET @tipoError = 2; 
            SET @mensaje = 'El correo ya está registrado';
            ROLLBACK TRANSACTION;
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Inserción en la tabla Cliente
        INSERT INTO BSK_Cliente (nombre, apellidoPaterno, apellidoMaterno, rolId)
        VALUES (@nombre, @apellidoPaterno, @apellidoMaterno, @rolId);

        DECLARE @clienteId INT = SCOPE_IDENTITY();
        DECLARE @hashedPassword VARBINARY(64) = HASHBYTES('SHA2_256', @contrasena);

        -- Inserción en la tabla Autenticacion
        INSERT INTO BSK_Autenticacion (correo, contrasena, clienteId)
        VALUES (@correo, @hashedPassword, @clienteId);

        -- Confirma la transacción
        COMMIT TRANSACTION;

        SET @tipoError = 0;  -- 0 indica operación correcta
        SET @mensaje = 'Operación correcta';

        SELECT @tipoError as tipoError, @mensaje as mensaje;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END