-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2018-12-04
-- =============================================
-- SELECT sms.fnSmsSegmentsV2 ('abcd', 0)
CREATE FUNCTION [sms].[fnSmsSegmentsV2]
(	
	@Body nvarchar(1600),
	@DCS tinyint
)
RETURNS TINYINT
AS
BEGIN

	DECLARE @BodyLength smallint
	DECLARE @Charset tinyint

	SELECT @Charset = CharacterSet FROM sms.DimDCS WHERE DCS = @DCS

	--SET @Body = REPLACE(@Body, ' ', '*'); 
	SET @BodyLength = LEN(REPLACE(@Body, ' ', '*')); -- workaround for trailing space in LEN()

	-- GSM7
	IF @Charset = 1
	BEGIN

		-- special chars in GSM7 counts as 2 bytes
		DECLARE @Char char(1), @SpecialCharList varchar(20) = '|^€{}[]~\' ;
		DECLARE @i tinyint = 1, @FoundChars smallint = 0 ;
		
		IF @Body LIKE '%[|\^€{}\[\]~\\]%' ESCAPE '\'
		BEGIN
			WHILE @i <= LEN(@SpecialCharList)
			BEGIN
				SET @Char = SUBSTRING(@SpecialCharList, @i, 1) ;
				SET @FoundChars = @FoundChars + LEN(@Body) - LEN(REPLACE(@Body, @Char, '')) ;
				SET @i += 1;
			END ;

			SET @BodyLength += @FoundChars
		END;

		RETURN IIF(@BodyLength <= 160, 1, CEILING(@BodyLength/CAST(153 as DECIMAL(5,1))))
	END
	-- 8BIT data
	ELSE IF @Charset = 2
		RETURN IIF(@BodyLength <= 140, 1, CEILING(@BodyLength/CAST(134 as DECIMAL(5,1))))
	-- UCS2
	ELSE IF @Charset = 3
		RETURN IIF(@BodyLength <= 70, 1, CEILING(@BodyLength/CAST(67 as DECIMAL(5,1))))


	-- Unexpected case
	RETURN 0;
END
