CREATE TABLE [optimus].[SenderRotationPoolList] (
    [SenderPoolId]            SMALLINT     NOT NULL,
    [SenderId]                VARCHAR (16) NOT NULL,
    [NextAvailabilityTimeUtc] DATETIME     CONSTRAINT [DF_SenderRotationPoolList_NextAvailabilityTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_SenderRotationPoolList] PRIMARY KEY CLUSTERED ([SenderPoolId] ASC, [SenderId] ASC),
    CONSTRAINT [FK_SenderRotationPoolList_SenderRotationPool] FOREIGN KEY ([SenderPoolId]) REFERENCES [optimus].[SenderRotationPool] ([SenderPoolId])
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [optimus].[SenderRotationPoolList_DataChanged]
   ON  [optimus].[SenderRotationPoolList]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'Optimus.SenderId.Settings'
END
