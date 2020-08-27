CREATE TABLE [ms].[Survey] (
    [SurveyUid]               INT             IDENTITY (1, 1) NOT NULL,
    [SurveyId]                VARCHAR (50)    NOT NULL,
    [SurveyTitle]             NVARCHAR (100)  NULL,
    [SubAccountUid]           INT             NOT NULL,
    [Sid]                     VARCHAR (50)    NOT NULL,
    [SurveyUrlSchema]         VARCHAR (5)     NULL,
    [SurveyDomainName]        VARCHAR (50)    NULL,
    [TemplateBody]            NVARCHAR (1600) NOT NULL,
    [CallbackTimeoutSec]      INT             CONSTRAINT [DF_Survey_CallbackTimeoutSec] DEFAULT ((0)) NOT NULL,
    [CallbackUrl]             NVARCHAR (450)  NULL,
    [Active]                  BIT             CONSTRAINT [DF_Survey_Active] DEFAULT ((1)) NOT NULL,
    [ResponseJsonForNoAnswer] NVARCHAR (1600) NULL,
    CONSTRAINT [PK_Survey] PRIMARY KEY CLUSTERED ([SurveyUid] ASC),
    CONSTRAINT [UC_Survey_SurveyId] UNIQUE NONCLUSTERED ([SurveyId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[Survey_DataChanged]
   ON  [ms].[Survey]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.Survey'
END
