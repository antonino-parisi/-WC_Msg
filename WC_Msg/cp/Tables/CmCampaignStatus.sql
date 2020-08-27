CREATE TABLE [cp].[CmCampaignStatus] (
    [CampaignStatusId]   TINYINT      NOT NULL,
    [CampaignStatusName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_cpCmCampaignStatus] PRIMARY KEY CLUSTERED ([CampaignStatusId] ASC)
);

