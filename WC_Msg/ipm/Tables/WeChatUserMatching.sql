CREATE TABLE [ipm].[WeChatUserMatching] (
    [UserId]        BIGINT       IDENTITY (1, 1) NOT NULL,
    [SubAccountUid] INT          NOT NULL,
    [Msisdn]        BIGINT       NULL,
    [ChannelUserId] VARCHAR (50) NULL,
    CONSTRAINT [PK_WeChatUserMatching] PRIMARY KEY CLUSTERED ([UserId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-06-28
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[WeChatUserMatching_DataChanged]
   ON  [ipm].[WeChatUserMatching]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.WeChatUserMatching'
END
