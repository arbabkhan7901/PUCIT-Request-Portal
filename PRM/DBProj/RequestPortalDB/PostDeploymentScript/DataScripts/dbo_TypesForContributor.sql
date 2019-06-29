SET IDENTITY_INSERT dbo.TypesForContributor ON

MERGE INTO dbo.TypesForContributor AS Target 
USING (
	Select 1, 'ActionPerformed','When contributor performed an action on any application' UNION ALL
	Select 2, 'ApplicationAssigned','When an application is assigned to a user.' UNION ALL
	Select 3, 'ApplicationUnassigned','when someone route back the application' UNION ALL
	SELECT 4, 'ApplicationReassigned','In the case of route back' UNION ALL
	SELECT 5, 'ApplicationUnassigned','Same As 3 but some parameters are different' UNION ALL
	SELECT 6, 'ApplicationAssigned', 'Same as 2 but some parameters are change' UNION ALL
	SELECT 7, 'CommentedOnApplication', 'When you commented on an application' UNION ALL
	SELECT 8, 'SomeoneCommented', 'other user commented on application' UNION ALL
	SELECT 9, 'AskForReview', 'When a user asked for a review on his/her application'
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

SET IDENTITY_INSERT dbo.TypesForContributor OFF