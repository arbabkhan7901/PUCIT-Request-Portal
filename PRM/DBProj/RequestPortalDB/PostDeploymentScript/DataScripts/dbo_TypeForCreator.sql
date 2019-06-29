SET IDENTITY_INSERT dbo.TypeForCreator ON

MERGE INTO dbo.TypeForCreator AS Target 
USING (
	Select 1, 'ActionPerformed', 'When a contributor perform any action on your application'  UNION ALL
	Select 2, 'ApplicationClosed', 'When your application is closed' UNION ALL
	Select 3, 'ApplicationReassigned', 'When your applicatio routed back by a contributor' UNION ALL
	SELECT 4, 'ApplicationCreation', 'When you generate a new application' UNION ALL
	SELECT 5, 'SomeOneCommented', 'When someone commented on your application' UNION ALL
	SELECT 6, 'AskForReview', 'When You asked for a review'
) 
AS Source (TypeID, TypeName, Description) 
ON Target.TypeID = Source.TypeID
WHEN MATCHED THEN 
UPDATE SET 
	TypeName = Source.TypeName,
	Description = Source.Description

WHEN NOT MATCHED BY TARGET THEN 
INSERT (TypeID, TypeName, Description) 
VALUES (TypeID, TypeName, Description);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.TypeForCreator OFF