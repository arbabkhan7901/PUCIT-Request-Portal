
SET IDENTITY_INSERT dbo.AttachmentTypes ON

MERGE INTO dbo.AttachmentTypes AS Target 
USING (
	Select '1','College ID Card' UNION ALL
	Select '2','Challan Form' UNION ALL
	Select '3','Medical' UNION ALL
	Select '4','Bonafide' UNION ALL
	Select '5','Applicant CNIC' UNION ALL
	Select '6','Clearance Form' UNION ALL
	Select '7','Motor Cycle Registration' UNION ALL
	Select '8','Photograph' UNION ALL
	Select '9','Other' UNION ALL
	Select '10','Father''s CNIC' UNION ALL
	SELECT 11, N'cxv' UNION ALL
	SELECT 12, N'cvx' UNION ALL
	SELECT 13, N'abc' UNION ALL
	SELECT 14, N'abc'
) 
AS Source (AttachmentTypeID, typeName) 
ON Target.AttachmentTypeID = Source.AttachmentTypeID
WHEN MATCHED THEN 
UPDATE SET 
	typeName = Source.typeName

WHEN NOT MATCHED BY TARGET THEN 
INSERT (AttachmentTypeID, typeName) 
VALUES (AttachmentTypeID, typeName);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.AttachmentTypes OFF;
