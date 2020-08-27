-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [ms].[GetDRLevel]
(
	@Status varchar(50)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @level int = 0

	IF @Status = 'RECEIVED'				SET @level = 1
	IF @Status = 'TRASHED'				SET @level = 2
	IF @Status = 'SENT'					SET @level = 2
	IF @Status = 'DELIVERED TO CARRIER' SET @level = 3
	IF @Status = 'REJECTED BY CARRIER'	SET @level = 3 
	IF @Status = 'REJECTED BY DEVICE'	SET @level = 4
	IF @Status = 'DELIVERED TO DEVICE'	SET @level = 4
	
	--CASE 
	--	WHEN @Status = 'TRASHED' THEN SET @level = 2
	--	WHEN @Status = 'SENT' THEN SET @level = 2
	--	WHEN @Status = 'DELIVERED_TO_DEVICE' THEN SET @level = 4
	--	WHEN @Status = 'DELIVERED_TO_CARRIER' THEN SET @level = 3
	--	WHEN @Status = 'REJECTED_BY_CARRIER' THEN SET @level = 3 
	--	WHEN @Status = 'RECEIVED' THEN SET @level = 1
	--	WHEN @Status = 'REJECTED_BY_DEVICE' THEN SET @level = 4
	--	ELSE SET @level = 0
	--END

	RETURN @level

END
