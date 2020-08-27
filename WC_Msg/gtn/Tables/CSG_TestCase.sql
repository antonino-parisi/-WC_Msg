CREATE TABLE [gtn].[CSG_TestCase] (
    [TestCase]                VARCHAR (50)    NOT NULL,
    [SMSTemplateID]           SMALLINT        NOT NULL,
    [SMSTemplateName]         NVARCHAR (50)   NOT NULL,
    [InterpretationRulesJson] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_CSG_TestCase] PRIMARY KEY CLUSTERED ([TestCase] ASC)
);

