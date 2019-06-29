

MERGE INTO dbo.StatusTypes AS Target 
USING (
	Select 1, N'Not Assigned yet' UNION ALL
	Select 2, N'Pending' UNION ALL
	Select 3, N'Accepted' UNION ALL
	SELECT 4, N'Rejected' UNION ALL
	SELECT 5, N'N/A'  UNION ALL
	SELECT 6, N'New Application'
) 
AS Source ([StatusTypeID], [StatusType]) 
ON Target.StatusTypeID = Source.StatusTypeID
WHEN MATCHED THEN 
UPDATE SET 
	StatusType = Source.StatusType

WHEN NOT MATCHED BY TARGET THEN 
INSERT ([StatusTypeID], [StatusType]) 
VALUES ([StatusTypeID], [StatusType]);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

