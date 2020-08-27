-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-18
-- Description:	Get SenderID masking rules from SenderMaskingRules for OperatorId + RouteId
-- =============================================
--	Example
--		EXEC optimus.SenderMaskingRules_GetByOperatorRoute @OperatorId = 525001, @RouteId = 'Test page'
--		EXEC optimus.SenderMaskingRules_GetByOperatorRoute @OperatorId = 525001, @RouteId = 'Test page', @SubAccountId = 'raymond_cnt'
--
CREATE PROCEDURE [optimus].[SenderMaskingRules_GetByOperatorRoute]
	@OperatorId int,
	@RouteId varchar(50),
	@SubAccountId varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @OperatorId int = 515002
	--DECLARE @RouteId varchar(50) = 'PLDT_DIR'
	--DECLARE @SubAccountId varchar(50) = 'zapOTP'

	-- get Country
	DECLARE @Country char(2)
	SELECT @Country = CountryISO2alpha FROM mno.Operator WHERE OperatorId = @OperatorId

	-- get AccountId
	DECLARE @AccountId varchar(50)
	SELECT @AccountId = AccountId FROM dbo.Account WHERE SubAccountId = @SubAccountId

	SELECT
		r.RuleId, 
		IIF(AccountId IS NOT NULL, @SubAccountId, r.SubAccountId) AS SubAccountId, 
		r.OriginalSenderId AS OriginalSenderIdPattern, 
		r.Priority, 
		r.NewSenderId, 
		r.NewSenderPoolId
	FROM optimus.SenderMaskingRules r
	WHERE r.Country = @Country AND RouteId = @RouteId
		AND (OperatorId = @OperatorId OR OperatorId IS NULL)
		AND (NewSenderId IS NOT NULL OR NewSenderPoolId IS NOT NULL)
		AND (@SubAccountId IS NULL OR (
			@SubAccountId IS NOT NULL AND 
				(r.SubAccountId = @SubAccountId
				OR (r.SubAccountId IS NULL AND r.AccountId = @AccountId)
				OR (r.SubAccountId IS NULL AND r.AccountId IS NULL))))
		AND r.Deleted = 0 AND r.SenderIdFilterType = 'P' AND r.CustomerType IS NULL
	ORDER BY Priority DESC

END
