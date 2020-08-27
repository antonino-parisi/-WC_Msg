-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-02-02
-- Description:	Return all TrafficErrorCode for MessageSphere apps
-- =============================================
-- EXEC [ms].[TrafficErrorCode_GetAll]
CREATE PROCEDURE [ms].[TrafficErrorCode_GetAll]
AS
BEGIN	
    SELECT RouteID, SupplierErrorCode, WavecellErrorCode
	FROM dbo.TrafficErrorCode
END
