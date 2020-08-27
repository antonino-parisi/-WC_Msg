CREATE TABLE [ext].[SmsTemplateReddoorz_ID] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateReddoorz_ID] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateReddoorz_ID_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

