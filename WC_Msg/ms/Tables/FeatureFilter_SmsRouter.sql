CREATE TABLE [ms].[FeatureFilter_SmsRouter] (
    [FilterId]     INT           IDENTITY (1, 1) NOT NULL,
    [Priority]     TINYINT       CONSTRAINT [DF_FeatureFilter_SmsRouter_Priority] DEFAULT ((0)) NOT NULL,
    [SubAccountId] VARCHAR (50)  NULL,
    [Country]      CHAR (2)      NULL,
    [OperatorId]   INT           NULL,
    [IsActive]     BIT           CONSTRAINT [DF_FeatureFilter_SmsRouter_IsActive] DEFAULT ((0)) NOT NULL,
    [ApiVersion]   CHAR (2)      CONSTRAINT [DF_FeatureFilter_SmsRouter_ApiVersion] DEFAULT ('V1') NOT NULL,
    [UpdatedAt]    DATETIME2 (2) CONSTRAINT [DF_FeatureFilter_SmsRouter_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_SmsRouter] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [IX_FeatureFilter_SmsRouter] UNIQUE NONCLUSTERED ([SubAccountId] ASC, [Country] ASC, [OperatorId] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_SmsRouter_DataChanged]
   ON  [ms].[FeatureFilter_SmsRouter]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [ms].[FeatureFilter_SmsRouter] f
		INNER JOIN inserted AS i ON f.FilterId = i.FilterId

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_SmsRouter'
END
