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

-- ############################
-- STORE PROCEDURE DE AGREGAR TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <agregar nueva tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_tienda]

    @Nombre VARCHAR(100),
    @Imagen VARCHAR(255),
    @ClienteId INT
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
        IF @Nombre IS NULL OR @Nombre = '' OR @Imagen IS NULL OR @Imagen = '' OR @ClienteId IS NULL
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos Nombre y Imagen son obligatorios';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen, @ClienteId AS clienteId;
            RETURN;
        END

        -- Validar que el AdministradorId exista en la tabla de administradores
        IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @ClienteId)
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'El Administrador no existe';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen, @ClienteId AS clienteId;
            RETURN;
        END

        -- Inserción de la tienda
        INSERT INTO BSK_Tienda (nombre, imagen, clienteId)
        VALUES (@Nombre, @Imagen, @ClienteId);

        -- Retornar el ID de la tienda recién agregada
        DECLARE @TiendaId INT;
        SET @TiendaId = SCOPE_IDENTITY();

        SET @tipoError = 0;
        SET @mensaje = 'Tienda agregada exitosamente';

        SELECT @TiendaId AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen, @ClienteId AS clienteId;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS TiendaId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje, 
            @Nombre AS Nombre, 
            @Imagen AS Imagen, 
            @ClienteId AS clienteId;
    END CATCH
END
GO
print 'Operacion correcta, sp_agregar_tienda ejecutado.'
GO
------*************************************************************

-- ############################
-- STORE PROCEDURE DE EDITAR TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <edita la tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_editar_tienda]
    @TiendaId INT,
    @Nombre VARCHAR(100),
    @Imagen VARCHAR(255)
   
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
        IF @TiendaId IS NULL OR @TiendaId <= 0 OR @Nombre IS NULL OR @Nombre = '' OR @Imagen IS NULL OR @Imagen = '' 
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos Nombre y Imagen son obligatorios';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen;
            RETURN;
        END

        -- Validar que la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda que desea editar no existe';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen;
            RETURN;
        END


        -- Actualización de los datos de la tienda
        UPDATE BSK_Tienda
        SET nombre = @Nombre,
            imagen = @Imagen
        WHERE id = @TiendaId;

        -- Si la actualización fue exitosa
        SET @tipoError = 0;
        SET @mensaje = 'Tienda actualizada correctamente';

        SELECT @TiendaId AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje, @Nombre AS Nombre, @Imagen AS Imagen;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS TiendaId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje, 
            @Nombre AS Nombre, 
            @Imagen AS Imagen
    END CATCH
END;
GO
print 'Operacion correcta, sp_editar_tienda ejecutado.'
GO
------*************************************************************

-- ############################
-- STORE PROCEDURE DE ELIMINAR TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <elimina la tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_tienda]
    @TiendaId INT
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
        IF @TiendaId IS NULL OR @TiendaId <= 0
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'El tienda a eliminar es obligatoria';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda que desea eliminar no existe';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Eliminar las direcciones asociadas a la tienda
        DELETE FROM BSK_DireccionTienda WHERE tiendaId = @TiendaId;

        -- Eliminar la tienda
        DELETE FROM BSK_Tienda WHERE id = @TiendaId;

        -- Si la eliminación fue exitosa
        SET @tipoError = 0;
        SET @mensaje = 'Tienda eliminada correctamente';

        SELECT @TiendaId AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS TiendaId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operacion correcta, sp_eliminar_tienda ejecutado.'
GO
------*************************************************************

