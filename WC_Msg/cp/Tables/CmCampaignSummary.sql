CREATE TABLE [cp].[CmCampaignSummary] (
    [CampaignId]    INT             NOT NULL,
    [ChannelTypeId] TINYINT         NOT NULL,
    [MsgTotal]      INT             NOT NULL,
    [MsgDelivered]  INT             NOT NULL,
    [MsgRejected]   INT             NOT NULL,
    [MsgRead]       INT             NOT NULL,
    [MsgCharged]    INT             NOT NULL,
    [PriceCurrency] CHAR (3)        NOT NULL,
    [Price]         DECIMAL (19, 7) NOT NULL,
    [PriceUSD]      DECIMAL (12, 6) NOT NULL,
    [CostUSD]       DECIMAL (12, 6) NOT NULL,
    [MsgAccepted]   AS              ([MsgTotal]-[MsgRejected]),
    CONSTRAINT [PK_CmCampaignSummary] PRIMARY KEY CLUSTERED ([CampaignId] ASC, [ChannelTypeId] ASC),
    CONSTRAINT [FK_CmCampaignSummary_CampaignId] FOREIGN KEY ([CampaignId]) REFERENCES [cp].[CmCampaign] ([CampaignId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CmCampaignSummary]
    ON [cp].[CmCampaignSummary]([CampaignId] ASC, [ChannelTypeId] ASC);

