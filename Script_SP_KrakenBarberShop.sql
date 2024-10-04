USE [KraenBarberShop]
GO

-- ############################
-- STORE PROCEDURE DE REGISTRO DE USUARIOS
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 septiembre 2024>
-- Description: <Crear un nuevo usuario con un rol en especifico>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_registrar_cliente]
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
        -- Comienza la transacci�n
        BEGIN TRANSACTION;

        -- Validaci�n del correo electr�nico
        IF dbo.fn_validar_correo(@correo) = 0
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'Formato de correo inv�lido';
            ROLLBACK TRANSACTION;
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el correo ya est� registrado
        IF EXISTS (SELECT 1 FROM BSK_Autenticacion WHERE correo = @correo)
        BEGIN
            SET @tipoError = 2; 
            SET @mensaje = 'El correo ya est� registrado';
            ROLLBACK TRANSACTION;
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Inserci�n en la tabla Cliente
        INSERT INTO BSK_Cliente (nombre, apellidoPaterno, apellidoMaterno, rolId)
        VALUES (@nombre, @apellidoPaterno, @apellidoMaterno, @rolId);

        DECLARE @clienteId INT = SCOPE_IDENTITY();
        DECLARE @hashedPassword VARBINARY(64) = HASHBYTES('SHA2_256', @contrasena);

        -- Inserci�n en la tabla Autenticacion
        INSERT INTO BSK_Autenticacion (correo, contrasena, clienteId)
        VALUES (@correo, @hashedPassword, @clienteId);

        -- Confirma la transacci�n
        COMMIT TRANSACTION;

        SET @tipoError = 0;  -- 0 indica operaci�n correcta
        SET @mensaje = 'Operaci�n correcta';

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
GO
print 'Operacion correcta, Sp_registrar_cliente ejecutado.'
-----******************************************************************

-- ############################
-- STORE PROCEDURE DE INICIO DE SESION
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Data: <28 de septiembre del 2024>
-- Description: <Autenticacion del Usuario>
-- ############################
CREATE OR ALTER PROCEDURE [dbo].[sp_iniciar_sesion]
    @correo VARCHAR(100),               
    @contrasena VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

		DECLARE @tipoError INT;
		DECLARE @mensaje VARCHAR(255);

    BEGIN TRY
        -- Inicializaci�n de variables de salida

        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validaci�n de datos de entrada
        IF @correo IS NULL OR @correo = '' OR @contrasena IS NULL OR @contrasena = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos correo y contrase�a son obligatorios';
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje, @correo AS correo, @contrasena AS contrasena ;
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
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje, @correo AS correo, @contrasena AS contrasena;
            RETURN;
        END

        -- Comparar contrase�as (usando el hash de la contrase�a)
        IF @contrasena_bd != CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', @contrasena))
        BEGIN
            SET @tipoError = 2; 
            SET @mensaje = 'Contrase�a incorrecta';
			SELECT 0 AS Id, NULL AS Nombre, 0 AS RolId, @tipoError AS tipoError, @mensaje AS mensaje, @correo AS correo, @contrasena AS contrasena;
            RETURN;
        END

        -- Si la contrase�a coincide, obtener los datos del usuario
		SET @tipoError = 0; 
        SET @mensaje = 'Operaci�n correcta';

        SELECT
			[id] = id,
            [nombre] = nombre,
            [rolId] = rolId,
			@tipoError AS tipoError,
			@mensaje AS mensaje, 
            @correo AS correo, 
            @contrasena AS contrasena
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
            @mensaje AS mensaje, 
            @correo AS correo, 
            @contrasena AS contrasena;

    END CATCH
END
GO
print 'Operacion correcta, sp_iniciar_sesion ejecutado.'
------*************************************************************