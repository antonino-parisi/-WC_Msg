CREATE TABLE [ms].[FeatureFilter_PriceOnDelivery] (
    [FilterId]         INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]       UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid]    INT              NULL,
    [Country]          CHAR (2)         NOT NULL,
    [OperatorId]       INT              NULL,
    [Priority]         INT              NOT NULL,
    [Enabled]          BIT              CONSTRAINT [DF_FeatureFilter_PriceOnDelivery_Enabled] DEFAULT ((1)) NULL,
    [ChargeOnDelivery] BIT              CONSTRAINT [DF_FeatureFilter_PriceOnDelivery_ChargeOnDelivery] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_PriceOnDelivery] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [FK_FeatureFilter_PriceOnDelivery_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_FeatureFilter_PriceOnDelivery_SubAccountUid] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [UIX_FeatureFilter_PriceOnDelivery] UNIQUE NONCLUSTERED ([AccountUid] ASC, [SubAccountUid] ASC, [Country] ASC, [OperatorId] ASC),
    CONSTRAINT [UIX_FeatureFilter_PriceOnDelivery_Priority] UNIQUE NONCLUSTERED ([AccountUid] ASC, [Priority] ASC)
);


GO

CREATE TRIGGER [ms].[FeatureFilter_PriceOnDelivery_DataChanged]
   ON [ms].[FeatureFilter_PriceOnDelivery]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_PriceOnDelivery'
END
