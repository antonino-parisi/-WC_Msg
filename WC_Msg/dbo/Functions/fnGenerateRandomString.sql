-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-11-13
-- NOTES: currently it's a very dummy implementation. For real random string or passwords, better to rewrite function
-- =============================================
-- SELECT dbo.fnGenerateRandomString(30)
CREATE FUNCTION [dbo].[fnGenerateRandomString]
(
	@Length as int
)
RETURNS varchar(30)
AS
BEGIN
	
	DECLARE @Result varchar(30)

	IF (@Length > 30) SET @Length = 30

	DECLARE @new_id VARCHAR(200)
	SELECT @new_id = REPLACE(new_id, '-','') FROM dbo.vwNewID	
	--delete view dbo.vwNewID if line above will be removed

	SELECT @Result = CAST((ABS(CHECKSUM(@new_id))%10) AS VARCHAR(1)) + 
			CHAR(ASCII('a')+(ABS(CHECKSUM(@new_id))%25)) +
			CHAR(ASCII('A')+(ABS(CHECKSUM(@new_id))%25)) + LEFT(@new_id, @Length-3)

	-- Return the result of the function
	RETURN @Result

END


