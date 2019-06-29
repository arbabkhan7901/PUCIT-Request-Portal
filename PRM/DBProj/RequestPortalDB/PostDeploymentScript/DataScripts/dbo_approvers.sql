
SET IDENTITY_INSERT dbo.Approvers ON

MERGE INTO dbo.Approvers AS Target 
USING (
	Select '1','1',8,'1' UNION ALL
	Select '2','2',1010,'1' UNION ALL
	Select '3','3',1015,'1' UNION ALL
	Select '4','4',1016,'1' UNION ALL
	Select '5','5',1017,'1' UNION ALL
	Select '6','6',1018,'1' UNION ALL
	Select '7','7',1019,'1' UNION ALL
	Select '8','8',1022,'1' UNION ALL
	Select '9','9',1023,'1' UNION ALL
	Select '10','10',8,'1' UNION ALL
	Select 11,10,55,1 UNION ALL
	Select 12,11,1027,1 UNION ALL
	Select 13,12,1028,1 
) 
AS Source (ApproverID, DesignationID, UserID, IsActive) 
ON Target.ApproverID = Source.ApproverID
WHEN MATCHED THEN 
UPDATE SET 
	DesignationID = Source.DesignationID,
	UserID = Source.UserID,
	IsActive = Source.IsActive
WHEN NOT MATCHED BY TARGET THEN 
INSERT (ApproverID, DesignationID, UserID, IsActive) 
VALUES (ApproverID, DesignationID, UserID, IsActive);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.Approvers OFF;
