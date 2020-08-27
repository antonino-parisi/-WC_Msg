
-- =============================================
-- Author:		Sadeep Madurange
-- Create date: 2020-01-30
-- Description:	Gets all records from DlrToProcess table that are not currently being processed.
-- =============================================
CREATE PROCEDURE [sms].[DlrToProcess_GetBatchUnprocessed]
AS
    --DECLARE @Batch TABLE (Umid UNIQUEIDENTIFIER, StatusId TINYINT, InProcess BIT)

    UPDATE TOP(1000) sms.DlrToProcess -- Setting a limit just in case, though we don't expect the number here to be too high.
    SET InProcess = 1
    OUTPUT inserted.Umid, inserted.StatusId, inserted.InProcess --INTO @Batch
    WHERE InProcess = 0;

    --SELECT * FROM @Batch;
