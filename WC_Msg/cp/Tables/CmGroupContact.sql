CREATE TABLE [cp].[CmGroupContact] (
    [GroupId]   INT NOT NULL,
    [ContactId] INT NOT NULL,
    CONSTRAINT [PK_cpCmGroupContact] PRIMARY KEY CLUSTERED ([GroupId] ASC, [ContactId] ASC),
    CONSTRAINT [FK_cpCmGroupContact_cpCmContact] FOREIGN KEY ([ContactId]) REFERENCES [cp].[CmContact] ([ContactId]),
    CONSTRAINT [FK_cpCmGroupContact_cpCmGroup] FOREIGN KEY ([GroupId]) REFERENCES [cp].[CmGroup] ([GroupId])
);

