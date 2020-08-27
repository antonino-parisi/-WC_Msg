CREATE TABLE [ipm].[ChannelStatus] (
    [StatusId] CHAR (1)     NOT NULL,
    [Status]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_ChannelStatus] PRIMARY KEY CLUSTERED ([StatusId] ASC),
    CONSTRAINT [UX_ChannelStatus] UNIQUE NONCLUSTERED ([Status] ASC)
);

