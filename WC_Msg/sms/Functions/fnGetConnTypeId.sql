-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Description:	Transform ProtocolSource to ConnTypeId
-- =============================================
-- SELECT sms.fnGetConnTypeId('HTTP') as ConnTypeId
CREATE FUNCTION [sms].[fnGetConnTypeId]
(
	@ProtocolSource VARCHAR(4)
)
RETURNS tinyint
AS
BEGIN

	RETURN 
		CASE @ProtocolSource
			WHEN 'HTTP' THEN 1
			WHEN 'SMPP' THEN 2
			WHEN 'WSMX' THEN 3
			ELSE 99
		END
END
