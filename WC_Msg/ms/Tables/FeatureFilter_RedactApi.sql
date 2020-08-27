CREATE TABLE [ms].[FeatureFilter_RedactApi] (
    [FilterId]   INT              IDENTITY (1, 1) NOT NULL,
    [Priority]   TINYINT          DEFAULT ((0)) NOT NULL,
    [AccountUid] UNIQUEIDENTIFIER NOT NULL,
    [IsActive]   BIT              DEFAULT ((0)) NOT NULL,
    CONSTRAINT [ms.FeatureFilter_RedactApi_pk] PRIMARY KEY NONCLUSTERED ([FilterId] ASC),
    CONSTRAINT [FK_FeatureFilter_RedactApi_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid])
);


GO

-- =============================================
-- Author: Tony Ivanov
-- Create date: 2020-08-05
-- Description:	Data updated trigger
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_RedactApi_DataChanged]
   ON  ms.FeatureFilter_RedactApi
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_RedactApi'
END
