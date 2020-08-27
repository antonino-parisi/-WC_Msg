CREATE TABLE [ms].[FeatureFilter_SMSCDLR] (
    [FilterId]         INT          IDENTITY (1, 1) NOT NULL,
    [Priority]         TINYINT      CONSTRAINT [DF_FeatureFilter_SMSCDLR_Priority] DEFAULT ((0)) NOT NULL,
    [RouteId]          VARCHAR (50) NULL,
    [CountryISO2alpha] CHAR (2)     NOT NULL,
    [OperatorId]       INT          NULL,
    [SubAccountId]     VARCHAR (50) NULL,
    [IsActive]         BIT          CONSTRAINT [DF_FeatureFilter_SMSCDLR_IsActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_SMSCDLR] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [IX_FeatureFilter_SMSCDLR] UNIQUE NONCLUSTERED ([RouteId] ASC, [CountryISO2alpha] ASC, [OperatorId] ASC, [SubAccountId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_SMSCDLR_DataChanged]
   ON  [ms].[FeatureFilter_SMSCDLR]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_SMSCDLR'
END
