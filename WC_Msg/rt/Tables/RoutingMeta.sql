CREATE TABLE [rt].[RoutingMeta] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [SubAccountId]   VARCHAR (50)    NOT NULL,
    [Country]        CHAR (2)        NULL,
    [OperatorId]     INT             NULL,
    [InfoMessage]    NVARCHAR (1000) NOT NULL,
    [CreatedTimeUtc] DATETIME        CONSTRAINT [DF_rt_RoutingMeta_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_rt_RoutingMeta] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UIX_rt_RoutingMeta_Unique] UNIQUE NONCLUSTERED ([SubAccountId] ASC, [Country] ASC, [OperatorId] ASC)
);

