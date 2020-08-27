CREATE TABLE [cp].[SubAccountStat] (
    [SubAccountUid] INT NOT NULL,
    [SmsVolume_1M]  INT CONSTRAINT [DF_Table_1_SmsCount_1M] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubAccountStat] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC)
);

