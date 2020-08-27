﻿CREATE SYMMETRIC KEY [WebhookTokenCfg_Key]
    AUTHORIZATION [dbo]
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE [WebhookTokenCfg];
