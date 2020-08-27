-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-01
-- =============================================
-- SAMPLE:
-- SELECT [dbo].[Base62Encode](172154) 
CREATE FUNCTION [dbo].[Base62Encode](@a_number_to_convert [decimal](36, 0))
RETURNS [char](12) WITH EXECUTE AS CALLER
AS 
BEGIN

	DECLARE @v_modulo INTEGER;  
	DECLARE @v_temp_int decimal(38) = @a_number_to_convert;  
	DECLARE @v_temp_val VARCHAR(256) = '';  
	DECLARE @v_temp_char VARCHAR(1);    

	DECLARE @c_base62_digits VARCHAR(62) = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	--DECLARE @c_base62_digits VARCHAR(62) = '0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ'; 
   
	IF ( @a_number_to_convert = 0 )
	BEGIN
	SET @v_temp_val = '0';  
	END    
        
	WHILE ( @v_temp_int <> 0 )
	BEGIN
	SET @v_modulo = @v_temp_int % 62;  
	SET @v_temp_char = substring( @c_base62_digits, @v_modulo + 1, 1 );  
	SET @v_temp_val = @v_temp_char + @v_temp_val;   
	SET @v_temp_int = floor(@v_temp_int / 62);  
   
	END
    
	RETURN @v_temp_val;  

END
