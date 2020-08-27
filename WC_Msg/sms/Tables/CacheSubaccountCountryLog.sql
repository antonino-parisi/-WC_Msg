CREATE TABLE [sms].[CacheSubaccountCountryLog] (
    [SubAccountUid] INT      NOT NULL,
    [Country]       CHAR (2) NOT NULL,
    [CreatedAt]     DATETIME CONSTRAINT [DF_CacheSubaccountCountryLog_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_CacheSubaccountCountryLog] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC, [Country] ASC)
);

