﻿CREATE SYMMETRIC KEY [AccountCertificate_Key]
    AUTHORIZATION [dbo]
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE [AccountCertificate];

