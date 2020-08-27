CREATE TABLE [ext].[SmsTemplateLazada] (
    [TemplateId]       SMALLINT        IDENTITY (1, 1) NOT NULL,
    [Template]         NVARCHAR (450)  NOT NULL,
    [UseCase]          VARCHAR (150)   NULL,
    [TemplateOriginal] NVARCHAR (1000) NULL,
    CONSTRAINT [PK_LazadaSmsTemplate] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_LazadaSmsTemplate_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

