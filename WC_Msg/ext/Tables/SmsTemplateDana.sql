CREATE TABLE [ext].[SmsTemplateDana] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateDana] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateDana_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

