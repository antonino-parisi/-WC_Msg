CREATE TABLE [ms].[WebhookTokenCfg] (
    [CfgId]            INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]       UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid]    INT              NULL,
    [ResourceType]     VARCHAR (20)     NULL,
    [AuthUrl]          VARCHAR (255)    NOT NULL,
    [GrantType]        VARCHAR (20)     NOT NULL,
    [ClientId]         VARBINARY (300)  NULL,
    [ClientSecret]     VARBINARY (300)  NULL,
    [TokenFactoryType] VARCHAR (20)     NOT NULL,
    [TokenValiditySec] INT              NULL,
    CONSTRAINT [PK_WebhookTokenCfg] PRIMARY KEY CLUSTERED ([CfgId] ASC),
    CONSTRAINT [CHK_GrantType] CHECK ([GrantType]='RefreshToken' OR [GrantType]='ClientCredentials'),
    CONSTRAINT [CHK_ResourceType] CHECK ([ResourceType]='MSG' OR [ResourceType]='DR' OR [ResourceType]='EV' OR [ResourceType]='MO' OR [ResourceType] IS NULL),
    CONSTRAINT [CHK_TokenFactoryType] CHECK ([TokenFactoryType]='vcc' OR [TokenFactoryType]='bearer'),
    CONSTRAINT [FK_WebhookTokenCfg_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_WebhookTokenCfg_SubAccountUid] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [UIX_WebhookTokenCfgId] UNIQUE NONCLUSTERED ([AccountUid] ASC, [SubAccountUid] ASC, [ResourceType] ASC)
);


GO

CREATE TRIGGER [ms].[WebhookTokenCfg_DataChanged]
	ON [ms].[WebhookTokenCfg] AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.WebhookTokenCfg'
END
