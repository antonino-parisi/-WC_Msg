CREATE TABLE [ipm].[PricingPlan] (
    [PricingPlanId]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [PricingPlanName] VARCHAR (50)  NOT NULL,
    [CreatedAt]       DATETIME2 (2) CONSTRAINT [DF_PricingPlan_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_ipmPricingPlan] PRIMARY KEY CLUSTERED ([PricingPlanId] ASC)
);

