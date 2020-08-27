CREATE TABLE [cp].[ReportTemplate] (
    [TemplateId]   INT              IDENTITY (1, 1) NOT NULL,
    [TemplateName] NVARCHAR (50)    NOT NULL,
    [AccountUid]   UNIQUEIDENTIFIER NOT NULL,
    [ReportId]     SMALLINT         CONSTRAINT [DF_ReportTemplate_ReportId] DEFAULT ((1)) NOT NULL,
    [SettingsJson] NVARCHAR (4000)  NOT NULL,
    [CreatedAt]    DATETIME         CONSTRAINT [DF_ReportTemplate_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]    DATETIME         CONSTRAINT [DF_ReportTemplate_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [DeletedAt]    DATETIME         NULL,
    [CreatedBy]    UNIQUEIDENTIFIER NOT NULL,
    [UpdatedBy]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_cpReportTemplate] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_cpReportTemplate_AccountUid_ReportId]
    ON [cp].[ReportTemplate]([AccountUid] ASC, [ReportId] ASC);

