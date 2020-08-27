-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-08
-- Description:	Update record for RouteOperator
-- =============================================
CREATE PROCEDURE [rt].[RouteOperator_Update]
	@OperatorId int,
	@RouteId varchar(50),
	@Ranking tinyint,
	@JsonData nvarchar(max)
AS
BEGIN
	DECLARE @RouteUid smallint ;

	-- block record updates for depricated kdb.wavecell.io portal
	IF SUSER_NAME() = 'app_kdb' RETURN ;

	SELECT @RouteUid = ConnUid FROM rt.Supplierconn
	WHERE ConnId = @RouteId ;

	IF @RouteUid IS NULL RETURN ;

	UPDATE rt.RoutingView_Operator 
	SET JsonData=@JsonData, Ranking = @Ranking
	WHERE RouteUid = @RouteUid AND OperatorId = @OperatorId ;

END
