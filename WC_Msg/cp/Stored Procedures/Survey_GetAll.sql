



-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-04-23
-- Description:	Get surveys for account
-- =============================================
-- exec [cp].[Survey_GetAll] @AccountUid = '619250FE-E2E5-E611-813F-06B9B96CA965'
-- =============================================
-- Updated by Raul Torrefiel
-- Updated at: 2020-05-14
-- Update Description:
--  * added SubAccountUid filter as optional parameter
--  * added Sid to selected columns
--  * added cp.fnSubAccount_GetByUser as another security layer
-- =============================================
CREATE PROCEDURE [cp].[Survey_GetAll]
	@AccountUid uniqueidentifier,
    @SubAccountUid int = NULL, -- optional filter
	@UserId uniqueidentifier = NULL		-- optional filter
AS
BEGIN

	SELECT
		  s.SurveyUid 
		 ,s.SurveyId
		 ,s.SurveyTitle
		 ,s.SubAccountUid
		 ,s.SurveyUrlSchema
		 ,s.SurveyDomainName
		 ,s.TemplateBody
		 ,s.CallbackUrl
         ,s.Sid
	FROM ms.Survey s
		-- Get accessible subaccounts only
		INNER JOIN cp.fnSubAccount_GetByUser (@AccountUid, @UserId, @SubAccountUid, NULL, NULL, NULL, NULL) su 
			ON su.SubAccountUid = s.SubAccountUid
	WHERE s.Active = 1

END
