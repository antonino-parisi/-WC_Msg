CREATE TABLE [rt].[RoutingPlan] (
    [RoutingPlanId]   INT             IDENTITY (1, 1) NOT NULL,
    [RoutingPlanName] NVARCHAR (100)  NOT NULL,
    [Description]     NVARCHAR (1000) NULL,
    [OwnerId]         SMALLINT        NULL,
    [CreatedAt]       DATETIME2 (2)   CONSTRAINT [DF_RoutingPlan_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]       DATETIME2 (2)   CONSTRAINT [DF_RoutingPlan_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]         BIT             CONSTRAINT [DF_RoutingPlan_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RoutingPlan] PRIMARY KEY CLUSTERED ([RoutingPlanId] ASC),
    CONSTRAINT [UIX_RoutingPlan_Name] UNIQUE NONCLUSTERED ([RoutingPlanName] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[RoutingPlan_DataChanged] 
   ON  rt.RoutingPlan 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[RoutingPlan] f
		INNER JOIN inserted AS i ON f.RoutingPlanId = i.RoutingPlanId
END
