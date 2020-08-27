CREATE TABLE [ext].[SmsTemplateTix] (
    [TemplateId] SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (450) NOT NULL,
    [UseCase]    VARCHAR (150)  NULL,
    CONSTRAINT [PK_SmsTemplateTix] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [UIX_SmsTemplateTix_Template] UNIQUE NONCLUSTERED ([Template] ASC)
);

