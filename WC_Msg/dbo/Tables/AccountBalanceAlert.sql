CREATE TABLE [dbo].[AccountBalanceAlert] (
    [AccountId]               NVARCHAR (50)   NOT NULL,
    [FirstBalanceAlert]       DECIMAL (14, 5) NULL,
    [FirstOverDraftAlert]     DECIMAL (14, 5) NULL,
    [CreatedBy]               NVARCHAR (250)  NULL,
    [CreatedDateTime]         DATETIME        NULL,
    [UpdatedBy]               NVARCHAR (250)  NULL,
    [UpdateDateTime]          DATETIME        NULL,
    [IsFirstBalanceAlerted]   BIT             NOT NULL,
    [IsBalanceZeroAlerted]    BIT             NOT NULL,
    [IsFirstOverdraftalerted] BIT             NOT NULL,
    [IsOverdraftZeroalerted]  BIT             NOT NULL,
    CONSTRAINT [PK_AccountBalanceAlert] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);

