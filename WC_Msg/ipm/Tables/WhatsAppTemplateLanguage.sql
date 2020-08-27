CREATE TABLE [ipm].[WhatsAppTemplateLanguage] (
    [LanguageCode]     VARCHAR (5)    COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [UserFriendlyName] NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_WhatsAppTemplateLanguage] PRIMARY KEY CLUSTERED ([LanguageCode] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[WhatsAppTemplateLanguage_DataChanged]
   ON  [ipm].[WhatsAppTemplateLanguage]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WhatsAppTemplateLanguage'
END
