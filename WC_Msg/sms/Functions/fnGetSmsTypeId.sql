-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Description:	Transform MessageType to SmsTypeId
-- =============================================
-- SELECT sms.fnGetSmsTypeId('MT') as SmsTypeId
CREATE FUNCTION [sms].[fnGetSmsTypeId]
(
	@MessageType VARCHAR(10)
)
RETURNS tinyint
AS
BEGIN
	RETURN
		CASE @MessageType
			WHEN 'MO' THEN 0
			WHEN 'MT' THEN 1
			ELSE 99
		END
END

