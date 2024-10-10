-- #region sp_registrar_cliente
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
GO
-- #endregion
-----**************************************************************
-- #region sp_iniciar_sesion
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
GO
-- #endregion
------*************************************************************
-- #region sp_agregar_tienda
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
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que el AdministradorId exista en la tabla de administradores
        IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @ClienteId)
        BEGIN
            SET @tipoError = 1; 
            SET @mensaje = 'El Administrador no existe';
            SELECT 0 AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;
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

        SELECT @TiendaId AS TiendaId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS TiendaId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje
    END CATCH
END
GO
print 'Operacion correcta, sp_agregar_tienda ejecutado.'
GO
-- #endregion
------*************************************************************
-- #region sp_editar_tienda
-- ############################
-- STORE PROCEDURE DE EDITAR TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <edita la tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_editar_tienda]
    @TiendaId INT,
    @Nombre VARCHAR(100),
    @Imagen VARCHAR(255),
    @ClienteId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @TiendaId IS NULL OR @TiendaId <= 0 OR @Nombre IS NULL OR @Nombre = '' OR @Imagen IS NULL OR @Imagen = ''
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos Nombre y Imagen son obligatorios';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda que desea editar no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @ClienteId)
        BEGIN
            SET @tipoError = 2;
            SET @mensaje = 'El cliente no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Iniciar una transacción
        BEGIN TRANSACTION;

        -- Actualización de los datos de la tienda
        UPDATE BSK_Tienda
        SET nombre = @Nombre,
            imagen = @Imagen,
            clienteId = @ClienteId
        WHERE id = @TiendaId;

        -- Verificar si se realizaron cambios
        IF @@ROWCOUNT = 0
        BEGIN
            SET @tipoError = 2;
            SET @mensaje = 'No se realizaron cambios en la tienda';
            ROLLBACK TRANSACTION;
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Confirmar la transacción
        COMMIT TRANSACTION;

        -- Si la actualización fue exitosa
        SET @tipoError = 0;
        SET @mensaje = 'Tienda actualizada correctamente';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operacion correcta, sp_editar_tienda ejecutado.'
GO
-- #endregion
------*************************************************************
-- #region sp_eliminar_tienda
-- ############################
-- STORE PROCEDURE DE ELIMINAR TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <elimina la tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_tienda]
    @TiendaId INT,
	@tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @TiendaId IS NULL OR @TiendaId <= 0
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'El tienda a eliminar es obligatoria';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda que desea eliminar no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Eliminar las direcciones asociadas a la tienda
        DELETE FROM BSK_DireccionTienda WHERE tiendaId = @TiendaId;

        -- Eliminar la tienda
        DELETE FROM BSK_Tienda WHERE id = @TiendaId;

        -- Si la eliminación fue exitosa
        SET @tipoError = 0;
        SET @mensaje = 'Tienda eliminada correctamente';

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;

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
-- #endregion
------*************************************************************
-- #region sp_agregar_direccion
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
    @TiendaId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

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
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda a la que desea agregar la dirección no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Insertar la dirección de la tienda
        INSERT INTO BSK_DireccionTienda (CP, estado, municipio, ubicacion, tipoVivienda, ciudad, pais, noExterior, telefono, referencia, tiendaId)

        VALUES (@CP, @Estado, @Municipio, @Ubicacion, @TipoVivienda, @Ciudad, @Pais, @NoExterior, @Telefono, @Referencia, @TiendaId);


        -- Si la inserción fue exitosa
        DECLARE @DireccionId INT = SCOPE_IDENTITY();
        SET @tipoError = 0;
        SET @mensaje = 'Dirección de tienda agregada correctamente';

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_agregar_direccion ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_editar_direccion
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
    @Referencia VARCHAR(255),
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

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
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si la dirección existe
        IF NOT EXISTS (SELECT 1 FROM BSK_DireccionTienda WHERE id = @DireccionId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La dirección que desea editar no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
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

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_editar_direccion ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_eliminar_direccion
-- ############################
-- STORE PROCEDURE DE ELIMINAR DIRECCION DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <6 de octubre 2024>
-- Description: <Elimina la direccion de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_direccion]
    @DireccionId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

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
-- #endregion
------*************************************************************
-- #region sp_agregar_estilo
-- ############################
-- STORE PROCEDURE DE AGREGAR ESTILO DE CORTE DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Agrega el estilo de corte de las tiendas>
-- ############################


CREATE OR ALTER PROCEDURE [dbo].[sp_agregar_estilo]
    @Nombre VARCHAR(100),
    @Imagen VARCHAR(255),
    @Descripcion VARCHAR(255),
    @TiendaId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @Nombre IS NULL OR @Nombre = '' OR @Imagen IS NULL OR @Imagen = '' OR @TiendaId IS NULL
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos Nombre y Imagen son obligatorios';
            SELECT 0 AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar que la tienda existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @TiendaId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'La tienda a la que desea agregar el estilo del corte no existe';
            SELECT 0 AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Inserción del estilo
        INSERT INTO BSK_EstilosTienda (nombre, imagen, descripcion, tiendaId)
        VALUES (@Nombre, @Imagen, @Descripcion, @TiendaId);  -- Corregida la coma faltante

        -- Retornar el ID del estilo recién agregado
        DECLARE @EstiloId INT;
        SET @EstiloId = SCOPE_IDENTITY();  -- Cambié la variable correcta para capturar el ID del estilo

        SET @tipoError = 0;
        SET @mensaje = 'Estilo agregado exitosamente';

        SELECT @EstiloId AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS EstiloId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END
