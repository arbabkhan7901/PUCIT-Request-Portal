
SET IDENTITY_INSERT dbo.PermissionsMapping ON

MERGE INTO dbo.PermissionsMapping AS Target 
USING (
	Select '1','1','1' UNION ALL
	Select '2','1','2' UNION ALL
	Select '3','1','6' UNION ALL
	Select '4','3','3' UNION ALL
	Select '5','3','4' UNION ALL
	Select '6','3','5' UNION ALL
	Select '7','3','6' UNION ALL
	Select '8','3','7' UNION ALL
	Select '9','3','8' UNION ALL
	Select '10','3','9' UNION ALL
	Select '11','3','10' UNION ALL
	Select '12','3','13' UNION ALL
	Select '13','1','15' UNION ALL
	Select '14','3','16' UNION ALL
	Select '15','3','17' UNION ALL
	Select '16','3','18' UNION ALL
	Select '17','3','19' UNION ALL
	Select '18','4','3' UNION ALL
	Select '19','4','4' UNION ALL
	Select '20','4','5' UNION ALL
	Select '21','4','6' UNION ALL
	Select '22','4','7' UNION ALL
	Select '23','4','8' UNION ALL
	Select '24','4','9' UNION ALL
	Select '25','4','10' UNION ALL
	Select '26','4','13' UNION ALL
	Select '27','4','16' UNION ALL
	SELECT 206, 17, 26 UNION ALL
	SELECT 207, 17, 27 UNION ALL
	SELECT 208, 17, 28 UNION ALL
	Select 209,'17','29' UNION ALL
	Select 210,'17','30' UNION ALL
	Select 211,'17','31' UNION ALL
	Select 212,'17','32' UNION ALL
	Select 213,'17','33' UNION ALL
	Select 214,'17','34' UNION ALL
	Select 215,'17','35' UNION ALL
	Select 216,'17','5' UNION ALL

	Select 1001,'1001','3' UNION ALL
	Select 1002,'1001','4' UNION ALL
	Select 1003,'1001','5' UNION ALL
	Select 1004,'1001','6' UNION ALL
	Select 1005,'1001','7' UNION ALL
	Select 1006,'1001','8' UNION ALL
	Select 1007,'1001','9' UNION ALL
	Select 1008,'1001','10' UNION ALL
	Select 1009,'1001','13' UNION ALL
	Select 1010,'1001','16' UNION ALL
	Select 1011,'1001','17' UNION ALL
	Select 1012,'1001','18' UNION ALL
	Select 1013,'1001','19' UNION ALL
	Select 1014,'1001','29' UNION ALL
	Select 1015,'1001','33' UNION ALL
	Select 1016, 3, 36 UNION ALL
	Select 1017, 3, 37 UNION ALL
	Select 1018, 3, 1 UNION ALL
	Select 1019, 1003, 38 UNION ALL
	Select 1021, 1003, 41 UNION ALL
	Select 1022, 4, 1 UNION ALL
	Select 1023, 4, 37 UNION ALL
	Select 1024, 4, 2 UNION ALL
	Select 1025, 4, 6
) 
AS Source (Id, RoleId, PermissionId) 
ON Target.Id = Source.Id
WHEN MATCHED THEN 
UPDATE SET 
	RoleId = Source.RoleId,
	PermissionId = Source.PermissionId

WHEN NOT MATCHED BY TARGET THEN 
INSERT (Id, RoleId, PermissionId) 
VALUES (Id, RoleId, PermissionId);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.PermissionsMapping OFF