-- ############################
-- STORE PROCEDURE DE AGREGAR DIRECCION A LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <Agregar una direccion a las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_direccion]
    @CP VARCHAR(5),
    @ubicacion VARCHAR(50),
    @tipoVivienda VARCHAR(50),
    @municipio VARCHAR(100),
    @estado VARCHAR(100),
    @ciudad VARCHAR(100),
    @pais VARCHAR(100),
    @NoExterior VARCHAR(10),
    @Telefono VARCHAR(10),
    @Referencia VARCHAR(255) = NULL,  
    @TiendaId INT
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
        IF LTRIM(RTRIM(@CP)) = '' OR 
           LTRIM(RTRIM(@ubicacion)) = '' OR 
           LTRIM(RTRIM(@tipoVivienda)) = '' OR 
           LTRIM(RTRIM(@municipio)) = '' OR 
           LTRIM(RTRIM(@estado)) = '' OR 
           LTRIM(RTRIM(@ciudad)) = '' OR 
           LTRIM(RTRIM(@pais)) = '' OR 
           LTRIM(RTRIM(@NoExterior)) = '' OR 
           LTRIM(RTRIM(@Telefono)) = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Todos los campos son obligatorios.';
            SELECT 0 AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda a la que desea agregar la dirección no existe';
            SELECT 0 AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Insertar la dirección de la tienda
        INSERT INTO BSK_DireccionTienda (CP, estado, municipio, asentamiento, tipo_asentamiento, ciudad, pais, noExterior, telefono, referencia, tiendaId)

        VALUES (@CP, @Estado, @Municipio, @Ubicacion, @TipoVivienda, @Ciudad, @Pais, @NoExterior, @Telefono, @Referencia, @TiendaId);


        -- Si la inserción fue exitosa
        DECLARE @DireccionId INT = SCOPE_IDENTITY();
        SET @tipoError = 0;
        SET @mensaje = 'Dirección de tienda agregada correctamente';

        SELECT @DireccionId AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS DireccionId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_agregar_direccion ejecutado.';
GO
------*************************************************************

-- ############################
-- STORE PROCEDURE DE EDITAR DIRECCION DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <Edita la direccion de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_editar_direccion]
    @DireccionId INT,
    @CP VARCHAR(5),
    @ubicacion VARCHAR(50),
    @tipoVivienda VARCHAR(50),
    @municipio VARCHAR(100),
    @estado VARCHAR(100),
    @ciudad VARCHAR(100),
    @pais VARCHAR(100),
    @NoExterior VARCHAR(10),
    @Telefono VARCHAR(10),
    @Referencia VARCHAR(255)
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
        IF @DireccionId IS NULL OR @DireccionId <= 0 OR
           LTRIM(RTRIM(@CP)) = '' OR 
           LTRIM(RTRIM(@ubicacion)) = '' OR 
           LTRIM(RTRIM(@tipoVivienda)) = '' OR 
           LTRIM(RTRIM(@municipio)) = '' OR 
           LTRIM(RTRIM(@estado)) = '' OR 
           LTRIM(RTRIM(@ciudad)) = '' OR 
           LTRIM(RTRIM(@pais)) = '' OR 
           LTRIM(RTRIM(@NoExterior)) = '' OR 
           LTRIM(RTRIM(@Telefono)) = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Todos los campos son obligatorios.';
            SELECT 0 AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si la dirección existe
        IF NOT EXISTS (SELECT 1 FROM BSK_DireccionTienda WHERE id = @DireccionId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La dirección que desea editar no existe';
            SELECT 0 AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Actualizar la dirección de la tienda
        UPDATE BSK_DireccionTienda
        SET CP = @CP,
            ubicacion = @Ubicacion,
            tipoVivienda = @TipoVivienda,
            municipio = @Municipio,
            estado = @Estado,
            ciudad = @Ciudad,
            pais = @Pais,  
            noExterior = @NoExterior,
            telefono = @Telefono,
            referencia = @Referencia
        WHERE id = @DireccionId;

        -- Si la actualización fue exitosa
        SET @tipoError = 0; 
        SET @mensaje = 'Dirección de tienda actualizada correctamente';

        SELECT @DireccionId AS DireccionId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS DireccionId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_editar_direccion ejecutado.';
GO
------*************************************************************

-- ############################
-- STORE PROCEDURE DE ELIMINAR DIRECCION DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <Elimina la direccion de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_direccion]
    @DireccionId INT
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
        IF @DireccionId IS NULL OR @DireccionId <= 0
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'La direccion que desea eliminar es obligatoria';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si la dirección existe
        IF NOT EXISTS (SELECT 1 FROM BSK_DireccionTienda WHERE id = @DireccionId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La dirección que desea eliminar no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Eliminar la dirección de la tienda
        DELETE FROM BSK_DireccionTienda WHERE id = @DireccionId;

        -- Si la eliminación fue exitosa
        SET @tipoError = 0; 
        SET @mensaje = 'Dirección de tienda eliminada correctamente';

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_eliminar_direccion ejecutado.';
GO
------*************************************************************
