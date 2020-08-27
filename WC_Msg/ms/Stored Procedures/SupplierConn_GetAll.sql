-- ================================================
-- Author:		Anton Shchekalov
-- Create date: 2018-09-25
-- Description:	List of all active SupplierConns
-- ================================================
CREATE PROCEDURE ms.SupplierConn_GetAll
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		RouteUid AS ConnUid,
		LTRIM(RTRIM(RouteId)) AS ConnId, 
		ClassName, 
		TrashOnConnectionFail, 
		TrashOnMessageFail
	FROM dbo.CarrierConnections
	WHERE Active = 1

END

