CREATE ROLE [role_team_ops_l2]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_ops_l2] ADD MEMBER [user_LV_ops];


GO
ALTER ROLE [role_team_ops_l2] ADD MEMBER [user_HC_ops];


GO
ALTER ROLE [role_team_ops_l2] ADD MEMBER [user_PA_ops];


GO
ALTER ROLE [role_team_ops_l2] ADD MEMBER [user_ops_kristof];

