CREATE TABLE [ms].[VirtualNumberRental] (
    [VnRentalId]         INT             IDENTITY (1, 1) NOT NULL,
    [VNId]               INT             NOT NULL,
    [RentalStart]        SMALLDATETIME   NOT NULL,
    [RentalEnd]          SMALLDATETIME   NOT NULL,
    [SubAccountUid]      INT             NOT NULL,
    [Currency]           CHAR (3)        NOT NULL,
    [MonthlyFee]         DECIMAL (18, 6) NOT NULL,
    [SetupFee]           DECIMAL (18, 6) NOT NULL,
    [Address]            NVARCHAR (500)  NULL,
    [Label]              NVARCHAR (50)   NULL,
    [ActivationStatus]   CHAR (1)        NULL,
    [BillingStatus]      CHAR (1)        NULL,
    [ProvisioningStatus] CHAR (1)        NULL,
    [UpdatedAt]          DATETIME2 (2)   CONSTRAINT [DF_VirtualNumberRental_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_VirtualNumberRental] PRIMARY KEY CLUSTERED ([VnRentalId] ASC),
    CONSTRAINT [CK_VirtualNumberRental_RentalEnd] CHECK ([RentalEnd]>[RentalStart]),
    CONSTRAINT [FK_VirtualNumberRental_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [FK_VirtualNumberRental_VirtualNumber] FOREIGN KEY ([VNId]) REFERENCES [ms].[VirtualNumber] ([VNId]),
    CONSTRAINT [UIX_VirtualNumberRental_VNId_RentalStart] UNIQUE NONCLUSTERED ([VNId] ASC, [RentalStart] ASC)
);


GO
CREATE TRIGGER ms.VirtualNumberRental_Constraints
	ON ms.VirtualNumberRental AFTER INSERT, UPDATE
AS
BEGIN

	--IF (ROWCOUNT_BIG() = 0) RETURN;

	-- check rental periods overall with other records
	IF EXISTS (
		SELECT 1 
		FROM ms.VirtualNumberRental v1
			INNER JOIN inserted v2 on v1.VNId = v2.VNId and v1.VnRentalId <> v2.VnRentalId
		WHERE NOT (v2.RentalStart >= v1.RentalEnd OR v2.RentalEnd <= v1.RentalStart)
	)
	BEGIN
		RAISERROR ('Rental period conflicts with existing records', 16, 1)
		ROLLBACK TRANSACTION
	END

END

GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-04-14
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[VirtualNumberRental_DataChanged]
   ON  [ms].[VirtualNumberRental]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.VirtualNumberRental'
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = '5c503e21-22c6-81fa-620b-f369b8ec38d1', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'VirtualNumberRental', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Contact Info', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'VirtualNumberRental', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '1866ca45-1973-4c28-9d12-04d407f147ad', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'VirtualNumberRental', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Public', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'VirtualNumberRental', @level2type = N'COLUMN', @level2name = N'Address';

