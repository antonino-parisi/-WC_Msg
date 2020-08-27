-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-02
-- =============================================
-- EXEC [rt].[SupplierConn_UpdateConnectionStatus] @ConnId = 'abcd', @IsConnected = 1
CREATE PROCEDURE [rt].[SupplierConn_UpdateConnectionStatus]
	@ConnId varchar(50),
	@IsConnected bit
AS
BEGIN

	DECLARE @Now DATETIME2 = SYSUTCDATETIME();
	DECLARE @Secondes1d INT = 24 * 60 * 60;
	DECLARE @Secondes7d INT = 24 * 60 * 60 * 7;
	DECLARE @Secondes30d INT = 24 * 60 * 60 * 30;
	
	UPDATE rt.SupplierConn
	SET IsConnected = @IsConnected,
		UpdatedAt = @Now,
		UptimeLast1dSum = 
			CASE
				WHEN UptimeLast1dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) < 0 THEN 0
				WHEN UptimeLast1dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) > @Secondes1d THEN @Secondes1d
				ELSE UptimeLast1dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1)
			END,
		UptimeLast7dSum = 
			CASE
				WHEN UptimeLast7dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) < 0 THEN 0
				WHEN UptimeLast7dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) > @Secondes7d THEN @Secondes7d
				ELSE UptimeLast7dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1)
			END,
		UptimeLast30dSum = 
			CASE
				WHEN UptimeLast30dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) < 0 THEN 0
				WHEN UptimeLast30dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1) > @Secondes30d THEN @Secondes30d
				ELSE UptimeLast30dSum + DATEDIFF(SECOND, UpdatedAt, @Now) * IIF(@IsConnected = 1, -1, 1)
			END
	WHERE ConnId = @ConnId AND IsConnected <> @IsConnected

END
