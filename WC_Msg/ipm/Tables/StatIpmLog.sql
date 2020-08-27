CREATE TABLE [ipm].[StatIpmLog] (
    [StatDate]      DATE     NOT NULL,
    [SubAccountUid] INT      NOT NULL,
    [Country]       CHAR (2) NULL,
    [ChannelUid]    INT      NOT NULL,
    [MsgDelivered]  INT      NULL,
    [MsgRead]       INT      NULL,
    [MsgIncoming]   INT      NULL,
    [MsgOutgoing]   INT      NULL,
    [MsgChargeable] INT      NULL,
    [LastUpdatedAt] DATETIME NULL,
    CONSTRAINT [PK_StatIpmLog] UNIQUE NONCLUSTERED ([StatDate] ASC, [SubAccountUid] ASC, [Country] ASC, [ChannelUid] ASC)
);

