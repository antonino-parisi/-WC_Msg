-- =============================================
-- Author:		Anton Shchekalov 
-- Create date: 2018-08-03
-- Updated By:  Nathanael Hinay
-- Date Updated: 2018-9-17
-- =============================================
-- SAMPLE:
-- EXEC map.ChangeEvent_GetDetail @EventId = 23
CREATE PROCEDURE [map].[ChangeEvent_GetDetail]
	@EventId int
AS
BEGIN
	SELECT 
		ce.EventId, 
		ce.EventData,
        ce.EventNotes
	FROM rt.ChangeEvent ce
	WHERE
		ce.EventId = @EventId

END
