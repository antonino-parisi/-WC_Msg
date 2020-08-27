CREATE TABLE [sms].[MonthlyActiveUsers] (
    [AccountUid]    UNIQUEIDENTIFIER NOT NULL,
    [Year]          INT              NOT NULL,
    [Month]         TINYINT          NOT NULL,
    [UsersEstimate] INT              CONSTRAINT [DF_MonthlyActiveUsers_UsersEstimate] DEFAULT ((0)) NOT NULL,
    [Users]         INT              CONSTRAINT [DF_MonthlyActiveUsers_Users] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2)    CONSTRAINT [DF_MonthlyActiveUsers_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [MonthlyActiveUsers_PK] PRIMARY KEY CLUSTERED ([AccountUid] ASC, [Year] ASC, [Month] ASC)
);

