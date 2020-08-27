CREATE TABLE [ms].[FeatureFilter_Classifier] (
    [FilterId]      INT      IDENTITY (1, 1) NOT NULL,
    [Priority]      TINYINT  CONSTRAINT [DF_FeatureFilter_Classifier_Priority] DEFAULT ((0)) NOT NULL,
    [CustomerType]  CHAR (1) NULL,
    [Country]       CHAR (2) NULL,
    [SubAccountUid] INT      NULL,
    [IsActive]      BIT      CONSTRAINT [DF_FeatureFilter_Classifier_IsActive] DEFAULT ((0)) NOT NULL,
    [Version]       CHAR (2) CONSTRAINT [DF_FeatureFilter_Classifier_Version] DEFAULT ('V1') NOT NULL,
    CONSTRAINT [PK_FeatureFilter_Classifier] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [UIX_FeatureFilter_Classifier] UNIQUE NONCLUSTERED ([CustomerType] ASC, [Country] ASC, [SubAccountUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_Classifier_DataChanged]
   ON  [ms].[FeatureFilter_Classifier]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_Classifier'
END
