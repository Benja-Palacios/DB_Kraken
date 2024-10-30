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
    @ClienteId INT,
    @HorarioApertura TIME,
    @HorarioCierre TIME
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
        INSERT INTO BSK_Tienda (nombre, imagen, clienteId, horarioApertura, horarioCierre)
        VALUES (@Nombre, @Imagen, @ClienteId, @HorarioApertura, @HorarioCierre);

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
    @HorarioApertura TIME,
    @HorarioCierre TIME,
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
            clienteId = @ClienteId,
            horarioApertura = @HorarioApertura,
            horarioCierre = @HorarioCierre
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


        SET @tipoError = 0;
        SET @mensaje = 'Estilo agregado exitosamente';

        SELECT  @tipoError AS tipoError, @mensaje AS mensaje;

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
    @Descripcion VARCHAR(255),
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

        SELECT  @tipoError AS tipoError, @mensaje AS mensaje;

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
    @EstiloId INT,
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
        E.id AS Id,
        E.nombre AS Nombre,
        E.imagen AS Imagen,
        E.descripcion AS Descripcion,
		E.tiendaId AS TiendaId
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

-- #region sp_obtener_tienda_por_id
-- ############################
-- STORE PROCEDURE DE OBTENER TIENDA POR ID
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Obtner tienda por id>
-- ############################


CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_tienda_por_id]
    @TiendaID INT
AS
BEGIN
    SELECT 
        T.id AS TiendaID,
        T.nombre AS NombreTienda,
        T.imagen AS ImagenTienda,
		T.horarioApertura AS HorarioApertura,
		T.horarioCierre AS HorarioCierre
    FROM 
        BSK_Tienda T
    WHERE 
        T.id = @TiendaID;
