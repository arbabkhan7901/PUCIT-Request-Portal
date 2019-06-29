
print 'setting dbo.ApproverHierarchy data';

SET IDENTITY_INSERT dbo.ApproverHierarchy ON

MERGE INTO dbo.ApproverHierarchy AS Target 
USING (
	Select '1','1','1','7','0','1' UNION ALL
	Select '2','1','3','6','0','1' UNION ALL
	Select '3','1','4','5','0','1' UNION ALL
	Select '4','1','6','2','0','1' UNION ALL
	Select '5','1','7','3','0','1' UNION ALL
	Select '6','1','8','1','0','1' UNION ALL
	Select '7','1','9','4','0','1' UNION ALL
	Select '8','2','1','1','1','1' UNION ALL
	Select '9','2','2','2','0','1' UNION ALL
	Select '10','3','1','2','0','1' UNION ALL
	Select '11','3','4','1','0','1' UNION ALL
	Select '12','4','1','1','0','1' UNION ALL
	Select '13','4','2','2','0','1' UNION ALL
	Select '14','5','1','1','0','1' UNION ALL
	Select '15','5','5','2','0','1' UNION ALL
	Select '16','6','1','1','0','1' UNION ALL
	Select '17','6','5','2','0','1' UNION ALL
	Select '18','7','5','2','0','1' UNION ALL
	Select '19','7','6','1','0','1' UNION ALL
	Select '20','7','7','3','0','1' UNION ALL
	Select '21','8','1','1','0','1' UNION ALL
	Select '22','8','4','2','0','1' UNION ALL
	Select '23','8','5','3','0','1' UNION ALL
	Select '24','9','1','3','0','1' UNION ALL
	Select '25','9','2','4','0','1' UNION ALL
	Select '26','9','6','1','0','1' UNION ALL
	Select '27','9','7','2','0','1' UNION ALL
	Select '28','10','1','1','0','1' UNION ALL
	Select '29','10','1','3','0','1' UNION ALL
	Select '30','10','2','2','0','1' UNION ALL
	Select '31','11','4','1','0','1' UNION ALL
	Select '32','12','1','0','0','1' UNION ALL
	Select '33','13','1','1','0','1' UNION ALL
	Select '34','13','3','2','0','1' UNION ALL
	Select '35','2','3','2','1','0' UNION ALL
	Select 36, 14, 12, 1, 0, 1 UNION ALL
	Select 37, 15, 12, 1, 0, 1 UNION ALL
	Select 38, 16, 2, 1, 0, 1 UNION ALL
	Select 39, 16, 13, 2, 0, 1 UNION ALL
	Select 40, 17, 13, 1, 0, 1 UNION ALL
	Select 41, 17, 2, 2, 0, 1 UNION ALL
	Select 43, 18, 9, 1, 0, 1 UNION ALL
	Select 44, 19, 3, 1, 0, 1
) 
AS Source (ID, FormID, ApproverID, ApprovalOrder, IsForNewCampus, IsForOldCampus) 
ON Target.ID = Source.ID
WHEN MATCHED THEN 
UPDATE SET 
	FormID = Source.FormID,
	ApproverID = Source.ApproverID,
	ApprovalOrder = Source.ApprovalOrder,
	IsForNewCampus = Source.IsForNewCampus,
	IsForOldCampus = Source.IsForOldCampus
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ID, FormID, ApproverID, ApprovalOrder, IsForNewCampus, IsForOldCampus) 
VALUES (ID, FormID, ApproverID, ApprovalOrder, IsForNewCampus, IsForOldCampus);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.ApproverHierarchy OFF;
