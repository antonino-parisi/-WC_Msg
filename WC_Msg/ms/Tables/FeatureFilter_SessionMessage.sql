CREATE TABLE [ms].[FeatureFilter_SessionMessage] (
    [SubAccountUid] INT NOT NULL,
    [Enabled]       BIT CONSTRAINT [DF_FeatureFilter_SessionMessage_Enabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FeatureFilter_SessionMessage] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC)
);


GO
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2017-02-12
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[FeatureFilter_SessionMessage_DataChanged]
   ON  [ms].[FeatureFilter_SessionMessage]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.FeatureFilter_SessionMessage'
END
