CREATE TABLE [ipm].[CostPlanCoverage] (
    [CoverageId]      INT             IDENTITY (1, 1) NOT NULL,
    [CostPlanId]      SMALLINT        NOT NULL,
    [ChannelTypeId]   TINYINT         NOT NULL,
    [Country]         CHAR (2)        NULL,
    [ContentTypeCode] VARCHAR (10)    NOT NULL,
    [PeriodStart]     DATE            NOT NULL,
    [PeriodEnd]       DATE            NOT NULL,
    [VolumeStart]     INT             NOT NULL,
    [VolumeEnd]       INT             NOT NULL,
    [Currency]        CHAR (3)        NOT NULL,
    [Cost]            DECIMAL (18, 6) NOT NULL,
    [UpdatedAt]       DATETIME2 (2)   CONSTRAINT [DF_CostPlanCoverage_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_CostPlanCoverage] PRIMARY KEY CLUSTERED ([CoverageId] ASC),
    CONSTRAINT [CK_CostPlanCoverage_PeriodEnd] CHECK ([PeriodEnd]>[PeriodStart]),
    CONSTRAINT [CK_CostPlanCoverage_VolumeEnd] CHECK ([VolumeEnd]>[VolumeStart]),
    CONSTRAINT [FK_CostPlanCoverage_ChannelTypeId] FOREIGN KEY ([ChannelTypeId]) REFERENCES [ipm].[ChannelType] ([ChannelTypeId])
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-12-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[CostPlanCoverage_DataChanged]
   ON  [ipm].[CostPlanCoverage]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.CostPlanCoverage'
END

GO


CREATE TRIGGER [ipm].[CostPlanCoverage_Constraints]
	ON [ipm].[CostPlanCoverage] AFTER INSERT, UPDATE
AS
BEGIN

	-- check conflict of period overlap with other records
	IF EXISTS (
		SELECT 1 
		FROM ipm.CostPlanCoverage v1
			INNER JOIN inserted v2 ON 
				v1.CoverageId <> v2.CoverageId 
				AND v2.CostPlanId = v1.CostPlanId
				AND v2.ChannelTypeId = v1.ChannelTypeId
				AND v2.ContentTypeCode = v1.ContentTypeCode
				AND v2.Country = v1.Country
				AND v1.VolumeStart = v2.VolumeStart
		WHERE NOT (v2.PeriodStart >= v1.PeriodEnd OR v2.PeriodEnd <= v1.PeriodStart)
	)
	BEGIN
		RAISERROR ('Time period conflicts with other existing record', 16, 1)
		ROLLBACK TRANSACTION
	END

END
