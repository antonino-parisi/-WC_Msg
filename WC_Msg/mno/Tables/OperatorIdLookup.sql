CREATE TABLE [mno].[OperatorIdLookup] (
    [MCC]                 SMALLINT      NOT NULL,
    [MNC]                 SMALLINT      NOT NULL,
    [OperatorId]          INT           NOT NULL,
    [LastModifiedTimeUtc] SMALLDATETIME CONSTRAINT [DF_OperatorIdLookup_LastModifiedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_OperatorIdLookup] PRIMARY KEY CLUSTERED ([MCC] ASC, [MNC] ASC),
    CONSTRAINT [CK_mnoOperatorIdLookup_MCC] CHECK ([MCC]>=(0) AND [MCC]<=(999)),
    CONSTRAINT [CK_mnoOperatorIdLookup_MNC] CHECK ([MNC]>=(0) AND [MNC]<=(999)),
    CONSTRAINT [CK_mnoOperatorIdLookup_OperatorId] CHECK ([OperatorId]>=(0) AND [OperatorId]<=(999999))
);

