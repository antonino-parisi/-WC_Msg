CREATE TABLE [cp].[AccountWalletSnapshot] (
    [EventTime]      SMALLDATETIME    NOT NULL,
    [AccountUid]     UNIQUEIDENTIFIER NOT NULL,
    [Currency]       CHAR (3)         NOT NULL,
    [Balance]        DECIMAL (18, 6)  NOT NULL,
    [OverdraftLimit] DECIMAL (18, 6)  NOT NULL,
    CONSTRAINT [PK_AccountWalletSnapshot] PRIMARY KEY CLUSTERED ([AccountUid] ASC, [EventTime] ASC)
);

