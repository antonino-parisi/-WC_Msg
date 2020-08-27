CREATE TABLE [cp].[CmContact] (
    [ContactId]  INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid] UNIQUEIDENTIFIER NOT NULL,
    [MSISDN]     BIGINT           NOT NULL,
    [Country]    CHAR (2)         NULL,
    [CreatedAt]  DATETIME         CONSTRAINT [DF_cpCmContact_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]  UNIQUEIDENTIFIER NULL,
    [DeletedAt]  DATETIME         NULL,
    [DeletedBy]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_cpCmContact] PRIMARY KEY CLUSTERED ([ContactId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_cpCmContact_Account_MSISDN]
    ON [cp].[CmContact]([AccountUid] ASC, [MSISDN] ASC)
    INCLUDE([DeletedAt]);


GO
CREATE NONCLUSTERED INDEX [IX_CmContact_AccountUid_DeletedAt]
    ON [cp].[CmContact]([AccountUid] ASC, [DeletedAt] ASC)
    INCLUDE([ContactId], [Country]) WHERE ([DeletedAt] IS NULL);

