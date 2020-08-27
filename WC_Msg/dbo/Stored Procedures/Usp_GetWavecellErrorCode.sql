--EXEC [dbo].[Usp_GetWavecellErrorCode] @UMID='8187c4e6-e9c7-4b7c-8cb7-a1a792c9e344'
CREATE PROCEDURE [dbo].[Usp_GetWavecellErrorCode]
	@UMID VARCHAR(50)		
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Err as varchar(50)
	SELECT @Err = te.WavecellErrorCode 
	FROM TrafficRecord tr WITH (NOLOCK)
		INNER JOIN TrafficErrorCode te WITH (NOLOCK) ON tr.RouteIdUsed = te.RouteID AND tr.ErrorCode = te.SupplierErrorCode
	WHERE tr.UMID=@UMID

	IF @Err IS NULL
		SET @Err = '0'

	SELECT @Err AS WavecellErrorcode
END