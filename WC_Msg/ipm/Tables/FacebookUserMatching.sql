CREATE TABLE [ipm].[FacebookUserMatching] (
    [SubAccountUid] INT          NOT NULL,
    [PageId]        BIGINT       NOT NULL,
    [ChannelUserId] VARCHAR (50) NOT NULL,
    [Msisdn]        BIGINT       NULL,
    [UserId]        BIGINT       NULL,
    CONSTRAINT [PK_FacebookUserMatching] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC, [PageId] ASC, [ChannelUserId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-10-12
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[FacebookUserMatching_DataChanged]
   ON  [ipm].[FacebookUserMatching]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.FacebookUserMatching'
END
