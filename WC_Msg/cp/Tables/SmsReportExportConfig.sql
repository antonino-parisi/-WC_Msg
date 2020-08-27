CREATE TABLE [cp].[SmsReportExportConfig] (
    [TemplateId]   INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]   UNIQUEIDENTIFIER NOT NULL,
    [Columns]      VARCHAR (1000)   NULL,
    [Emails]       VARCHAR (1000)   NOT NULL,
    [Frequency]    CHAR (1)         NOT NULL,
    [PreferredDay] TINYINT          NOT NULL,
    [CreatedBy]    UNIQUEIDENTIFIER NOT NULL,
    [CreatedAt]    DATETIME2 (2)    CONSTRAINT [DF_SmsReportExportConfig_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]    DATETIME2 (2)    CONSTRAINT [DF_SmsReportExportConfig_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [LastRunAt]    DATETIME2 (2)    NULL,
    [NextRunAt]    DATETIME2 (2)    NULL,
    CONSTRAINT [PK_SmsReportExportConfig] PRIMARY KEY CLUSTERED ([TemplateId] ASC),
    CONSTRAINT [CHK_SmsReportExportConfig_Frequency] CHECK ([Frequency]='W' OR [Frequency]='D' OR [Frequency]='M'),
    CONSTRAINT [CHK_SmsReportExportConfig_PreferredDay] CHECK ([PreferredDay]>=(0) AND [PreferredDay]<=(6)),
    CONSTRAINT [FK_SmsReportExportConfig_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_SmsReportExportConfig_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [cp].[User] ([UserId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SmsReportExportConfig_CreatedBy]
    ON [cp].[SmsReportExportConfig]([CreatedBy] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'SmsReportExportConfig', @level2type = N'COLUMN', @level2name = N'Emails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'SmsReportExportConfig', @level2type = N'COLUMN', @level2name = N'Emails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'SmsReportExportConfig', @level2type = N'COLUMN', @level2name = N'Emails';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'SmsReportExportConfig', @level2type = N'COLUMN', @level2name = N'Emails';

