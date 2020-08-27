CREATE TABLE [rt].[RoutingView_Operator] (
    [OperatorId]          INT            NOT NULL,
    [RouteUid]            SMALLINT       NOT NULL,
    [IsActiveRoute]       BIT            NOT NULL,
    [JsonData]            NVARCHAR (MAX) NULL,
    [CreatedTimeUtc]      DATETIME       CONSTRAINT [DF_OperatorRoutes_dtCreated] DEFAULT (getutcdate()) NOT NULL,
    [LastModifiedTimeUtc] DATETIME       CONSTRAINT [DF_OperatorRoutes_dtLastUpdatedUtc] DEFAULT (getutcdate()) NOT NULL,
    [Ranking]             TINYINT        NULL,
    [RouteId]             VARCHAR (50)   NULL,
    [Currency]            CHAR (3)       NULL,
    [Cost]                REAL           NULL,
    CONSTRAINT [PK_OperatorRoutes] PRIMARY KEY CLUSTERED ([OperatorId] ASC, [RouteUid] ASC),
    CONSTRAINT [FK_RouteOperator_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_RouteOperator_SupplierConn_ConnId] FOREIGN KEY ([RouteId]) REFERENCES [rt].[SupplierConn] ([ConnId]) ON DELETE CASCADE,
    CONSTRAINT [FK_RouteOperator_SupplierConn_ConnUid] FOREIGN KEY ([RouteUid]) REFERENCES [rt].[SupplierConn] ([ConnUid])
);


GO
CREATE TRIGGER [rt].[tr_RoutingView_Operator_UpdateLastModified]
ON [rt].[RoutingView_Operator]
AFTER UPDATE
AS
    UPDATE rt.RoutingView_Operator 
	SET LastModifiedTimeUtc = SYSUTCDATETIME()
    FROM rt.RoutingView_Operator rv
		INNER JOIN inserted 
		ON rv.OperatorId= inserted.OperatorId AND rv.RouteUid = inserted.RouteUid
