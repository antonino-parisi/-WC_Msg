CREATE TABLE [ipm].[WhatsAppTemplateCategory] (
    [CategoryId]       INT            NOT NULL,
    [CategoryName]     VARCHAR (50)   NOT NULL,
    [UserFriendlyName] NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_WhatsAppTemplateCategory] PRIMARY KEY CLUSTERED ([CategoryId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[WhatsAppTemplateCategory_DataChanged]
   ON  [ipm].[WhatsAppTemplateCategory]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WhatsAppTemplateCategory'
END
