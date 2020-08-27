CREATE TABLE [rt].[SubAccount_Default] (
    [SubAccountUid]         INT           NOT NULL,
    [RoutingPlanId_Default] INT           NOT NULL,
    [PricingPlanId_Default] INT           NOT NULL,
    [UpdatedAt]             DATETIME2 (2) CONSTRAINT [DF_SubAccount_Default_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]               BIT           CONSTRAINT [DF_SubAccount_Default_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SubAccount_Default] PRIMARY KEY CLUSTERED ([SubAccountUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SubAccount_Default_DataChanged] 
   ON  [rt].[SubAccount_Default] 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[SubAccount_Default] f
		INNER JOIN inserted AS i ON f.SubAccountUid = i.SubAccountUid
END
