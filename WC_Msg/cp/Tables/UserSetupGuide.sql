CREATE TABLE [cp].[UserSetupGuide] (
    [UserId] UNIQUEIDENTIFIER NOT NULL,
    [StepId] TINYINT          NOT NULL,
    [Passed] BIT              NOT NULL,
    CONSTRAINT [PK_UserSetupGuide] PRIMARY KEY CLUSTERED ([UserId] ASC, [StepId] ASC)
);

