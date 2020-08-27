CREATE TABLE [ms].[SubAccount] (
    [SubAccountUid]            INT              NOT NULL,
    [SubAccountId]             VARCHAR (50)     NOT NULL,
    [AccountUid]               UNIQUEIDENTIFIER NOT NULL,
    [Active]                   BIT              NOT NULL,
    [CreatedAt]                DATETIME2 (2)    CONSTRAINT [DF_SubAccount_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]                DATETIME2 (2)    CONSTRAINT [DF_SubAccount_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [PriceNotifiedAt]          DATETIME2 (2)    NULL,
    [Product_SMS]              BIT              CONSTRAINT [DF_SubAccount_Product_SMS] DEFAULT ((0)) NOT NULL,
    [Product_CA]               BIT              CONSTRAINT [DF_SubAccount_Product_CA] DEFAULT ((0)) NOT NULL,
    [Product_VO]               BIT              CONSTRAINT [DF_SubAccount_Product_VO] DEFAULT ((0)) NOT NULL,
    [SF_SMS_Usage_ProductCode] VARCHAR (20)     NULL,
    [SF_SMS_Usage_AssetId]     VARCHAR (255)    NULL,
    CONSTRAINT [PK_SubAccount] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC),
    CONSTRAINT [FK_SubAccount_Account] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [UIX_SubAccount_SubAccountId] UNIQUE NONCLUSTERED ([SubAccountId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SubAccount_AccountUid]
    ON [ms].[SubAccount]([AccountUid] ASC);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2019-09-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[SubAccount_DataChanged]
   ON  [ms].[SubAccount]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF NOT UPDATE(UpdatedAt)
		UPDATE sa
		SET UpdatedAt = SYSUTCDATETIME()
		FROM ms.SubAccount sa
			INNER JOIN inserted AS i ON sa.SubAccountUid = i.SubAccountUid

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.SubAccount'
END
