
-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-01
-- =============================================
-- SAMPLE:
-- SELECT [dbo].[Base62Decode]('img') 172154
CREATE FUNCTION [dbo].[Base62Decode](@a_value_to_convert [char](12))
RETURNS [decimal](36, 0) WITH EXECUTE AS CALLER
AS 
BEGIN

	DECLARE @v_iterator int;  
	DECLARE @v_length int;  
	DECLARE @v_temp_char VARCHAR(1);  
	DECLARE @v_temp_int bigint;  
	DECLARE @v_return_value decimal(38) = 0;  
	DECLARE @v_multiplier decimal(38) = 1;  
	DECLARE @v_temp_convert_val VARCHAR(256) = @a_value_to_convert;  

	DECLARE @c_base62_digits VARCHAR(62) = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	--DECLARE @c_base62_digits VARCHAR(62) = '0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ'; 
  
	SET @v_length = len( @v_temp_convert_val );  
	SET @v_iterator = @v_length; 
  
	WHILE ( @v_iterator > 0 )   
	BEGIN
	-- The character being converted
	SET @v_temp_char = substring( @v_temp_convert_val, @v_iterator, 1 );  
	-- The index of the character being converted
	SET @v_temp_int = charindex( @v_temp_char collate  SQL_Latin1_General_CP1_CS_AS, @c_base62_digits collate  SQL_Latin1_General_CP1_CS_AS ) - 1;  
   
	SET @v_return_value = @v_return_value + ( @v_temp_int * @v_multiplier );  
	SET @v_multiplier = @v_multiplier * 62;  
	SET @v_iterator = @v_iterator - 1;  
   
	END
  
	RETURN @v_return_value; 

END