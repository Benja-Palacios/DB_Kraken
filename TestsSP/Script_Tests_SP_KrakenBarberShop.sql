------------STORE PROCEDURE DE REGISTRO DE USUARIOS

DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_registrar_cliente]
    @nombre = 'Juan',
    @apellidoPaterno = 'Pérez',
    @apellidoMaterno = 'González',
    @correo = 'juan.perez@example.com',
    @contrasena = 'password123',
    @rolId = 1,  
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE PARA REGISTRAR EMPLEADOS 
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_registrar_empleado] 
    @nombre = 'Juan',
    @apellidoPaterno = 'Pérez',
    @apellidoMaterno = 'Gómez',
    @correo = 'juan.perez@example.com',
    @contrasena = 'contraseña123',
    @rolId = 1, 
	@direccionId = 1, 
    @tiendaId = 1,
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE DE INICIO DE SESION

EXEC [dbo].[sp_iniciar_sesion]
    @correo = 'juan.perez@example.com',
    @contrasena = 'password123';

-----------STORE PROCEDURE DE AGREGAR TIENDAS

EXEC [dbo].[sp_agregar_tienda]
    @Nombre = 'NombreTienda2',
    @Imagen = 'ruta/imagen.jpg',
	@HorarioApertura = '11:00',
    @HorarioCierre = '19:00',
    @ClienteId = 1;

-----------STORE PROCEDURE DE EDITAR TIENDAS
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC dbo.sp_editar_tienda 
    @TiendaId = 1, 
    @Nombre = 'Nombre de Tienda', 
    @Imagen = 'url_imagen', 
	@HorarioApertura = '9:00',
    @HorarioCierre = '20:00',
    @ClienteId = 1, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE DE ELIMINAR TIENDAS
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_eliminar_tienda]
    @TiendaId = 8,
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE DE AGREGAR DIRECCION DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_agregar_direccion] 
    @CP = '42900', 
    @ubicacion = 'Ubicacion de Prueba',
    @tipoVivienda = 'Vivienda de Prueba', 
    @municipio = 'Municipio de Prueba', 
    @estado = 'Estado de Prueba', 
    @ciudad = 'Ciudad de Prueba',
    @pais = 'Pais de Prueba', 
    @NoExterior = '123', 
    @Telefono = '555123456788', 
    @Referencia = 'entre cale 1 y 2', 
    @TiendaId = 1,
	@tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;


-----------STORE PROCEDURE DE EDITAR DIRECCION DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_editar_direccion]
    @DireccionId = 1,
    @CP = '12345',
    @ubicacion = 'Ubicacion nueva', 
    @tipoVivienda = 'Vivienda nueva',
    @municipio = 'Nuevo Municipio', 
    @estado = 'Nuevo Estado', 
    @ciudad = 'Ciudad nueva',
    @pais = 'Pais nueva', 
    @NoExterior = '123', 
    @Telefono = '5551234567', 
    @Referencia = 'Al lado del supermercado',
	@tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;
   


-----------STORE PROCEDURE DE ELIMINAR DIRECCION DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_eliminar_direccion] 
    @DireccionId = 1,
	@tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;


-----------STORE PROCEDURE DE AGREGAR ESTILO DE CORTES DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_agregar_estilo]  
    @Nombre = 'Moicano', 
    @Imagen = 'nueva_imagen.jpg',
    @Descripcion = 'Es un corte unico que hacemos al estilo', 
    @TiendaId = 1,
	@tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE DE EDITAR ESTILO DE CORTES DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_editar_estilo]  
    @Nombre = 'Corte nuevo', 
    @Imagen = 'nueva_imagen2.jpg',
    @Descripcion = 'nueva descripcion', 
    @EstiloId = 1,
	@tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE DE ELIMINAR ESTILO DE CORTES DE LA TIENDA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_eliminar_estilo] 
    @EstiloId = 2,
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE DE OBTENER DIRECCIONES DE LAS TIENDA

EXEC [dbo].[sp_obtener_direcciones_por_tienda] 
    @TiendaID = 1 

-----------STORE PROCEDURE DE OBTENER TIENDAS POR ID CLIENTE

EXEC [dbo].[sp_obtener_tiendas_por_cliente] 
    @ClienteID = 1 

-----------STORE PROCEDURE DE OBTENER ESTILOS DE LAS TIENDA

EXEC [dbo].[sp_obtener_estilos_por_tienda] 
    @TiendaID = 1

-----------STORE PROCEDURE DE OBTENER TIENDA POR ID

EXEC [dbo].[sp_obtener_tienda_por_id] 
    @TiendaID = 1

-----------STORE PROCEDURE DE EDITAR DATOS DEL CLIENTE

DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);


EXEC [dbo].[sp_editar_cliente]
    @clienteId = 1,                                
    @nombre = 'Emil',                             
    @apellidoPaterno = 'Hernandez',                
    @apellidoMaterno = 'Avila',                    
	@correo = 'emil.hdz@gmail.com', 
    @estado = 'Inactivo', 
    @tipoError = @tipoError OUTPUT,                
    @mensaje = @mensaje OUTPUT;                  

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE DE EDITAR DATOS DEL EMPLEADO

DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);


