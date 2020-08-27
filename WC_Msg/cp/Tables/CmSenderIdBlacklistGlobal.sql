CREATE TABLE [cp].[CmSenderIdBlacklistGlobal] (
    [SenderIdPattern]     NVARCHAR (50) NOT NULL,
    [SenderIdPatternFlag] VARCHAR (10)  NULL,
    CONSTRAINT [PK_cpCmSenderIdBlacklistGlobal] PRIMARY KEY CLUSTERED ([SenderIdPattern] ASC)
);

