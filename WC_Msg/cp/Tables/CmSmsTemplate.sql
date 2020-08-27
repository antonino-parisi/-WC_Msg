CREATE TABLE [cp].[CmSmsTemplate] (
    [TemplateId]    INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]    UNIQUEIDENTIFIER NOT NULL,
    [TemplateName]  NVARCHAR (50)    NOT NULL,
    [SenderId]      VARCHAR (16)     NOT NULL,
    [MessageBody]   NVARCHAR (1600)  NOT NULL,
    [LastUpdatedAt] DATETIME2 (2)    CONSTRAINT [DF_CmSmsTemplate_LastUpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_CmSmsTemplate] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_CmSmsTemplate_AccountUid_TemplateName]
    ON [cp].[CmSmsTemplate]([AccountUid] ASC, [TemplateName] ASC);

