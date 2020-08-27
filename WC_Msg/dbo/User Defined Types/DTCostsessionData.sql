﻿CREATE TYPE [dbo].[DTCostsessionData] AS TABLE (
    [AccountId]            NVARCHAR (50)  NOT NULL,
    [SubAccountId]         NVARCHAR (50)  NOT NULL,
    [RouteId]              NVARCHAR (50)  NOT NULL,
    [Price]                FLOAT (53)     NULL,
    [Operator]             NVARCHAR (200) NOT NULL,
    [Cost]                 FLOAT (53)     NULL,
    [Margin]               FLOAT (53)     NULL,
    [MarginPercent]        FLOAT (53)     NULL,
    [SessionId]            NVARCHAR (250) NOT NULL,
    [DateTime]             DATETIME       NOT NULL,
    [Currentcost]          FLOAT (53)     NULL,
    [Currentprice]         FLOAT (53)     NULL,
    [Currentmargin]        FLOAT (53)     NULL,
    [Currentmarginpercent] FLOAT (53)     NULL,
    [UpdateMargin]         FLOAT (53)     NULL,
    [UpdateMarginpercent]  FLOAT (53)     NULL,
    [Impact]               NVARCHAR (50)  NULL,
    [Active]               BIT            NULL,
    [CurrentActive]        BIT            NOT NULL,
    [Country]              NVARCHAR (50)  NULL,
    [InCostFile]           NVARCHAR (50)  NULL,
    [DateTimeUpdated]      DATETIME       NOT NULL,
    [OperatorName]         NVARCHAR (MAX) NULL,
    [ProposedRouteId]      NVARCHAR (50)  NULL,
    [UpdateCost]           FLOAT (53)     NULL,
    [RoutingMode]          INT            NULL,
    [RouteStatus]          NVARCHAR (50)  NULL);

