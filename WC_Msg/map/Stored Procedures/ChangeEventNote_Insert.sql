-- =============================================
-- Author:		Nathanael Hinay 
-- Create date: 2018-09-17
-- =============================================
-- SAMPLE:
-- EXEC map.ChangeEventNote_Insert @EvenId=20 @EventNotes = 'testing event notes'

CREATE PROCEDURE [map].[ChangeEventNote_Insert]
	@EventId int,
	@EventNotes nvarchar(4000)
AS
BEGIN
    UPDATE rt.ChangeEvent
    SET EventNotes = @EventNotes
    WHERE EventId = @EventId
END