END;
GO
PRINT 'Operación correcta, sp_obtener_tienda_por_id ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_editar_cliente
-- ############################
-- STORE PROCEDURE PARA EDITAR DATOS DEL USUARIO
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Date: <14 de octubre 2024 >
-- Description: <Permitir a los usuarios editar su información personal>
-- ############################
CREATE OR ALTER PROCEDURE [dbo].[sp_editar_cliente]
    @clienteId INT,
    @nombre VARCHAR(50),
    @apellidoPaterno VARCHAR(50),
    @apellidoMaterno VARCHAR(50),
    @correo VARCHAR(100),
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @tipoError = 0;
    SET @mensaje = '';

    BEGIN TRY

        -- Validación de nulos o vacíos
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '' OR 
           @apellidoPaterno IS NULL OR LTRIM(RTRIM(@apellidoPaterno)) = '' OR 
           @apellidoMaterno IS NULL OR LTRIM(RTRIM(@apellidoMaterno)) = '' OR 
           @correo IS NULL OR LTRIM(RTRIM(@correo)) = ''
        BEGIN
            SET @tipoError = 4;
            SET @mensaje = 'Ninguno de los campos puede estar vacío';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @clienteId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'Cliente no encontrado';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el correo ya está en uso por otro cliente
        IF EXISTS (SELECT 1 FROM BSK_Autenticacion WHERE correo = @correo AND clienteId != @clienteId)
        BEGIN
            SET @tipoError = 2;
            SET @mensaje = 'El correo ya está en uso por otro cliente';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Actualizar datos en la tabla Cliente
        UPDATE BSK_Cliente
        SET nombre = @nombre,
            apellidoPaterno = @apellidoPaterno,
            apellidoMaterno = @apellidoMaterno
        WHERE id = @clienteId;

        -- Actualizar el correo en la tabla Autenticacion
        UPDATE BSK_Autenticacion
        SET correo = @correo
        WHERE clienteId = @clienteId;

        SET @tipoError = 0;
        SET @mensaje = 'Datos actualizados correctamente';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END TRY
    BEGIN CATCH
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END
GO
print 'Operación correcta, sp_editar_cliente ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_cambiar_contrasena
-- ############################
-- STORE PROCEDURE PARA CAMBIAR CONTRASEÑA
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Date: <Fecha Actual>
-- Description: <Permitir a los usuarios cambiar su contraseña>
-- ############################
CREATE OR ALTER PROCEDURE [dbo].[sp_cambiar_contrasena]
    @correo VARCHAR(100),
    @contrasenaActual VARCHAR(255),
    @nuevaContrasena VARCHAR(255),
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @tipoError = 0;
    SET @mensaje = '';

    BEGIN TRY
        -- Validar si el correo existe y obtener la contraseña actual
        DECLARE @contrasena_bd VARCHAR(64);
        DECLARE @clienteId INT;

        SELECT @contrasena_bd = contrasena, @clienteId = clienteId
        FROM BSK_Autenticacion
        WHERE correo = @correo;

        IF @contrasena_bd IS NULL
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'El correo no está registrado';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END
		    
        -- Validar la contraseña actual (convertir el hash a VARCHAR para comparar)
        IF @contrasena_bd != CONVERT(VARBINARY(64), HASHBYTES('SHA2_256', @contrasenaActual))
        BEGIN
            SET @tipoError = 2;
            SET @mensaje = 'Contraseña actual incorrecta';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END



        -- Actualizar la contraseña (almacenar como VARCHAR)
        UPDATE BSK_Autenticacion
        SET contrasena = HASHBYTES('SHA2_256', @nuevaContrasena)
        WHERE clienteId = @clienteId;

        SET @tipoError = 0;
        SET @mensaje = 'Contraseña actualizada correctamente';

        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END TRY
    BEGIN CATCH
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END
GO
print 'Operación correcta, sp_cambiar_contrasena ejecutado.';
GO
-- #endregion
------*************************************************************
-- #region sp_obtener_tiendas_por_cp
-- ############################
-- STORE PROCEDURE DE OBTENER TIENDAS POR CÓDIGO POSTAL
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Obtener las tiendas por código postal>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_tiendas_por_cp]
    @Filtro NVARCHAR(255),  -- Parámetro de búsqueda, puede ser el nombre del municipio o estado
    @EsCodigoPostal BIT      -- Bandera: 1 = Código Postal, 0 = Dirección Completa
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declarar variables para municipio y estado
    DECLARE @Municipio NVARCHAR(255) = NULL;
    DECLARE @Estado NVARCHAR(255) = NULL;

    -- Separar el filtro en municipio y estado si se busca por dirección completa
    IF @EsCodigoPostal = 0
    BEGIN
        -- Dividir el filtro en municipio y estado si se encuentra una coma
        IF CHARINDEX(',', @Filtro) > 0
        BEGIN
            SET @Municipio = LTRIM(RTRIM(LEFT(@Filtro, CHARINDEX(',', @Filtro) - 1)));
            SET @Estado = LTRIM(RTRIM(SUBSTRING(@Filtro, CHARINDEX(',', @Filtro) + 1, LEN(@Filtro))));
        END
        ELSE
        BEGIN
            -- Si no hay coma, asumir que es solo el estado
            SET @Estado = @Filtro;
        END
    END;

    -- Declarar tabla temporal para almacenar los resultados
    DECLARE @Resultados TABLE (
        TiendaID INT,
        NombreTienda NVARCHAR(255),
        ImagenTienda NVARCHAR(255),
        HorarioApertura TIME,
        HorarioCierre TIME
    );

    -- Intentar buscar con el municipio y el estado
    INSERT INTO @Resultados (TiendaID, NombreTienda, ImagenTienda, HorarioApertura, HorarioCierre)
    SELECT 
        T.id AS TiendaID,                
        T.nombre AS NombreTienda,         
        T.imagen AS ImagenTienda, 
        T.horarioApertura AS HorarioApertura,
        T.horarioCierre AS HorarioCierre
    FROM 
        BSK_Tienda T
    INNER JOIN 
        BSK_DireccionTienda D ON T.id = D.tiendaId
    WHERE 
        (
            (@EsCodigoPostal = 1 AND D.CP = @Filtro)  -- Búsqueda por Código Postal
        ) 
        OR 
        (
            @EsCodigoPostal = 0 AND D.municipio = @Municipio
        )
    GROUP BY 
        T.id, T.nombre, T.imagen, T.horarioApertura, T.horarioCierre;

    -- Si no se encontraron resultados con el municipio, buscar solo por el estado
    IF NOT EXISTS (SELECT 1 FROM @Resultados)
    BEGIN
        INSERT INTO @Resultados (TiendaID, NombreTienda, ImagenTienda, HorarioApertura, HorarioCierre)
        SELECT 
            T.id AS TiendaID,                
            T.nombre AS NombreTienda,         
            T.imagen AS ImagenTienda,
            T.horarioApertura AS HorarioApertura,
            T.horarioCierre AS HorarioCierre
        FROM 
            BSK_Tienda T
        INNER JOIN 
            BSK_DireccionTienda D ON T.id = D.tiendaId
        WHERE 
            @EsCodigoPostal = 0 AND D.estado = @Estado
        GROUP BY 
            T.id, T.nombre, T.imagen, T.horarioApertura, T.horarioCierre;
    END;

    -- Retornar los resultados
    SELECT * FROM @Resultados;

