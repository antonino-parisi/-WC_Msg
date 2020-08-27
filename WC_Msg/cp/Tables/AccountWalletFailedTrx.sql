CREATE TABLE [cp].[AccountWalletFailedTrx] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [EventTime]  DATETIME2 (2)    NOT NULL,
    [AccountUid] UNIQUEIDENTIFIER NULL,
    [Currency]   CHAR (3)         NULL,
    [Amount]     DECIMAL (19, 7)  NULL,
    [Host]       VARCHAR (128)    NULL,
    [Message]    VARCHAR (200)    NULL,
    CONSTRAINT [PK_AccountWalletFailedTrx] PRIMARY KEY CLUSTERED ([Id] ASC)
);

