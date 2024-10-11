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

-----------STORE PROCEDURE DE INICIO DE SESION

EXEC [dbo].[sp_iniciar_sesion]
    @correo = 'juan.perez@example.com',
    @contrasena = 'password123';

-----------STORE PROCEDURE DE AGREGAR TIENDAS

EXEC [dbo].[spAgregarTienda]
    @Nombre = 'NombreTienda',
    @Imagen = 'ruta/imagen.jpg',
    @ClienteId = 2;

-----------STORE PROCEDURE DE EDITAR TIENDAS
DECLARE @tipoError INT;
DECLARE @mensaje VARCHAR(255);

EXEC dbo.sp_editar_tienda 
    @TiendaId = 1, 
    @Nombre = 'Nombre de Tienda', 
    @Imagen = 'url_imagen', 
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
    @TiendaID = 3

-----------STORE PROCEDURE DE OBTENER TIENDA POR ID

EXEC [dbo].[sp_obtener_tienda_por_id] 
    @TiendaID = 3