END;
GO
PRINT 'Operación correcta, sp_obtener_tiendas_por_cp ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_guardar_calificacion_tienda
-- ############################
-- STORE PROCEDURE DE GUARDAR CALIFICACION DE LA TENDA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Data: <14 de octubre 2024>
-- Description: <Guardar calificacion de las tiendas>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_guardar_calificacion_tienda]
    @TiendaId INT,
    @ClienteId INT,
    @Calificacion INT,
	@tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	SET @tipoError = 0;
    SET @mensaje = '';

    -- Verificar si ya existe una calificación para esta tienda y cliente
    IF EXISTS (SELECT 1 FROM BSK_CalificacionTienda WHERE tiendaId = @TiendaId AND clienteId = @ClienteId)
    BEGIN
        -- Si ya existe, actualizar la calificación
        UPDATE BSK_CalificacionTienda
        SET calificacion = @Calificacion, fechaCalificacion = GETDATE()
        WHERE tiendaId = @TiendaId AND clienteId = @ClienteId;

		SET @tipoError = 0;
        SET @mensaje = 'Calificacion Actualizada';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END
    ELSE
    BEGIN
        -- Si no existe, insertar una nueva calificación
        INSERT INTO BSK_CalificacionTienda (tiendaId, clienteId, calificacion)
        VALUES (@TiendaId, @ClienteId, @Calificacion);
		SET @tipoError = 0;
        SET @mensaje = 'Calificacion Agregada';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END
END;

