CREATE TABLE [ipm].[PricingPlanSubscription] (
    [Id]                            INT             IDENTITY (1, 1) NOT NULL,
    [AccountId]                     VARCHAR (50)    NOT NULL,
    [ImmediateBilling]              BIT             CONSTRAINT [DF_PricingPlanSubscription_ImmediateBilling] DEFAULT ((0)) NOT NULL,
    [MonthlyActiveUsers]            INT             NOT NULL,
    [MonthlyActiveUsersFeeEUR]      DECIMAL (12, 6) NOT NULL,
    [ExtraUserFeeEUR]               DECIMAL (12, 6) NOT NULL,
    [OutboundMessageFeeEUR]         DECIMAL (12, 6) NOT NULL,
    [InboundMessageFeeEUR]          DECIMAL (12, 6) NOT NULL,
    [MonthlyActiveUsersFeeContract] DECIMAL (12, 6) NOT NULL,
    [ExtraUserFeeContract]          DECIMAL (12, 6) NOT NULL,
    [OutboundMessageFeeContract]    DECIMAL (12, 6) NOT NULL,
    [InboundMessageFeeContract]     DECIMAL (12, 6) NOT NULL,
    [ContractCurrency]              CHAR (3)        NOT NULL,
    [UpdatedAt]                     DATETIME2 (2)   NULL,
    CONSTRAINT [PK_PricingPlanSubscription] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[PricingPlanSubscription_DataChanged]
   ON  [ipm].[PricingPlanSubscription]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.PricingPlanSubscription'
END
