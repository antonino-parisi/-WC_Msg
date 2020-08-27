CREATE TABLE [cp].[AccountSSOConfig] (
    [AccountUid]  UNIQUEIDENTIFIER NOT NULL,
    [SSO_Url]     VARBINARY (1000) NOT NULL,
    [Issuer]      VARBINARY (1000) NOT NULL,
    [Certificate] VARBINARY (MAX)  NOT NULL,
    [Metadata]    VARCHAR (1000)   NULL,
    [Enabled]     BIT              CONSTRAINT [DF_AccountSSOConfig_Enabled] DEFAULT ((1)) NOT NULL,
    [CreatedAt]   DATETIME2 (2)    CONSTRAINT [DF_AccountSSOConfig_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]   DATETIME2 (2)    CONSTRAINT [DF_AccountSSOConfig_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_AccountSSOConfig] PRIMARY KEY CLUSTERED ([AccountUid] ASC),
    CONSTRAINT [FK_AccountSSOConfig_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SSO configuration of accounts', @level0type = N'SCHEMA', @level0name = N'cp', @level1type = N'TABLE', @level1name = N'AccountSSOConfig';

