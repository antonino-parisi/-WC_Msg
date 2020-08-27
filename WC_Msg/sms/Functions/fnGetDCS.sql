
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Description:	Transform Encoding to EncodingTypeId
-- =============================================
-- SELECT sms.fnGetDCS('ASCII', NULL) as DCS
CREATE FUNCTION [sms].[fnGetDCS]
(
	@DCS tinyint,
	@Encoding VARCHAR(50)
)
RETURNS tinyint
AS
BEGIN
	IF (@DCS IS NULL) 
		SET @DCS = 
			CASE @Encoding
				WHEN 'ASCII' THEN 0
				WHEN 'UNICODE' THEN 8
				ELSE 0
			END

	RETURN @DCS
END


