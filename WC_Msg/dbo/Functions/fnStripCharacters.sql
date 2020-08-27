--
-- https://stackoverflow.com/questions/1007697/how-to-strip-all-non-alphabetic-characters-from-string-in-sql-server
--
-- Samples
--	SELECT dbo.fnStripCharacters('a1!s2@d3#f4$', '^a-z')
--	SELECT dbo.fnStripCharacters('a1!s2@d3#f4$', '^0-9')
--	SELECT dbo.fnStripCharacters('a1!s2@d3#f4$', '^a-z0-9')
--	SELECT dbo.fnStripCharacters('a1!.s2@d3#_f4$', '^a-zA-Z0-9_.')
CREATE FUNCTION [dbo].[fnStripCharacters]
(
    @String NVARCHAR(MAX), 
    @MatchExpression VARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    SET @MatchExpression =  '%['+@MatchExpression+']%'

    WHILE PatIndex(@MatchExpression, @String) > 0
        SET @String = Stuff(@String, PatIndex(@MatchExpression, @String), 1, '')

    RETURN @String

END
