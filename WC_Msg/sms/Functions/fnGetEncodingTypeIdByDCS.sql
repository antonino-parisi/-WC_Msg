-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-11-23
-- Description:	Transform DCS to EncodingTypeId
-- =============================================
-- SELECT sms.fnGetEncodingTypeIdByDCS(8) as EncodingTypeId
CREATE FUNCTION [sms].[fnGetEncodingTypeIdByDCS]
(
	@DCS tinyint
)
RETURNS tinyint
AS
BEGIN

	-- fast search for 99.9% of traffic
	IF @DCS IN (0, 1, 2, 3, 240, 241) RETURN 0
	IF @DCS = 8 RETURN 10

	-- rest
	DECLARE @EncodingTypeId tinyint
	SELECT @EncodingTypeId = EncodingTypeId FROM sms.DimDCS (NOLOCK) WHERE DCS = @DCS
	RETURN ISNULL(@EncodingTypeId, 99)
END
