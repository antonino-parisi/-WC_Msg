CREATE TABLE [ipm].[WhatsAppTemplateStatus] (
    [StatusId]         TINYINT        NOT NULL,
    [StatusCode]       VARCHAR (36)   NOT NULL,
    [UserFriendlyName] NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_WhatsAppTemplateStatus] PRIMARY KEY CLUSTERED ([StatusId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-08-20
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[WhatsAppTemplateStatus_DataChanged]
   ON  [ipm].[WhatsAppTemplateStatus]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WhatsAppTemplateStatus'
END
