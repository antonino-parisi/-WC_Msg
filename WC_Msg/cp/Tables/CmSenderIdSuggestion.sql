CREATE TABLE [cp].[CmSenderIdSuggestion] (
    [AccountUid] UNIQUEIDENTIFIER NOT NULL,
    [SenderId]   VARCHAR (16)     NOT NULL,
    [LastUsedAt] SMALLDATETIME    NOT NULL,
    [Hits]       INT              CONSTRAINT [DF_CmSenderIdSuggestion_Hits] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CmSenderIdSuggestion] PRIMARY KEY CLUSTERED ([AccountUid] ASC, [SenderId] ASC)
);

