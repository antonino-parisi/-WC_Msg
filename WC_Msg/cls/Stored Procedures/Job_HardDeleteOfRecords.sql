-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-07
-- =============================================
CREATE PROCEDURE [cls].[Job_HardDeleteOfRecords]
	@FromTimeStamp datetime2(2) = NULL
AS
BEGIN
	IF(@FromTimeStamp IS NULL)
		SET @FromTimeStamp = DATEADD(DAY, -7, SYSUTCDATETIME());

    DELETE FROM [cls].[ClassificationPattern]
	WHERE (Deleted = 1 AND UpdatedAt <= @FromTimeStamp)

	DELETE FROM [cls].[ClassificationPatternDefault]
	WHERE (Deleted = 1 AND UpdatedAt <= @FromTimeStamp)

	DELETE FROM [cls].[ClassificationRule]
	WHERE (Deleted = 1 AND UpdatedAt <= @FromTimeStamp)
END
