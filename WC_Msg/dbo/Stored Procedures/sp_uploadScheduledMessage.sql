-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_uploadScheduledMessage]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


BULK INSERT   ScheduledMessages
    FROM 'C:\\fic.csv'  
    WITH  
    (  
        FIRSTROW = 1,  
        MAXERRORS = 0,  
        FIELDTERMINATOR = ';',
        CODEPAGE='ACP',
ROWTERMINATOR = '\n'
    )
END
