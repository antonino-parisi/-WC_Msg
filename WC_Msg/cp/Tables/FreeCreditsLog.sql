CREATE TABLE [cp].[FreeCreditsLog] (
    [MSISDN]     BIGINT           NOT NULL,
    [AccountUid] UNIQUEIDENTIFIER NOT NULL,
    [UserId]     UNIQUEIDENTIFIER NOT NULL,
    [Amount]     DECIMAL (19, 7)  NOT NULL,
    [Currency]   CHAR (3)         CONSTRAINT [DF_FreeCreditsLog_Currency] DEFAULT ('EUR') NOT NULL,
    [CreatedAt]  DATETIME         CONSTRAINT [DF_FreeCreditsLog_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_FreeCreditsLog] PRIMARY KEY CLUSTERED ([MSISDN] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'FreeCreditsLog', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Financial', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'FreeCreditsLog', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'FreeCreditsLog', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'FreeCreditsLog', @level2type = N'COLUMN', @level2name = N'Amount';

