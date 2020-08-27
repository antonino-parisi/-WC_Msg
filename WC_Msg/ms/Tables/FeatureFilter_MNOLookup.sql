CREATE TABLE [ms].[FeatureFilter_MNOLookup] (
    [FilterId]        INT          IDENTITY (1, 1) NOT NULL,
    [Priority]        TINYINT      CONSTRAINT [DF_FeatureFilter_MNOLookup_Priority] DEFAULT ((0)) NOT NULL,
    [Country]         CHAR (2)     NULL,
    [SubAccountId]    VARCHAR (50) NULL,
    [IsActive]        BIT          CONSTRAINT [DF_FeatureFilter_MNOLookup_IsActive] DEFAULT ((0)) NOT NULL,
    [ApiVersion]      CHAR (2)     CONSTRAINT [DF_FeatureFilter_MNOLookup_ApiVersion] DEFAULT ('V1') NOT NULL,
    [FallbackEnabled] BIT          CONSTRAINT [DF_FeatureFilter_MNOLookup_FallbackEnabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_MNOLookup] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [FK_FeatureFilter_MNOLookup_Country] FOREIGN KEY ([Country]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [IX_FeatureFilter_MNOLookup] UNIQUE NONCLUSTERED ([Country] ASC, [SubAccountId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_MNOLookup_DataChanged]
   ON  ms.FeatureFilter_MNOLookup
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_MNOLookup'
END
