CREATE TABLE [rt].[RoutingView_Customer] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [AccountId]           NVARCHAR (50)  NOT NULL,
    [SubAccountId]        NVARCHAR (50)  NOT NULL,
    [IsActiveRoute]       BIT            NOT NULL,
    [Prefix]              VARCHAR (16)   NULL,
    [Country]             CHAR (2)       NULL,
    [OperatorId]          INT            NULL,
    [Priority]            TINYINT        NOT NULL,
    [RouteId]             VARCHAR (50)   NOT NULL,
    [Currency]            CHAR (3)       NOT NULL,
    [Cost]                REAL           NOT NULL,
    [Price]               REAL           NOT NULL,
    [RoutingMode]         TINYINT        NULL,
    [MessageBodyPrefix]   NVARCHAR (50)  NULL,
    [SenderPoolId]        SMALLINT       NULL,
    [TrafficLast7days]    INT            NULL,
    [CreatedTimeUtc]      DATETIME       CONSTRAINT [DF_RouteCustomer_Original_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [LastModifiedTimeUtc] DATETIME       CONSTRAINT [DF_RouteCustomer_Original_LastModifiedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [Comment]             NVARCHAR (500) NULL,
    CONSTRAINT [PK_RouteCustomer_Original] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RouteCustomer_Original_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_RouteCustomer_Original_Route] FOREIGN KEY ([RouteId]) REFERENCES [rt].[Route] ([RouteId]) ON DELETE CASCADE,
    CONSTRAINT [IX_RouteCustomer_Original_Unique] UNIQUE NONCLUSTERED ([AccountId] ASC, [SubAccountId] ASC, [Country] ASC, [OperatorId] ASC, [RouteId] ASC)
);


GO
CREATE TRIGGER [rt].[tr_RoutingView_Customer_UpdateLastModified]
ON [rt].[RoutingView_Customer]
AFTER UPDATE
AS
    UPDATE rt.RoutingView_Customer
	SET LastModifiedTimeUtc = GETUTCDATE()
    FROM rt.RoutingView_Customer curr
		INNER JOIN inserted 
		ON curr.ID= inserted.ID
