
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- SELECT cp.fnGetAccountUid('499250FE-E2E5-E611-813F-06B9B96CA965', 'AcmeCorp-0aA4C') as AccountUid
-- SELECT cp.fnGetAccountUid(NULL, 'AcmeCorp-0aA4C')
CREATE FUNCTION [cp].[fnGetAccountUid]
(
	@AccountUid UNIQUEIDENTIFIER,
	@AccountId VARCHAR(50)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN

	IF @AccountUid IS NULL
	BEGIN
		SELECT @AccountUid = AccountUid FROM cp.Account WITH (NOLOCK) WHERE AccountId = @AccountId
	END
		
	RETURN @AccountUid
END