GO
print 'Operacion correcta, sp_agregar_estilo ejecutado.'
GO
-- #endregion
------*************************************************************
-- #region sp_editar_estilo
-- ############################
-- STORE PROCEDURE DE EDITAR ESTILO DE CORTE DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Edita el estilo de corte de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_editar_estilo]
    @EstiloId INT,
	@Nombre VARCHAR(100),
    @Imagen VARCHAR(255),
    @Descripcion VARCHAR(255)
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
    
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @Nombre IS NULL OR @Nombre = '' OR @Imagen IS NULL OR @Imagen = '' OR @EstiloId IS NULL
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'Los campos Nombre y Imagen son obligatorios';
            SELECT 0 AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el estilo existe
        IF NOT EXISTS (SELECT 1 FROM BSK_EstilosTienda WHERE id = @EstiloId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'El estilo que desea editar no existe';
            SELECT 0 AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Actualizar la dirección de la tienda
        UPDATE BSK_EstilosTienda
        SET 
            nombre = @Nombre,
            imagen = @Imagen,
            descripcion = @Descripcion
        WHERE id = @EstiloId;

        -- Si la actualización fue exitosa
        SET @tipoError = 0; 
        SET @mensaje = 'Estilo de la tienda actualizado correctamente';

        SELECT @EstiloId AS EstiloId, @tipoError AS tipoError, @mensaje AS mensaje;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @tipoError = 3;  
        SET @mensaje = ERROR_MESSAGE();

        SELECT 
            0 AS EstiloId, 
            @tipoError AS tipoError, 
            @mensaje AS mensaje;
    END CATCH
END;
GO
print 'Operación correcta, sp_editar_estilo ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_eliminar_estilo
-- ############################
-- STORE PROCEDURE DE ELIMINAR ESTILO DE CORTE DE LAS TIENDAS
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Elimina el estilo de corte de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_estilo]
    @EstiloId INT
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Inicialización de variables de salida
        SET @tipoError = 0; 
        SET @mensaje = '';

        -- Validación de datos de entrada
        IF @EstiloId IS NULL OR @EstiloId <= 0
        BEGIN
            SET @tipoError = 4; 
            SET @mensaje = 'El estilo que desea eliminar es obligatoria';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el estilo existe
        IF NOT EXISTS (SELECT 1 FROM BSK_EstilosTienda WHERE id = @EstiloId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'El estilo que desea eliminar no existe';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Eliminar el estilo de la tienda
        DELETE FROM BSK_EstilosTienda WHERE id = @EstiloId;

        -- Si la eliminación fue exitosa
        SET @tipoError = 0; 
        SET @mensaje = 'Estilo de tienda eliminado correctamente';

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
print 'Operación correcta, sp_eliminar_estilo ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_obtener_direcciones_por_tienda
-- ############################
-- STORE PROCEDURE DE OBTENER DIRECCIONES DE LAS TIENDA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Obtner las direcciones de las tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_direcciones_por_tienda]
    @TiendaID INT
    
AS
BEGIN
    SELECT 
        D.id AS DireccionID,
        D.CP AS CP,
        D.ubicacion AS Ubicacion,
        D.tipoVivienda AS TipoVivienda,
        D.municipio AS Municipio,
        D.estado AS Estado,
        D.ciudad AS Ciudad,
        D.pais AS Pais,
        D.noExterior AS NoExterior,
        D.telefono AS Telefono,
        D.referencia AS Referencia
    FROM 
        BSK_DireccionTienda D
    WHERE 
        D.tiendaId = @TiendaID;
END;
GO
print 'Operación correcta, sp_obtener_direcciones_por_tienda ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_obtener_tiendas_por_cliente
-- ############################
-- STORE PROCEDURE DE OBTENER TIENDAS POR ID CLIENTE
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Obtner las tiendas por id cliente>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_tiendas_por_cliente]
    @ClienteID INT
AS
BEGIN
    SELECT 
        T.id AS TiendaID,                
        T.nombre AS NombreTienda,         
        T.imagen AS ImagenTienda               
    FROM 
        BSK_Tienda T
    INNER JOIN 
        BSK_Cliente C ON T.clienteId = C.id
    WHERE 
        C.id = @ClienteID;
END;
GO
print 'Operación correcta, sp_obtener_tiendas_por_cliente ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_obtener_estilos_por_tienda
-- ############################
-- STORE PROCEDURE DE OBTENER ESTILOS DE LAS TIENDA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Obtner las estilos de las tienda>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_estilos_por_tienda]
    @TiendaID INT
AS
BEGIN
    SELECT 
        E.id AS TiendaID,
        E.nombre AS Nombre,
        E.imagen AS Imagen,
        E.descripcion AS Descripcion
    FROM 
        BSK_EstilosTienda E
    WHERE 
        E.tiendaId = @TiendaID;
END;
GO
print 'Operación correcta, sp_obtener_estilos_por_tienda ejecutado.';
GO
-- #endregion
------*************************************************************