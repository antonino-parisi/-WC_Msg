CREATE TABLE [dbo].[AccountCampaign] (
    [AccountId]       NVARCHAR (50)  NOT NULL,
    [CampaignSource]  NVARCHAR (MAX) NULL,
    [CampaignMedium]  NVARCHAR (MAX) NULL,
    [CampaignTerm]    NVARCHAR (MAX) NULL,
    [CampaignContent] NVARCHAR (MAX) NULL,
    [CampaigName]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AccountCampaign] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);

