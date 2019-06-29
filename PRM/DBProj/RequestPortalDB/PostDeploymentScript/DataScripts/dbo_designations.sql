
SET IDENTITY_INSERT dbo.Designations ON

MERGE INTO dbo.Designations AS Target 
USING (
	select 1,'Student Affairs Coordinator',1 UNION ALL
	select 2,'Principal',1 UNION ALL
	select 3,'Program Coordinator',1 UNION ALL
	select 4,'Exam Coordinator',1 UNION ALL
	select 5,'Admin Officer',1 UNION ALL
	select 6,'Assistant Treasurer',1 UNION ALL
	select 7,'Librarian',1 UNION ALL
	select 8,'Secretary DC',1 UNION ALL
	select 9,'Network Admin',1 UNION ALL
	select 10,'Teacher',1 UNION ALL
	select 11,'Store Keeper', 1 UNION ALL
	Select 12,'Account Officer', 1
) 
AS Source (DesignationID,Designation,IsActive) 
ON Target.DesignationID = Source.DesignationID
WHEN MATCHED THEN 
UPDATE SET 
	Designation = Source.Designation,
	IsActive = Source.IsActive
WHEN NOT MATCHED BY TARGET THEN 
INSERT (DesignationID,Designation,IsActive) 
VALUES (DesignationID,Designation,IsActive);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.Designations OFF;
