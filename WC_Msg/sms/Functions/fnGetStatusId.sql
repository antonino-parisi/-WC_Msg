-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-12-27
-- Description:	Transform Message Status to StatusId
-- =============================================
-- SELECT sms.fnGetStatusId('TRASHED') as StatusId
CREATE FUNCTION [sms].[fnGetStatusId]
(
	@Status VARCHAR(50)
)
RETURNS tinyint
AS
BEGIN
	DECLARE @SmsStatusId tinyint

	SELECT @SmsStatusId = StatusId FROM sms.DimSmsStatus WHERE StatusOld = @Status

	RETURN ISNULL(@SmsStatusId, 0)
END
