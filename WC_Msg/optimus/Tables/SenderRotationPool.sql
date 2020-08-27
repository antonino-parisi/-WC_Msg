CREATE TABLE [optimus].[SenderRotationPool] (
    [SenderPoolId]          SMALLINT        IDENTITY (1, 1) NOT NULL,
    [SenderPoolName]        VARCHAR (50)    NOT NULL,
    [SenderPoolDescription] NVARCHAR (255)  NOT NULL,
    [JsonSettings]          NVARCHAR (4000) NULL,
    CONSTRAINT [PK_SenderRotationPool] PRIMARY KEY CLUSTERED ([SenderPoolId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [optimus].[SenderRotationPool_DataChanged]
   ON  [optimus].[SenderRotationPool]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'Optimus.SenderId.Settings'
END
