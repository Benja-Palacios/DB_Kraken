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

-- Mostrar los resultados de salida
SELECT @tipoError AS TipoError, @mensaje AS Mensaje;

-----------STORE PROCEDURE DE INICIO DE SESION

EXEC [dbo].[sp_iniciar_sesion]
    @correo = 'juan.perez@example.com',
    @contrasena = 'password123';

-----------STORE PROCEDURE DE AGREGAR TIENDAS

EXEC [dbo].[sp_agregar_tienda]
    @Nombre = 'NombreTienda',
    @Imagen = 'ruta/imagen.jpg',
    @ClienteId = 2;

-----------STORE PROCEDURE DE EDITAR TIENDAS

EXEC [dbo].[sp_editar_tienda]
    @TiendaId = 8, 
    @Nombre = 'Nueva Tienda', 
    @Imagen = 'nueva_imagen.jpg';

-----------STORE PROCEDURE DE ELIMINAR TIENDAS

EXEC [dbo].[sp_eliminar_tienda]
    @TiendaId = 8;

-----------STORE PROCEDURE DE AGREGAR DIRECCION DE LA TIENDA

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
    @TiendaId = 8;


-----------STORE PROCEDURE DE EDITAR DIRECCION DE LA TIENDA
EXEC [dbo].[sp_editar_direccion]
    @DireccionId = 14,
    @CP = '12345',
    @ubicacion = 'Ubicacion nueva', 
    @tipoVivienda = 'Vivienda nueva',
    @municipio = 'Nuevo Municipio', 
    @estado = 'Nuevo Estado', 
    @ciudad = 'Ciudad nueva',
    @pais = 'Pais nueva', 
    @NoExterior = '123', 
    @Telefono = '5551234567', 
    @Referencia = 'Al lado del supermercado';
   


-----------STORE PROCEDURE DE ELIMINAR DIRECCION DE LA TIENDA
EXEC [dbo].[sp_eliminar_direccion] 
    @DireccionId = 14;


-----------STORE PROCEDURE DE AGREGAR ESTILO DE CORTES DE LA TIENDA
EXEC [dbo].[sp_agregar_estilo]  
    @Nombre = 'Moicano', 
    @Imagen = 'nueva_imagen.jpg',
    @Descripcion = 'Es un corte unico que hacemos al estilo', 
    @TiendaId = 2;

-----------STORE PROCEDURE DE EDITAR ESTILO DE CORTES DE LA TIENDA
EXEC [dbo].[sp_editar_estilo]  
    @Nombre = 'Corte nuevo', 
    @Imagen = 'nueva_imagen2.jpg',
    @Descripcion = 'nueva descripcion', 
    @EstiloId = 2;

-----------STORE PROCEDURE DE ELIMINAR ESTILO DE CORTES DE LA TIENDA

EXEC [dbo].[sp_eliminar_estilo] 
     @EstiloId = 2;