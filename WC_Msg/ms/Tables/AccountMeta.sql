CREATE TABLE [ms].[AccountMeta] (
    [AccountId]            VARCHAR (50)     NOT NULL,
    [CustomerType]         CHAR (1)         NOT NULL,
    [CompanyEntity]        VARCHAR (10)     CONSTRAINT [DF_AccountMeta_CompanyEntity] DEFAULT ('WSG') NOT NULL,
    [BillingMode]          VARCHAR (10)     CONSTRAINT [DF_AccountMeta_BillingMode] DEFAULT ('PREPAID') NOT NULL,
    [Manager]              VARCHAR (50)     NULL,
    [ManagerId]            SMALLINT         NULL,
    [MainContactEmail]     VARCHAR (50)     NULL,
    [EmergencyContact1]    VARCHAR (250)    NULL,
    [EmergencyContact2]    VARCHAR (250)    NULL,
    [CustomerCategory]     VARCHAR (5)      NULL,
    [Currency]             CHAR (3)         CONSTRAINT [DF_AccountMeta_Currency] DEFAULT ('EUR') NOT NULL,
    [ConnectionType]       VARCHAR (4)      NULL,
    [UsesWebsender]        BIT              CONSTRAINT [DF_AccountMeta_UsesWebsender] DEFAULT ((1)) NULL,
    [TrafficType]          VARCHAR (20)     NULL,
    [VPN]                  BIT              NULL,
    [OnboardingStatus]     VARCHAR (20)     NULL,
    [CompanySize]          CHAR (1)         NULL,
    [MainContact]          NVARCHAR (100)   NULL,
    [UpdatedBy]            UNIQUEIDENTIFIER NULL,
    [UpdatedAt]            DATETIME2 (2)    CONSTRAINT [DF_AccountMeta_UpdatedAt] DEFAULT (sysutcdatetime()) NULL,
    [SalesforceCustomerId] VARCHAR (20)     NULL,
    [EntityCountryISO]     AS               ([CompanyEntity]),
    [MapUpdatedBy]         SMALLINT         NULL,
    CONSTRAINT [PK_AccountMeta] PRIMARY KEY CLUSTERED ([AccountId] ASC),
    CONSTRAINT [CK_AccountMeta_BillingMode] CHECK ([BillingMode]='NOPAY' OR [BillingMode]='PREPAID' OR [BillingMode]='POSTPAID'),
    CONSTRAINT [CK_AccountMeta_CompanySize] CHECK ([CompanySize]='E' OR [CompanySize]='M' OR [CompanySize]='S'),
    CONSTRAINT [CK_AccountMeta_ManagerId] CHECK ([CustomerType]='L' OR [CustomerType]='I' OR ([CustomerType]='W' OR [CustomerType]='E') AND [ManagerId] IS NOT NULL),
    CONSTRAINT [FK_AccountMeta_AccountManager] FOREIGN KEY ([ManagerId]) REFERENCES [ms].[AccountManager] ([ManagerId]),
    CONSTRAINT [FK_AccountMeta_Currency] FOREIGN KEY ([Currency]) REFERENCES [mno].[Currency] ([Currency]),
    CONSTRAINT [FK_AccountMeta_DimCompanyEntity] FOREIGN KEY ([CompanyEntity]) REFERENCES [ms].[DimCompanyEntity] ([CompanyEntity]),
    CONSTRAINT [FK_AccountMeta_MapUpdatedBy] FOREIGN KEY ([MapUpdatedBy]) REFERENCES [map].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [IX_AccountMeta_CustomerType]
    ON [ms].[AccountMeta]([CustomerType] ASC);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[AccountMeta_DataChanged]
   ON  ms.AccountMeta
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AccountMeta'
END

GO
-- =============================================
-- Author:      Rebecca
-- Create date: 2019-01-25
-- =============================================

CREATE TRIGGER [ms].[AccountMeta_Update] ON ms.AccountMeta
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @PostpaidAccount TABLE (
		AccountId VARCHAR(50),
		AccountUid UNIQUEIDENTIFIER
	);

	IF UPDATE(BillingMode) --indicates only that BillingMode is in the columns in the sql
		IF EXISTS (SELECT 1 FROM deleted) -- update ops AND BillingMode different
			INSERT INTO @PostpaidAccount (AccountId, AccountUid)
			SELECT a.AccountId, a.AccountUid
			FROM inserted i
				INNER JOIN deleted d ON i.AccountId = d.AccountId
				INNER JOIN cp.Account a ON a.AccountId = i.AccountId
			WHERE i.BillingMode = 'POSTPAID'
				AND i.BillingMode <> d.BillingMode ;
		ELSE -- insert
			INSERT INTO @PostpaidAccount (AccountId, AccountUid)
			SELECT a.AccountId, a.AccountUid
			FROM inserted i
				INNER JOIN cp.Account a ON a.AccountId = i.AccountId
			WHERE i.BillingMode = 'POSTPAID' ;

	-- actions if Account switched to POSTPAID
	IF EXISTS (SELECT 1 FROM @PostpaidAccount)
	BEGIN
		-- remove Offer of FreeCredits to account
		UPDATE cp.Account
		SET FreeCreditsOffer = 0
		WHERE AccountUid IN (SELECT AccountUid FROM @PostpaidAccount) ;

		-- remove existing trial mode, if it is activate
		DELETE FROM w
		FROM 
			@PostpaidAccount t
			INNER JOIN ms.MsisdnWhitelist w ON w.AccountUid = t.AccountUid

		-- suspend auto payment
		UPDATE cp.BillingAutoTopup
		SET SuspendCheckUntil = '3000/01/01'
		WHERE AccountUid IN (SELECT AccountUid FROM @PostpaidAccount)
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'5C503E21-22C6-81FA-620B-F369B8EC38D1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountMeta', @level2type = N'COLUMN', @level2name = N'MainContactEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountMeta', @level2type = N'COLUMN', @level2name = N'MainContactEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'989ADC05-3F3F-0588-A635-F475B994915B', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountMeta', @level2type = N'COLUMN', @level2name = N'MainContactEmail';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential - GDPR', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AccountMeta', @level2type = N'COLUMN', @level2name = N'MainContactEmail';

