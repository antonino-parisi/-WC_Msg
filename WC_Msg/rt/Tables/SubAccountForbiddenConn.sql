CREATE TABLE [rt].[SubAccountForbiddenConn] (
    [SubAccoutUid] INT           NOT NULL,
    [ConnUid]      SMALLINT      NOT NULL,
    [Deleted]      BIT           CONSTRAINT [DF_SubAccountForbiddenConn__Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]    DATETIME2 (7) CONSTRAINT [DF_SubAccountForbiddenConn__UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_SubAccountForbiddenConn] PRIMARY KEY CLUSTERED ([SubAccoutUid] ASC, [ConnUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SubAccountForbiddenConn_DataChanged] 
   ON  [rt].[SubAccountForbiddenConn] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[SubAccountForbiddenConn] f
		INNER JOIN inserted AS i ON f.SubAccoutUid = i.SubAccoutUid and f.ConnUid = i.ConnUid
END
