CREATE TABLE [rt].[SupplierOperatorConfig] (
    [ConfigId]             INT     IDENTITY (1, 1) NOT NULL,
    [ConnUid]              INT     NOT NULL,
    [OperatorId]           INT     NOT NULL,
    [ChargeOnDelivery]     BIT     CONSTRAINT [DF_SupplierOperatorConfig_ChargeOnDelivery] DEFAULT ((0)) NOT NULL,
    [DRExpirationInMin]    INT     NULL,
    [DRExpirationStatusId] TINYINT NULL,
    CONSTRAINT [PK_SupplierOperatorConfig] PRIMARY KEY CLUSTERED ([ConfigId] ASC),
    CONSTRAINT [UIX_SupplierOperatorConfig] UNIQUE NONCLUSTERED ([ConnUid] ASC, [OperatorId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-03-19
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [rt].[SupplierOperatorConfig_DataChanged]
   ON  [rt].[SupplierOperatorConfig]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'rt.SupplierOperatorConfig'
END
