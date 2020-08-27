CREATE ROLE [role_team_eng_read]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_eng_read] ADD MEMBER [user_dev_tony];


GO
ALTER ROLE [role_team_eng_read] ADD MEMBER [WAVECELL\Dev team];


GO
ALTER ROLE [role_team_eng_read] ADD MEMBER [user_dev_AM];

