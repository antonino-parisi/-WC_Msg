CREATE ROLE [role_team_ops]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_LV_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_CP_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_HC_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_PA_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_JP_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_SL_ops];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [WAVECELL\Ops Team];


GO
ALTER ROLE [role_team_ops] ADD MEMBER [user_RL_sales];

