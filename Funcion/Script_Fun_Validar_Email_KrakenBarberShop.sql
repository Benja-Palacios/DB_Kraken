CREATE FUNCTION dbo.fn_validar_correo (@correo VARCHAR(100))
RETURNS INT
AS
BEGIN
    -- Inicializa el valor de retorno como 0 (inv�lido)
    DECLARE @resultado INT = 0;

    -- Verifica el formato del correo electr�nico utilizando LIKE
    IF @correo LIKE '%_@__%.__%' 
       AND @correo NOT LIKE '%[^0-9a-zA-Z@._-]%'  -- Solo permite caracteres v�lidos
       AND LEN(@correo) > 5  -- Asegura que el correo no sea demasiado corto
       AND LEFT(@correo, 1) NOT LIKE '%[^0-9a-zA-Z]%'  -- No puede empezar con un car�cter no v�lido
    BEGIN
        SET @resultado = 1;  -- Correo v�lido
    END

    -- Devuelve el resultado
    RETURN @resultado;
END