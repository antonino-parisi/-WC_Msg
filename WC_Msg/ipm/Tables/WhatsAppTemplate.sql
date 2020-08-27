CREATE TABLE [ipm].[WhatsAppTemplate] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [ChannelId]    UNIQUEIDENTIFIER NOT NULL,
    [TemplateId]   BIGINT           NOT NULL,
    [TemplateName] NVARCHAR (200)   NOT NULL,
    [Language]     VARCHAR (5)      COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [Text]         NVARCHAR (2000)  NOT NULL,
    [CategoryId]   INT              NOT NULL,
    [StatusId]     TINYINT          NOT NULL,
    [CreatedAt]    DATETIME2 (2)    CONSTRAINT [DF_WhatsAppTemplate_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]    DATETIME2 (2)    CONSTRAINT [DF_WhatsAppTemplate_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Components]   NVARCHAR (4000)  NULL,
    CONSTRAINT [PK_WhatsAppTemplate] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WhatsAppTemplate_Channel] FOREIGN KEY ([ChannelId]) REFERENCES [ipm].[Channel] ([ChannelId]),
    CONSTRAINT [FK_WhatsAppTemplate_WhatsAppTemplateCategory] FOREIGN KEY ([CategoryId]) REFERENCES [ipm].[WhatsAppTemplateCategory] ([CategoryId]),
    CONSTRAINT [FK_WhatsAppTemplate_WhatsAppTemplateLanguage] FOREIGN KEY ([Language]) REFERENCES [ipm].[WhatsAppTemplateLanguage] ([LanguageCode]),
    CONSTRAINT [FK_WhatsAppTemplate_WhatsAppTemplateStatus] FOREIGN KEY ([StatusId]) REFERENCES [ipm].[WhatsAppTemplateStatus] ([StatusId])
);


GO
CREATE NONCLUSTERED INDEX [IX_WhatsAppTemplate_WhatsAppId]
    ON [ipm].[WhatsAppTemplate]([ChannelId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ipm_WhatsAppTemplate]
    ON [ipm].[WhatsAppTemplate]([ChannelId] ASC, [TemplateId] ASC, [Language] ASC);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-09-05
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[WhatsAppTemplate_DataChanged]
   ON  ipm.WhatsAppTemplate
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WhatsAppTemplate'
END
