-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-07
-- Updated date: 2018-01-11 Aravinda Madushanka Added Priority
-- =============================================
CREATE PROCEDURE [cls].[Category_GetAll]
    @LastSyncTimeStamp datetime2(2) = NULL
AS
BEGIN
	SELECT SubCategoryId, SubCategory, Category, Deleted, Priority
	FROM cls.Category AS c
	WHERE ((@LastSyncTimestamp IS NULL AND c.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND c.UpdatedAt >= @LastSyncTimestamp))	
END
