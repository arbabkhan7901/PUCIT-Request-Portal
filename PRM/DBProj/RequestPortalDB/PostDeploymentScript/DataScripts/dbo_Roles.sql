
SET IDENTITY_INSERT dbo.Roles ON

MERGE INTO dbo.Roles AS Target 
USING (
	Select '1','Student','who submits application',1,GetUtCDate() UNION ALL
	Select '3','contributor','who takes action on application',1,GetUtCDate() UNION ALL
	Select '4','Teacher','ddd',1,GetUtCDate() UNION ALL
	SELECT '17','Admin','',1,GetUtCDate() UNION ALL
	SELECT 1001,'SuperContributor', 'Extra Permissions',1,GetUtCDate()  UNION ALL
	SELECT 1003, 'Manager', 'Manages Inventory', 1, GetUtCDate()  UNION ALL
	SELECT 1005, 'Accountant', 'manages Account', 1, GetUtCDate()
) 
AS Source (Id, Name, Description,CreatedBy,CreatedOn) 
ON Target.Id = Source.Id
WHEN MATCHED THEN 
UPDATE SET 
	Name = Source.Name,
	Description = Source.Description,
	CreatedBy = Source.CreatedBy,
	CreatedOn = Source.CreatedOn

WHEN NOT MATCHED BY TARGET THEN 
INSERT (Id, Name, Description,CreatedBy,CreatedOn) 
VALUES (Id, Name, Description,CreatedBy,CreatedOn);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.Roles OFF
