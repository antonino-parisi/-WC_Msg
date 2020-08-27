CREATE TABLE [ext].[SmsTemplateRedmart] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    CONSTRAINT [PK_SmsTemplateRedmart] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateRedmart_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