EXEC [dbo].[sp_editar_empleado]
    @clienteId = 1,                                
    @nombre = 'Emil',                             
    @apellidoPaterno = 'Hernandez',                
    @apellidoMaterno = 'AvilEZ',                    
	@correo = 'emil.hdz@gmail.com', 
    @estado = 'Inactivo',
    @rolId = 3,
	@direccionId = 1, 
    @tipoError = @tipoError OUTPUT,                
    @mensaje = @mensaje OUTPUT;                  

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE PARA CAMBIAR CONTRASENA DEL CLIENTE

DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_cambiar_contrasena] 
    @correo = 'emil.hdz@gmail.com',             
    @contrasenaActual = 'password123',           -- La contraseña actual del usuario
    @nuevaContrasena = 'NuevaContrasena456',      -- La nueva contraseña a establecer
    @tipoError = @tipoError OUTPUT,               
    @mensaje = @mensaje OUTPUT;                   

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE PARA AGENDAR CITA
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_agendar_cita]
    @clienteId = 1, 
	@empleadoId = 1,
    @tiendaId = 1, 
    @direccionId = 1, 
    @fechaCita = '2024-10-20', 
	@horaCita = '10:00:00', 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE PARA EDITAR CITA
DECLARE @tipoError INT, @mensaje VARCHAR(255);

EXEC [dbo].[sp_editar_cita]
    @citaId = 1, 
    @nuevaFechaCita = '2024-11-21 ', -- SOLO EL CLIENTE PUEDE MODIFICAR ESTE CAMPO
	@nuevahoraCita = '10:00', -- SOLO EL CLIENTE PUEDE MODIFICAR ESTE CAMPO
    @nuevoEstado = 'Pendiende', -----------EL ADMINISTRADOR SOLO PODRA MODIFICAR ESTE CAMPO A 'CONFIRMADA Y CANCELADA'. EL CLIENTE SOLO A 'CANCELADA'
    @nuevaDireccionId = 1, -- SOLO EL CLIENTE PUEDE MODIFICAR ESTE CAMPO
	@nuevoempleadoId = 2,
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;


SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE PARA CONSULTAR LAS CITAS DEL CLIENTE
EXEC [dbo].[sp_consultar_citas_por_usuario]
   @clienteId = 1;

-----------STORE PROCEDURE PARA CONSULTAR CITAS AGENDADAS POR TIENDA
EXEC [dbo].[sp_consultar_citas_por_tienda]

@tiendaId = 1;

-----------STORE PROCEDURE PARA CONSULTAR HORARIOS DISPONIBLES PARA LAS CITAS
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_obtener_horarios_disponibles] 
    @tiendaId = 2, 
    @direccionId = 1, 
    @fechaSeleccionada = '2024-11-21', 
    @empleadoId = 2,
    @duracionMinutos = 60, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE PARA AGREGAR FAVORITOS
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC [dbo].[sp_agregar_tienda_favorita]
    @clienteId = 1, 
	@tiendaId = 1,
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE PARA ELIMINAR FAVORITOS

-- Declaración de variables de salida para capturar los mensajes y tipo de error
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

-- Ejecución del procedimiento almacenado
EXEC [dbo].[sp_eliminar_tienda_favorita] 
    @favoritoId = 1, -- ID del favorito a eliminar
    @tipoError = @tipoError OUTPUT,
    @mensaje = @mensaje OUTPUT;

-- Ver el resultado del mensaje
SELECT @tipoError AS TipoError, @mensaje AS Mensaje;


-----------STORE PROCEDURE PARA INSERTAR UN NUEVO TOKEN DE RESTABLECIMIENTO DE CONTRASENA 
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);
DECLARE @token UNIQUEIDENTIFIER = NEWID();
DECLARE @expiration DATETIME = DATEADD(HOUR, 1, GETUTCDATE()); -- Expiración en 1 hora UTC

EXEC sp_Insert_password_reset_token 
    @clienteId = 1, 
    @token = @token, 
    @expiration = @expiration, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;


-----------STORE PROCEDURE PARA CONSULTAR LOS DATOS DEL USUARIO POR CORREO 

DECLARE @correo NVARCHAR(255) = 'emil.hdz@gmail.com';

EXEC sp_obtener_datos_por_correo 
    @correo = @correo;

-----------STORE PROCEDURE PARA CONSULTAR LOS DATOS DEL USUARIO POR TOKEN 

DECLARE @Token UNIQUEIDENTIFIER = '432688d6-d4cc-4620-8acc-2cf42f251c88';
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC sp_obtener_datos_por_token 
    @Token = @Token, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;

-----------STORE PROCEDURE PARA ACTUALIZAR LA CONTRASENA DEL USUARIO  

DECLARE @correo VARCHAR(100) = 'emil.hdz@gmail.com';
DECLARE @nuevaContrasena VARCHAR(255) = 'Emil-1234';
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC sp_actualizar_contrasena_sin_actual 
    @correo = @correo, 
    @nuevaContrasena = @nuevaContrasena, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS tipoError, @mensaje AS mensaje;


-----------STORE PROCEDURE PARA CONTAR CITAS POR ESTADO PARA UN CLIENTE ESPECÍFICO
DECLARE @tipoError INT, @mensaje VARCHAR(255);

EXEC sp_ContarCitasPorEstadoCliente 
    @clienteId = 1, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;


-----------STORE PROCEDURE PARA CONTAR CALIFICACION POR UNA TIENDA ESPECÍFICO

DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC sp_ConsultarCalificacionesPorTienda 
    @TiendaId = 1, 
    @tipoError = @tipoError OUTPUT, 
    @mensaje = @mensaje OUTPUT;

SELECT @tipoError AS TipoError, @mensaje AS Mensaje;