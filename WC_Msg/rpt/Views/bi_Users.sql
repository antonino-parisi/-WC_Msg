CREATE VIEW [rpt].[bi_Users]
AS
	SELECT
        Username,
        AccountId
    from dbo.Users
