CREATE TABLE [ms].[FeatureFilter_AsyncDb] (
    [FilterId]      INT     IDENTITY (1, 1) NOT NULL,
    [Priority]      TINYINT CONSTRAINT [DF_FeatureFilter_AsyncDb_Priority] DEFAULT ((0)) NOT NULL,
    [SubAccountUid] INT     NULL,
    [Enabled]       BIT     CONSTRAINT [DF_FeatureFilter_AsyncDb_Enabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_AsyncDb] PRIMARY KEY CLUSTERED ([FilterId] ASC)
);


GO
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2018-12-04
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_AsyncDb_DataChanged]
   ON  [ms].[FeatureFilter_AsyncDb]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_AsyncDb'
END
