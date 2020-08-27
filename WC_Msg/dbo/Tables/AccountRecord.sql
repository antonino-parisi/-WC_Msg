CREATE TABLE [dbo].[AccountRecord] (
    [Date]      DATETIME         NOT NULL,
    [AccountId] NVARCHAR (50)    NOT NULL,
    [Record]    NVARCHAR (250)   NULL,
    [value]     DECIMAL (18, 5)  NOT NULL,
    [UpdatedBy] UNIQUEIDENTIFIER NULL,
    [UpdatedAt] DATETIME2 (2)    CONSTRAINT [DF_AccountRecord_UpdatedAt] DEFAULT (sysutcdatetime()) NULL,
    [Currency]  CHAR (3)         CONSTRAINT [DF_AccountRecord_Currency] DEFAULT ('EUR') NOT NULL,
    CONSTRAINT [PK_AccountRecord] PRIMARY KEY CLUSTERED ([Date] ASC, [AccountId] ASC),
    CONSTRAINT [FK_AccountRecord_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [cp].[User] ([UserId])
);

