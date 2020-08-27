CREATE ROLE [role_team_dev_map]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_dev_map] ADD MEMBER [user_dev_MO];


GO
ALTER ROLE [role_team_dev_map] ADD MEMBER [user_dev_NH];


GO
ALTER ROLE [role_team_dev_map] ADD MEMBER [user_dev_RT];

