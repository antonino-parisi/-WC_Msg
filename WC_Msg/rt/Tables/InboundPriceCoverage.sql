CREATE TABLE [rt].[InboundPriceCoverage] (
    [PriceCoverageId]  INT             IDENTITY (1, 1) NOT NULL,
    [SubaccountUid]    INT             NOT NULL,
    [VNType]           CHAR (1)        NOT NULL,
    [VNCountry]        CHAR (2)        NOT NULL,
    [MSISDNCountry]    CHAR (2)        NULL,
    [MSISDNOperatorId] INT             NULL,
    [BillingStart]     SMALLDATETIME   CONSTRAINT [DF_InboundPricing_StartPeriod] DEFAULT (sysutcdatetime()) NOT NULL,
    [BillingEnd]       SMALLDATETIME   NOT NULL,
    [Currency]         CHAR (3)        NOT NULL,
    [PricePerSms]      DECIMAL (18, 6) NOT NULL,
    [UpdatedAt]        DATETIME2 (2)   CONSTRAINT [DF_InboundPriceCoverage_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_InboundPriceCoverage] PRIMARY KEY CLUSTERED ([PriceCoverageId] ASC),
    CONSTRAINT [CK_InboundPriceCoverage_BillingEnd] CHECK ([BillingEnd]>[BillingStart]),
    CONSTRAINT [FK_InboundPriceCoverage_Currency] FOREIGN KEY ([Currency]) REFERENCES [mno].[Currency] ([Currency]),
    CONSTRAINT [FK_InboundPriceCoverage_DimVirtualNumberType] FOREIGN KEY ([VNType]) REFERENCES [ms].[DimVirtualNumberType] ([VNType]),
    CONSTRAINT [FK_InboundPriceCoverage_MSISDNCountry] FOREIGN KEY ([MSISDNCountry]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [FK_InboundPriceCoverage_Operator] FOREIGN KEY ([MSISDNOperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_InboundPriceCoverage_SubAccount] FOREIGN KEY ([SubaccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid]),
    CONSTRAINT [FK_InboundPriceCoverage_VNCountry] FOREIGN KEY ([VNCountry]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [UIX_InboundPriceCoverage] UNIQUE NONCLUSTERED ([SubaccountUid] ASC, [VNType] ASC, [VNCountry] ASC, [MSISDNCountry] ASC, [MSISDNOperatorId] ASC, [BillingStart] ASC)
);


GO

-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-03-06
-- =============================================
CREATE TRIGGER rt.InboundPriceCoverage_DataChanged 
   ON  rt.InboundPriceCoverage 
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN

	UPDATE f
	SET UpdatedAt = SYSUTCDATETIME()
	FROM rt.InboundPriceCoverage f
		INNER JOIN inserted AS i ON f.PriceCoverageId = i.PriceCoverageId

	EXEC ms.DbDependency_DataChanged @Key = 'rt.InboundPriceCoverage'
END

GO


CREATE TRIGGER [rt].[InboundPriceCoverage_Constraints]
	ON [rt].[InboundPriceCoverage] AFTER INSERT, UPDATE
AS
BEGIN

	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM rt.InboundPriceCoverage v1
			INNER JOIN inserted v2 ON 
				v1.PriceCoverageId <> v2.PriceCoverageId 
				AND v2.SubaccountUid = v1.SubaccountUid
				AND v2.VNType = v1.VNType
				AND v2.VNCountry = v1.VNCountry
				AND ISNULL(v2.MSISDNCountry, '') = ISNULL(v1.MSISDNCountry, '')
				AND ISNULL(v2.MSISDNOperatorId, 0) = ISNULL(v1.MSISDNOperatorId, 0)
		WHERE NOT (v2.BillingStart >= v1.BillingEnd OR v2.BillingEnd <= v1.BillingStart)
	)
	BEGIN
		RAISERROR ('Time period conflicts with other existing record', 16, 1)
		ROLLBACK TRANSACTION
	END

END
