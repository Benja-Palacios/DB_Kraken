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
    @Estado = 'Estado de Prueba', 
    @Municipio = 'Municipio de Prueba', 
    @Colonia = 'Colonia de Prueba', 
    @Calle = 'Calle de Prueba', 
    @NoExterior = '123', 
    @Telefono = '555123456788', 
    @Referencia = 'entre cale 1 y 2', 
    @TiendaId = 8;

-----------STORE PROCEDURE DE EDITAR DIRECCION DE LA TIENDA
EXEC [dbo].[sp_editar_direccion]
    @DireccionId = 14,
    @CP = '12345', 
    @Estado = 'Nuevo Estado', 
    @Municipio = 'Nuevo Municipio', 
    @Colonia = 'Nueva Colonia', 
    @Calle = 'Nueva Calle', 
    @NoExterior = '123', 
    @Telefono = '5551234567', 
    @Referencia = 'Al lado del supermercado';

-----------STORE PROCEDURE DE EDITAR DIRECCION DE LA TIENDA
EXEC [dbo].[sp_eliminar_direccion] 
    @DireccionId = 14;