print 'Operación correcta, sp_guardar_calificacion_tienda ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_agendar_cita
-- ############################
-- STORE PROCEDURE PARA AGENDAR CITA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <21 de octubre 2024>
-- Description: <Agendar cita para un cliente en una tienda específica>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_agendar_cita]
    @clienteId INT,
    @tiendaId INT,
    @direccionId INT,
    @empleadoId INT,
    @fechaCita VARCHAR(20), 
    @horaCita TIME,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Inicializar variables de salida
    SET @tipoError = 0;
    SET @mensaje = '';

    -- Validación de nulos
    IF @clienteId IS NULL OR @tiendaId IS NULL OR @direccionId IS NULL OR @empleadoId IS NULL OR @fechaCita IS NULL OR @horaCita IS NULL
    BEGIN
        SET @tipoError = 4;
        SET @mensaje = 'Ninguno de los campos puede estar vacío';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia de la tienda
    IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @tiendaId)
    BEGIN
        SET @tipoError = 1;
        SET @mensaje = 'La tienda seleccionada no existe.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia de la dirección
    IF NOT EXISTS (SELECT 1 FROM BSK_DireccionTienda WHERE id = @direccionId)
    BEGIN
        SET @tipoError = 2;
        SET @mensaje = 'La dirección seleccionada no existe.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia del barbero
    IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @empleadoId AND estado = 'Activo')
    BEGIN
        SET @tipoError = 5;
        SET @mensaje = 'El barbero seleccionado no existe o no está activo.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Verificar si ya existe una cita para el cliente en la misma tienda y fecha y hora
    IF EXISTS (
        SELECT 1 
        FROM BSK_Citas 
        WHERE clienteId = @clienteId 
          AND tiendaId = @tiendaId 
          AND fechaCita = @fechaCita 
          AND horaCita = @horaCita
    )
    BEGIN
        SET @tipoError = 6;
        SET @mensaje = 'El cliente ya tiene una cita agendada para esta fecha y hora en esta tienda.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Insertar la nueva cita
    INSERT INTO BSK_Citas (clienteId, tiendaId, direccionId, empleadoId, fechaCita, horaCita)
    VALUES (@clienteId, @tiendaId, @direccionId, @empleadoId, @fechaCita, @horaCita);

    SET @tipoError = 0;
    SET @mensaje = 'Cita agendada con éxito.';
    SELECT @tipoError AS tipoError, @mensaje AS mensaje;
END;
GO

print 'Operación correcta, sp_agendar_cita ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_editar_cita
-- ############################
-- STORE PROCEDURE PARA EDITAR CITA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <21 de octubre 2024>
-- Description: <Editar el estado, fecha y dirección de una cita existente>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_editar_cita]
    @citaId INT,
	@nuevoempleadoId INT,
    @nuevaFechaCita DATETIME,
	@nuevahoraCita TIME,
    @nuevoEstado VARCHAR(50),
    @nuevaDireccionId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Inicializar variables de salida
    SET @tipoError = 0;
    SET @mensaje = '';

    -- Verificar si la cita existe
    IF NOT EXISTS (SELECT 1 FROM BSK_Citas WHERE id = @citaId)
    BEGIN
        SET @tipoError = 1;
        SET @mensaje = 'La cita no existe.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

     -- Validación de nulos o vacíos
     IF @nuevaFechaCita IS NULL OR LTRIM(RTRIM(@nuevaFechaCita)) = '' OR 
           @nuevoEstado IS NULL OR LTRIM(RTRIM(@nuevoEstado)) = '' OR 
           @nuevaDireccionId IS NULL OR LTRIM(RTRIM(@nuevaDireccionId)) = ''  OR 
           @nuevahoraCita IS NULL OR LTRIM(RTRIM(@nuevahoraCita)) = '' OR 
           @nuevoempleadoId IS NULL OR LTRIM(RTRIM(@nuevoempleadoId)) = '' 
        
     BEGIN
            SET @tipoError = 4;
            SET @mensaje = 'Ninguno de los campos puede estar vacío';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
     END

    -- Actualizar los datos de la cita
    UPDATE BSK_Citas
    SET fechaCita = @nuevaFechaCita,
	    horaCita = @nuevahoraCita,
        estado = @nuevoEstado,
        direccionId = @nuevaDireccionId,
		empleadoId = @nuevoempleadoId
    WHERE id = @citaId;

    -- Retornar mensaje de éxito
    SET @tipoError = 0;
    SET @mensaje = 'Cita actualizada correctamente.';
    SELECT @tipoError AS tipoError, @mensaje AS mensaje;
END;

