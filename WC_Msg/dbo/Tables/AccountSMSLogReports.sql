CREATE TABLE [dbo].[AccountSMSLogReports] (
    [AccountId]         NVARCHAR (50) NOT NULL,
    [ScheduleTimes]     NVARCHAR (50) NOT NULL,
    [EmailLastSentTime] DATETIME      CONSTRAINT [DF_AccountSMSLogReports_LastSentTime] DEFAULT (getutcdate()) NOT NULL,
    [IncludeBody]       BIT           CONSTRAINT [DF_AccountSMSLogReports_IncludeBody] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountSMSLogReports] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-02
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[AccountSMSLogReports_DataChanged]
   ON  [dbo].[AccountSMSLogReports]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.AccountSMSLogReports'
END
