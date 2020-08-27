-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Description:	Transform Encoding to EncodingTypeId
-- =============================================
-- SELECT sms.fnGetEncodingTypeId('ASCII') as EncodingTypeId
CREATE FUNCTION [sms].[fnGetEncodingTypeId]
(
	@Encoding VARCHAR(50)
)
RETURNS tinyint
AS
BEGIN
	RETURN 
		CASE @Encoding
			WHEN 'ASCII' THEN 0
			WHEN 'UNICODE' THEN 10
			ELSE 99
		END
END

