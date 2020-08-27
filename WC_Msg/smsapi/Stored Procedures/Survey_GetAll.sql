-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-04-13
-- Description:	Get Survey settings
-- =============================================
CREATE PROCEDURE [smsapi].[Survey_GetAll]	
AS
BEGIN	
	SELECT 
		SurveyUid, 
		SurveyId, 
		SubAccountUid, 
		[Sid], 
		SurveyUrlSchema, 
		SurveyDomainName, 
		TemplateBody, 
		CallbackUrl, 
		CallbackTimeoutSec
	FROM ms.Survey
	WHERE Active = 1
END
