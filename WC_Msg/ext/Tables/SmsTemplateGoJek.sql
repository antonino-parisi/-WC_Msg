CREATE TABLE [ext].[SmsTemplateGoJek] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateGoJek] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateGoJek_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

