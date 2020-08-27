/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW ms.vwSurvey
AS
	SELECT [SurveyUid]
		  ,[SurveyId]
		  ,[SurveyTitle]
		  ,s.[SubAccountUid]
		  ,a.SubAccountId, a.AccountId
		  ,[Sid]
		  ,[SurveyUrlSchema]
		  ,[SurveyDomainName]
		  ,[TemplateBody]
		  ,[CallbackTimeoutSec]
		  ,[CallbackUrl]
		  ,s.[Active]
		  ,[ResponseJsonForNoAnswer]
	  FROM [ms].[Survey] s
		INNER JOIN dbo.Account a on a.SubAccountUid = s.SubAccountUid