print 'Operación correcta, sp_editar_cita ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_consultar_citas_por_usuario
-- ############################
-- STORE PROCEDURE PARA CONSULTAR CITAS POR CLIENTE
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <21 de octubre 2024>
-- Description: <Consultar todas las citas de un cliente específico>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_consultar_citas_por_usuario]
    @clienteId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Seleccionar todas las citas del cliente
    SELECT 
        C.id AS CitaId,
        C.fechaCita,
        C.estado,
		E.nombre + ' ' + E.apellidoPaterno + ' ' + E.apellidoMaterno AS Empleado,
        T.nombre AS Tienda,
        D.ubicacion + ' ' + D.municipio + ' ' + D.CP AS Direccion,
		D.referencia AS Referencia,
		D.telefono AS Telefono,
        C.fechaCreacion
    FROM BSK_Citas C
    INNER JOIN BSK_Tienda T ON C.tiendaId = T.id
    INNER JOIN BSK_DireccionTienda D ON C.direccionId = D.id
	INNER JOIN BSK_Cliente E ON C.empleadoId = E.id
    WHERE C.clienteId = @clienteId
    ORDER BY C.fechaCita DESC;
END;

print 'Operación correcta, sp_consultar_citas_por_usuario ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_consultar_citas_por_tienda
-- ############################
-- STORE PROCEDURE PARA CONSULTAR CITAS AGENDADAS POR TIENDA
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <21 de octubre 2024>
-- Description: <Consultar todas las citas agendadas para una tienda específica>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_consultar_citas_por_tienda]
    @tiendaId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Seleccionar todas las citas agendadas para la tienda
    SELECT 
        C.id AS CitaId,
        C.fechaCita,
        C.estado,
        Cl.nombre + ' ' + Cl.apellidoPaterno AS Cliente,
        D.ubicacion AS Direccion,
        C.fechaCreacion
    FROM BSK_Citas C
    INNER JOIN BSK_Cliente Cl ON C.clienteId = Cl.id
    INNER JOIN BSK_DireccionTienda D ON C.direccionId = D.id
    WHERE C.tiendaId = @tiendaId
    ORDER BY C.fechaCita DESC;
END;

print 'Operación correcta, sp_consultar_citas_por_tienda ejecutado.';
GO
-- #endregion
------*************************************************************

-- #region sp_registrar_empleado
-- ############################
-- STORE PROCEDURE PARA REGISTAR EMPLEADOS 
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <28 de octubre 2024>
-- Description: <Registra Empleados>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_registrar_empleado]
    @nombre VARCHAR(50),               
    @apellidoPaterno VARCHAR(50),      
    @apellidoMaterno VARCHAR(50),      
    @correo VARCHAR(100),              
    @contrasena VARCHAR(255),          
    @rolId INT,
	@direccionId INT,
    @tiendaId INT,
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
        INSERT INTO BSK_Cliente (nombre, apellidoPaterno, apellidoMaterno, rolId, direccionId, tiendaId)
        VALUES (@nombre, @apellidoPaterno, @apellidoMaterno, @rolId, @direccionId, @tiendaId);

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
print 'Operacion correcta, Sp_registrar_empledo ejecutado.'
GO
-- #endregion
-----**************************************************************

-- #region sp_obtener_horarios_disponibles
-- ############################
-- STORE PROCEDURE PARA OBTENER HORARIOS DISPONIBLES 
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <28 de octubre 2024>
-- Description: <Obtiene los horarios disponibles>
-- ############################

