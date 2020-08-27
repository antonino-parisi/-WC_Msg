CREATE TABLE [ipm].[PricingPlanChannel] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [ChannelTypeId]    TINYINT         NOT NULL,
    [AccountId]        VARCHAR (50)    NULL,
    [SubAccountUid]    INT             NULL,
    [Country]          VARCHAR (2)     NULL,
    [Direction]        BIT             NOT NULL,
    [ContentTypeId]    TINYINT         NULL,
    [Priority]         INT             NOT NULL,
    [CostEUR]          DECIMAL (12, 6) NOT NULL,
    [CostContract]     DECIMAL (12, 6) NOT NULL,
    [ContractCurrency] CHAR (3)        NOT NULL,
    [UpdatedAt]        DATETIME2 (2)   CONSTRAINT [DF_PricingPlanChannel_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_PricingPlanChannel] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PricingPlanChannel_ChannelType] FOREIGN KEY ([ChannelTypeId]) REFERENCES [ipm].[ChannelType] ([ChannelTypeId])
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[PricingPlanChannel_DataChanged]
   ON  [ipm].[PricingPlanChannel]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.PricingPlanChannel'
END
