
-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2018-12-04
-- =============================================
-- SELECT sms.fnSmsSegments (309, 0)

CREATE FUNCTION [sms].[fnSmsSegments]
(	
	@BodyLength	SMALLINT = 0,
	@EncodingTypeId TINYINT = 0
)
RETURNS TINYINT
AS
BEGIN
	RETURN 
		CASE 
			WHEN @EncodingTypeId <= 1 THEN
				CASE 
					WHEN @BodyLength <= 160 THEN 1 
					ELSE CEILING(@BodyLength/CAST(153 as DECIMAL(5,1))) 
				END
			WHEN @EncodingTypeId=10 THEN
				CASE 
					WHEN @BodyLength <= 70 THEN 1 
					ELSE CEILING(@BodyLength/CAST(67 as DECIMAL(5,1))) 
				END
		END
END
