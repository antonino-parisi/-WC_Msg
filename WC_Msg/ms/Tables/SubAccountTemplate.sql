CREATE TABLE [ms].[SubAccountTemplate] (
    [SubAccountTemplateId] VARCHAR (50)     NOT NULL,
    [AccountUid]           UNIQUEIDENTIFIER NULL,
    [Product_SMS]          BIT              CONSTRAINT [DF_SubAccountTemplate_ProductSMS] DEFAULT ((0)) NOT NULL,
    [Product_CA]           BIT              CONSTRAINT [DF_SubAccountTemplate_ProductCA] DEFAULT ((0)) NOT NULL,
    [SMS_CustomerGroupId]  INT              NULL,
    [CA_PricingPlanId]     SMALLINT         NULL,
    CONSTRAINT [PK_SubAccountTemplate] PRIMARY KEY CLUSTERED ([SubAccountTemplateId] ASC)
);

