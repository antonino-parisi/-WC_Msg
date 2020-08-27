CREATE TABLE [dbo].[Jobs] (
    [JobId]              NVARCHAR (50)  NOT NULL,
    [JobDescription]     NVARCHAR (MAX) NULL,
    [ServiceId]          NVARCHAR (50)  NOT NULL,
    [AssemblyName]       VARCHAR (50)   NOT NULL,
    [ClassName]          VARCHAR (50)   NOT NULL,
    [LogFolder]          VARCHAR (MAX)  NOT NULL,
    [LogLevel]           INT            NOT NULL,
    [ScheduleType]       VARCHAR (50)   NULL,
    [ScheduleDefinition] VARCHAR (50)   NULL,
    [Active]             BIT            CONSTRAINT [DF_Jobs_Active] DEFAULT ((1)) NOT NULL
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-02
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[Jobs_DataChanged]
   ON  [dbo].[Jobs]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.Jobs'
END
