CREATE TABLE [ms].[FeatureFilter_Optimus] (
    [FilterId]   INT      IDENTITY (1, 1) NOT NULL,
    [Priority]   TINYINT  CONSTRAINT [DF_FeatureFilter_Optimus_Priority] DEFAULT ((0)) NOT NULL,
    [Country]    CHAR (2) NULL,
    [RouteUid]   INT      NULL,
    [IsActive]   BIT      CONSTRAINT [DF_FeatureFilter_Optimus_IsActive] DEFAULT ((0)) NOT NULL,
    [ApiVersion] CHAR (2) CONSTRAINT [DF_FeatureFilter_Optimus_ApiVersion] DEFAULT ('V1') NOT NULL,
    CONSTRAINT [PK_FeatureFilter_Optimus] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [FK_FeatureFilter_Optimus_Country] FOREIGN KEY ([Country]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [IX_FeatureFilter_Optimus] UNIQUE NONCLUSTERED ([Country] ASC, [RouteUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_Optimus_DataChanged]
   ON  [ms].[FeatureFilter_Optimus]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_Optimus'
END
