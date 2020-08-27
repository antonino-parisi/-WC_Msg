CREATE TABLE [cp].[CmCampaign] (
    [CampaignId]               INT              IDENTITY (1, 1) NOT NULL,
    [CampaignStatusId]         TINYINT          NOT NULL,
    [AccountUid]               UNIQUEIDENTIFIER NOT NULL,
    [SubAccountId]             VARCHAR (50)     NOT NULL,
    [CampaignName]             NVARCHAR (100)   NOT NULL,
    [TemplateBody]             NVARCHAR (1600)  NOT NULL,
    [TemplateSenderId]         VARCHAR (20)     NOT NULL,
    [TemplateId]               INT              NULL,
    [CampaignType]             VARCHAR (6)      CONSTRAINT [DF_CmCampaign_CampaignType] DEFAULT ('basic') NOT NULL,
    [SmsTotal]                 INT              CONSTRAINT [DF_cpcmCampaign_SmsTotal] DEFAULT ((0)) NOT NULL,
    [SmsDelivered]             INT              CONSTRAINT [DF_cpcmCampaign_SmsDelivered] DEFAULT ((0)) NOT NULL,
    [SmsRejected]              INT              CONSTRAINT [DF_CmCampaign_SmsRejected] DEFAULT ((0)) NOT NULL,
    [SmsError]                 INT              CONSTRAINT [DF_cpcmCampaign_SmsError] DEFAULT ((0)) NOT NULL,
    [MsgClicked]               INT              NULL,
    [MsgResponded]             INT              NULL,
    [AvgClickTimeInSec]        INT              NULL,
    [AvgRespondTimeInSec]      INT              NULL,
    [ScheduledAt]              DATETIME2 (2)    CONSTRAINT [DF_cpcmCampaign_ScheduledAt ] DEFAULT (sysutcdatetime()) NOT NULL,
    [Price]                    DECIMAL (18, 6)  NULL,
    [PriceCurrency]            CHAR (3)         NULL,
    [CreatedAt]                DATETIME2 (2)    CONSTRAINT [DF_cpCmCampaign_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CreatedBy]                UNIQUEIDENTIFIER NOT NULL,
    [DeletedAt]                DATETIME2 (2)    NULL,
    [DeletedBy]                UNIQUEIDENTIFIER NULL,
    [SubAccountUid]            INT              NOT NULL,
    [MsgTotal]                 INT              CONSTRAINT [DF_CmCampaign_MsgTotal] DEFAULT ((0)) NOT NULL,
    [MsgDelivered]             INT              CONSTRAINT [DF_CmCampaign_MsgDelivered] DEFAULT ((0)) NOT NULL,
    [MsgRejected]              INT              CONSTRAINT [DF_CmCampaign_MsgRejected] DEFAULT ((0)) NOT NULL,
    [MsgError]                 INT              CONSTRAINT [DF_CmCampaign_MsgError] DEFAULT ((0)) NOT NULL,
    [ApprovalDeadlineAt]       SMALLDATETIME    NULL,
    [CampaignDetailsUrl]       VARCHAR (300)    NULL,
    [ApprovalDeadlineNotified] BIT              NULL,
    [RejectionMsg]             VARCHAR (500)    NULL,
    [ReviewedBy]               UNIQUEIDENTIFIER NULL,
    [ReviewedAt]               DATETIME2 (2)    NULL,
    [Product]                  VARCHAR (3)      CONSTRAINT [DF_CmCampaign_Product] DEFAULT ('SMS') NOT NULL,
    [ClientMessageId]          VARCHAR (50)     NULL,
    [ChannelType]              CHAR (2)         CONSTRAINT [DF_CmCampaign_ChannelType] DEFAULT ('SM') NOT NULL,
    [CostUSD]                  DECIMAL (12, 6)  NULL,
    [PriceUSD]                 DECIMAL (12, 6)  NULL,
    [CampaignMeta]             NVARCHAR (1024)  NULL,
    [CompletedAt]              DATETIME2 (2)    NULL,
    [MsgAccepted]              AS               (([MsgTotal]-[MsgRejected])-[MsgError]),
    [SmsAccepted]              AS               (([SmsTotal]-[SmsRejected])-[SmsError]),
    [SmsCharged]               INT              CONSTRAINT [DF_cpcmCampaign_SmsCharged] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_cpCmCampaign] PRIMARY KEY CLUSTERED ([CampaignId] ASC),
    CONSTRAINT [FK_CmCampaign_CmCampaignStatus] FOREIGN KEY ([CampaignStatusId]) REFERENCES [cp].[CmCampaignStatus] ([CampaignStatusId])
);


GO
CREATE NONCLUSTERED INDEX [UIX_cpCmCampaign_AccountUid]
    ON [cp].[CmCampaign]([AccountUid] ASC)
    INCLUDE([DeletedAt]);


GO
CREATE NONCLUSTERED INDEX [IX_cpCmCampaign_CreatedAt]
    ON [cp].[CmCampaign]([CreatedAt] ASC)
    INCLUDE([CampaignStatusId], [SubAccountUid]);

