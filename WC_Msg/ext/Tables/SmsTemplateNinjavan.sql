CREATE TABLE [ext].[SmsTemplateNinjavan] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateNinjavan] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateNinjavan_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

