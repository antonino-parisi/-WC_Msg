CREATE TABLE [ipm].[ChannelType] (
    [ChannelTypeId]   TINYINT      NOT NULL,
    [ChannelType]     CHAR (2)     NOT NULL,
    [ChannelTypeName] VARCHAR (20) NOT NULL,
    [ChannelId]       AS           ([ChannelType]),
    [ChannelUid]      AS           ([ChannelTypeId]),
    CONSTRAINT [PK_ChannelType_ChannelTypeId] PRIMARY KEY CLUSTERED ([ChannelTypeId] ASC),
    CONSTRAINT [UIX_ChannelType_ChannelType] UNIQUE NONCLUSTERED ([ChannelType] ASC)
);