CREATE OR ALTER PROCEDURE [dbo].[sp_obtener_horarios_disponibles]
    @tiendaId INT,
    @direccionId INT,
    @fechaSeleccionada DATE,
    @empleadoId INT, -- ID del barbero
    @duracionMinutos INT = 60, -- Duración de cada cita en minutos
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Inicializar variables de salida
    SET @tipoError = 0;
    SET @mensaje = '';

    -- Validación de nulos
    IF @tiendaId IS NULL OR @direccionId IS NULL OR @fechaSeleccionada IS NULL OR @empleadoId IS NULL
    BEGIN
        SET @tipoError = 4;
        SET @mensaje = 'Ninguno de los campos puede estar vacío';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia de la tienda
    IF NOT EXISTS (SELECT 1 FROM BSK_Tienda WHERE id = @tiendaId)
    BEGIN
        SET @tipoError = 1;
        SET @mensaje = 'La tienda seleccionada no existe.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia de la dirección
    IF NOT EXISTS (SELECT 1 FROM BSK_DireccionTienda WHERE id = @direccionId)
    BEGIN
        SET @tipoError = 2;
        SET @mensaje = 'La dirección seleccionada no existe.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Validación de existencia del barbero
    IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @empleadoId AND estado = 'Activo')
    BEGIN
        SET @tipoError = 5;
        SET @mensaje = 'El barbero seleccionado no existe o no está activo.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    DECLARE @horarioApertura TIME;
    DECLARE @horarioCierre TIME;

    -- Obtener el horario de apertura y cierre de la tienda
    SELECT @horarioApertura = horarioApertura, @horarioCierre = horarioCierre
    FROM BSK_Tienda
    WHERE id = @tiendaId;

    -- Validar que se obtuvo el horario
    IF @horarioApertura IS NULL OR @horarioCierre IS NULL
    BEGIN
        SET @tipoError = 3;
        SET @mensaje = 'No se encontró el horario para la tienda seleccionada.';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
        RETURN;
    END

    -- Generar una tabla temporal para almacenar los horarios ocupados
    CREATE TABLE #HorariosOcupados (
        Hora TIME,
        EmpleadoId INT
    );

    -- Obtener las citas ya agendadas para la fecha, tienda y empleado seleccionados
    INSERT INTO #HorariosOcupados (Hora, EmpleadoId)
    SELECT CAST(horaCita AS TIME), empleadoId
    FROM BSK_Citas
    WHERE tiendaId = @tiendaId
      AND direccionId = @direccionId
      AND CAST(fechaCita AS DATE) = @fechaSeleccionada;

    -- Generar lista de horarios disponibles
    DECLARE @horarioActual TIME = @horarioApertura;
    DECLARE @listaHorarios NVARCHAR(MAX) = '';

    WHILE @horarioActual < @horarioCierre
    BEGIN
        -- Contar cuántas citas hay a esta hora para el barbero seleccionado
        DECLARE @citasOcupadas INT = (SELECT COUNT(DISTINCT EmpleadoId) FROM #HorariosOcupados WHERE Hora = @horarioActual);

        -- Verificar si el barbero está ocupado a esta hora
        IF NOT EXISTS (SELECT 1 FROM #HorariosOcupados WHERE Hora = @horarioActual AND EmpleadoId = @empleadoId)
        BEGIN
            -- Agregar hora disponible a la lista si el barbero está disponible
            SET @listaHorarios = @listaHorarios + CAST(@horarioActual AS NVARCHAR(5)) + ', ';
        END

        -- Incrementar la hora actual por la duración de la cita
        SET @horarioActual = DATEADD(MINUTE, @duracionMinutos, @horarioActual);
    END

    -- Eliminar la última coma y espacio
    SET @listaHorarios = RTRIM(SUBSTRING(@listaHorarios, 1, LEN(@listaHorarios) - 2));

    -- Retornar la lista de horarios disponibles
    SET @tipoError = 0;
    SET @mensaje = 'Horarios disponibles: ' + @listaHorarios;

    SELECT @tipoError AS tipoError, @mensaje AS mensaje;

    DROP TABLE #HorariosOcupados; -- Limpiar tabla temporal
END;
GO
print 'Operacion correcta, sp_obtener_horarios_disponibles ejecutado.'
GO
-- #endregion

-- #region sp_trabajadores_por_direccion
-- ############################
-- STORE PROCEDURE PARA OBTENER TRABAJADORES POR DIRECCION 
-- Autor: <Emil Jesus Hernandez Avilez>
-- Create Date: <28 de octubre 2024>
-- Description: <Obtiene los trabajadores por direccion>
-- ############################

CREATE OR ALTER PROCEDURE sp_trabajadores_por_direccion (
    @DireccionId INT
)
AS
BEGIN
    SELECT 
        C.id AS trabajadorId,
        CONCAT(C.nombre, ' ', C.apellidoPaterno, ' ', C.apellidoMaterno) AS nombreCompleto
    FROM 
        BSK_Cliente C
    INNER JOIN 
        BSK_DireccionTienda DT ON C.direccionId = DT.id
    WHERE 
        DT.id = @DireccionId
        AND C.tiendaId IS NOT NULL  -- Asegura que tenga asignado un tiendaId
        AND C.direccionId IS NOT NULL; -- Asegura que tenga asignado un direccionId
END;
GO
print 'Operacion correcta, sp_trabajadores_por_direccion ejecutado.'
GO

-- #endregion

-- #region sp_editar_empleado
-- ############################
-- STORE PROCEDURE PARA EDITAR DATOS DEL EMPLEADO
-- Autor: <Emil Jesus Hernandez Avila>
-- Create Date: <14 de octubre 2024 >
-- Description: <Permitir a los administadores editar su información personal de sus empleados>
-- ############################
CREATE OR ALTER PROCEDURE [dbo].[sp_editar_empleado]
    @clienteId INT,
    @nombre VARCHAR(50),
    @apellidoPaterno VARCHAR(50),
    @apellidoMaterno VARCHAR(50),
    @correo VARCHAR(100),
    @rolId INT,
	@direccionId INT,
    @tipoError INT OUTPUT,
    @mensaje VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @tipoError = 0;
    SET @mensaje = '';

    BEGIN TRY

        -- Validación de nulos o vacíos
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '' OR 
           @apellidoPaterno IS NULL OR LTRIM(RTRIM(@apellidoPaterno)) = '' OR 
           @apellidoMaterno IS NULL OR LTRIM(RTRIM(@apellidoMaterno)) = '' OR 
           @correo IS NULL OR LTRIM(RTRIM(@correo)) = ''OR 
           @rolId IS NULL OR LTRIM(RTRIM(@rolId)) = ''OR 
           @direccionId IS NULL OR LTRIM(RTRIM(@direccionId)) = ''
        BEGIN
            SET @tipoError = 4;
            SET @mensaje = 'Ninguno de los campos puede estar vacío';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM BSK_Cliente WHERE id = @clienteId)
        BEGIN
            SET @tipoError = 1;
            SET @mensaje = 'Cliente no encontrado';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Verificar si el correo ya está en uso por otro cliente
        IF EXISTS (SELECT 1 FROM BSK_Autenticacion WHERE correo = @correo AND clienteId != @clienteId)
        BEGIN
            SET @tipoError = 2;
            SET @mensaje = 'El correo ya está en uso por otro cliente';
            SELECT @tipoError AS tipoError, @mensaje AS mensaje;
            RETURN;
        END

        -- Actualizar datos en la tabla Cliente
        UPDATE BSK_Cliente
        SET nombre = @nombre,
            apellidoPaterno = @apellidoPaterno,
            apellidoMaterno = @apellidoMaterno,
            rolId = @rolId,
            direccionId= @direccionId
        WHERE id = @clienteId;

        -- Actualizar el correo en la tabla Autenticacion
        UPDATE BSK_Autenticacion
        SET correo = @correo
        WHERE clienteId = @clienteId;

        SET @tipoError = 0;
        SET @mensaje = 'Datos actualizados correctamente';
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END TRY
    BEGIN CATCH
        SET @tipoError = 3;
        SET @mensaje = ERROR_MESSAGE();
        SELECT @tipoError AS tipoError, @mensaje AS mensaje;
    END CATCH
END
GO
print 'Operación correcta, sp_editar_empleado ejecutado.';
GO
-- #endregion
------*************************************************************
