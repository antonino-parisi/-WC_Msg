CREATE TABLE [cp].[UserOnboarding] (
    [UserId]   UNIQUEIDENTIFIER NOT NULL,
    [Scenario] VARCHAR (10)     NOT NULL,
    [Passed]   BIT              NOT NULL,
    [LastStep] TINYINT          NULL,
    CONSTRAINT [PK_UserOnboarding] PRIMARY KEY CLUSTERED ([UserId] ASC, [Scenario] ASC)
);

