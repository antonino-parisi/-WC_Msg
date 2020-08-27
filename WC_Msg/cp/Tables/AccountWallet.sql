CREATE TABLE [cp].[AccountWallet] (
    [AccountUid]     UNIQUEIDENTIFIER NOT NULL,
    [Currency]       CHAR (3)         NOT NULL,
    [Balance]        DECIMAL (19, 7)  NOT NULL,
    [OverdraftLimit] DECIMAL (19, 7)  CONSTRAINT [DF_AccountWallet_OverdraftLimit] DEFAULT ((0)) NOT NULL,
    [ValidBalance]   AS               (CONVERT([bit],case when [Balance]>=[OverdraftLimit] then (1) else (0) end)),
    CONSTRAINT [PK_AccountWallet] PRIMARY KEY CLUSTERED ([AccountUid] ASC)
);

