CREATE TABLE [ms].[AccountBlackList] (
    [AccountId] VARCHAR (50)  NOT NULL,
    [Reason]    VARCHAR (250) NOT NULL,
    [AddedDate] DATETIME      CONSTRAINT [DF_AccountBlackList_AddedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AccountBlackList] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);

