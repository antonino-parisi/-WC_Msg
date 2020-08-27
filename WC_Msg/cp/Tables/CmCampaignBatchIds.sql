CREATE TABLE [cp].[CmCampaignBatchIds] (
    [CampaignId] INT              NOT NULL,
    [BatchId]    UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_cpCmCampaignBatchIds] PRIMARY KEY CLUSTERED ([CampaignId] ASC, [BatchId] ASC)
);

