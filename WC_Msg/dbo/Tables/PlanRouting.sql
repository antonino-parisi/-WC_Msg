CREATE TABLE [dbo].[PlanRouting] (
    [AccountId]          NVARCHAR (50)   NOT NULL,
    [SubAccountId]       NVARCHAR (50)   NOT NULL,
    [Prefix]             NVARCHAR (50)   NOT NULL,
    [RouteId]            NVARCHAR (50)   NOT NULL,
    [Price]              FLOAT (53)      NOT NULL,
    [Priority]           INT             NOT NULL,
    [Active]             BIT             NOT NULL,
    [Operator]           NVARCHAR (200)  CONSTRAINT [DF_PlanRouting_Operator] DEFAULT (N'none') NOT NULL,
    [TariffRoute]        BIT             CONSTRAINT [DF_PlanRouting_TariffRoute] DEFAULT ((0)) NOT NULL,
    [Cost]               FLOAT (53)      NULL,
    [RoutingMode]        INT             NULL,
    [Comment]            NVARCHAR (500)  NULL,
    [PriceLocalCurrency] CHAR (3)        NULL,
    [PriceLocal]         DECIMAL (12, 6) NULL,
    CONSTRAINT [PK_PlanRouting] PRIMARY KEY CLUSTERED ([AccountId] ASC, [SubAccountId] ASC, [Prefix] ASC, [Operator] ASC)
);


GO


CREATE TRIGGER [dbo].[PlanRouting_LogHistory] on [dbo].[PlanRouting]
  FOR insert,update,delete
AS
DECLARE @Now as datetime = GetUTCDate()
SET NOCOUNT ON
IF EXISTS (SELECT 1 FROM inserted)
BEGIN
	IF EXISTS (SELECT 1 FROM deleted)
	BEGIN
		--@action = 'UPDATE'
		insert into dbo.PlanRoutingHistory ([ChangedBy],[Action],[ChangedDate],[AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode])
		select SUser_SName(), 'update-deleted', @Now, [AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode]
		from deleted
		insert into dbo.PlanRoutingHistory ([ChangedBy],[Action],[ChangedDate],[AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode])
		select SUser_SName(), 'update-inserted', @Now, [AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode]
		from inserted
	END
	ELSE
	BEGIN
		--@action = 'INSERT'
		INSERT INTO dbo.PlanRoutingHistory ([ChangedBy],[Action],[ChangedDate],[AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode])
		SELECT SUser_SName(), 'insert', @Now, [AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode]
		FROM inserted
	END
END
ELSE
BEGIN
	--@action = 'DELETE'
	INSERT INTO dbo.PlanRoutingHistory ([ChangedBy],[Action],[ChangedDate],[AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode])
	SELECT SUser_SName(), 'delete', @Now, [AccountId],[SubAccountId],[Prefix],[RouteId],[Price],[Priority],[Active],[Operator],[TariffRoute],[Cost],[RoutingMode]
	FROM deleted
END


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[PlanRouting_LogHistory]', @order = N'last', @stmttype = N'delete';


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[PlanRouting_LogHistory]', @order = N'last', @stmttype = N'insert';


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[PlanRouting_LogHistory]', @order = N'last', @stmttype = N'update';


GO
CREATE TRIGGER [dbo].[updateServer_PlanRouting] ON
 [dbo].[PlanRouting]
 FOR INSERT,UPDATE,DELETE
 AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXECUTE  sp_configurationChanged;
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.PlanRouting';
	END
	-- this logic moved to JOB 'MessageSphere: job_PlanRoutingFor_GlobalPricing_Update'
	--delete from PlanRoutingFor_GlobalPricing
	--insert into PlanRoutingFor_GlobalPricing select * from PlanRouting
END