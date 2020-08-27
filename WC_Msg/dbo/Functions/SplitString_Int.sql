
CREATE FUNCTION [dbo].[SplitString_Int]
(
   @Input       NVARCHAR(MAX),
   @Delimiter  CHAR(1)
)
RETURNS @Output TABLE (Item int)
AS
BEGIN
	DECLARE @StartIndex INT, @EndIndex INT

	-- Add Delimiter to end of string
	SET @StartIndex = 1
	IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Delimiter
	BEGIN
		SET @Input = @Input + @Delimiter
	END
 
	-- Iterate
	WHILE CHARINDEX(@Delimiter, @Input) > 0
	BEGIN
		SET @EndIndex = CHARINDEX(@Delimiter, @Input)
           
		INSERT INTO @Output(Item)
		SELECT CAST(SUBSTRING(@Input, @StartIndex, @EndIndex - 1) as int)
           
		SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
	END
 
	RETURN
END


