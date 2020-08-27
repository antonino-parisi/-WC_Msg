CREATE TABLE [cp].[AccountFeatureToggle] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [Feature]   VARCHAR (50) NOT NULL,
    [AccountId] VARCHAR (50) NOT NULL,
    [Enabled]   BIT          CONSTRAINT [DF_AccountFeatureToggle_Enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AccountFeatureToggle] PRIMARY KEY CLUSTERED ([Feature] ASC, [AccountId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AccountFeatureToggle_AccountId]
    ON [cp].[AccountFeatureToggle]([AccountId] ASC);

