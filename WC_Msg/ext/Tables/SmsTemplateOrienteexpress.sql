CREATE TABLE [ext].[SmsTemplateOrienteexpress] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateOrienteexpress] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateOrienteexpress_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

