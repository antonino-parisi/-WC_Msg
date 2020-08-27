CREATE TABLE [sms].[SmsLogExportSettings] (
    [SubAccountUid] INT NOT NULL,
    [MSISDN]        BIT CONSTRAINT [DF_SmsLogExportSettings_MSISDN] DEFAULT ((0)) NOT NULL,
    [Body]          BIT NOT NULL,
    [OperatorId]    BIT CONSTRAINT [DF_SmsLogExportSettings_OperatorId] DEFAULT ((0)) NOT NULL,
    [OperatorName]  BIT CONSTRAINT [DF_SmsLogExportSettings_OperatorName] DEFAULT ((0)) NOT NULL
);


GO



-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-11
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [sms].[SmsLogExportSettings_DataChanged]
   ON  [sms].[SmsLogExportSettings]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	EXEC ms.DbDependency_DataChanged @Key = 'sms.SmsLogExportSettings'
END
