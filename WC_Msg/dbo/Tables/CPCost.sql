CREATE TABLE [dbo].[CPCost] (
    [Operator]  NVARCHAR (50)   NOT NULL,
    [RouteId]   NVARCHAR (50)   NOT NULL,
    [Cost]      DECIMAL (18, 5) NOT NULL,
    [Active]    BIT             NOT NULL,
    [UpdatedAt] DATETIME2 (2)   CONSTRAINT [DF_CPCost_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_CPCost] PRIMARY KEY CLUSTERED ([Operator] ASC, [RouteId] ASC)
);


GO


CREATE TRIGGER [dbo].[CPCost_LogHistory] on [dbo].[CPCost]
FOR INSERT, UPDATE, DELETE
AS
	
	--- UpdatedAt update
	IF NOT UPDATE(UpdatedAt)
	BEGIN
		UPDATE f
		SET [UpdatedAt] = SYSUTCDATETIME()
		FROM dbo.CPCost f
			INNER JOIN inserted AS i 
			ON f.Operator = i.Operator AND f.RouteId = i.RouteId
	END

	--- log changes
	DECLARE @Now as datetime = GetUTCDate()
	SET NOCOUNT ON
	IF EXISTS (SELECT 1 FROM inserted)
	BEGIN
		IF EXISTS (SELECT 1 FROM deleted)
		BEGIN
			--@action = 'UPDATE'
			insert into dbo.CPCostHistory ([ChangedBy],[Action],[ChangedDate],[Operator],[RouteId],[Cost],[Active])
			select distinct SUser_SName(), 'update-deleted', @Now, [Operator],[RouteId],[Cost],[Active]
			from deleted
			insert into dbo.CPCostHistory ([ChangedBy],[Action],[ChangedDate],[Operator],[RouteId],[Cost],[Active])
			select distinct SUser_SName(), 'update-inserted', @Now, [Operator],[RouteId],[Cost],[Active]
			from inserted
		END
		ELSE
		BEGIN
			--@action = 'INSERT'
			INSERT INTO dbo.CPCostHistory ([ChangedBy],[Action],[ChangedDate],[Operator],[RouteId],[Cost],[Active])
			SELECT distinct SUser_SName(), 'insert', @Now, [Operator],[RouteId],[Cost],[Active]
			FROM inserted
		END
	END
	ELSE
	BEGIN
		--@action = 'DELETE'
		INSERT INTO dbo.CPCostHistory ([ChangedBy],[Action],[ChangedDate],[Operator],[RouteId],[Cost],[Active])
		SELECT distinct SUser_SName(), 'delete', @Now, [Operator],[RouteId],[Cost],[Active]
		FROM deleted
	END


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[CPCost_LogHistory]', @order = N'last', @stmttype = N'delete';


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[CPCost_LogHistory]', @order = N'last', @stmttype = N'insert';


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[CPCost_LogHistory]', @order = N'last', @stmttype = N'update';


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER dbo.CPCost_DataChanged
   ON  dbo.CPCost
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	EXEC ms.DbDependency_DataChanged @Key = 'morph.Cost'
END

