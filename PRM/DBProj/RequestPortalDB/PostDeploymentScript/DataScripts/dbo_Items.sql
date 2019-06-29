
SET IDENTITY_INSERT dbo.Items On 

Merge Into dbo.Items AS Target
Using(

	SELECT 9, N'Duster(in no.)', 251, N'From Regular Budget', 22, 0, 1,GETDATE() UNION ALL
	SELECT 11, N'Pens(per pack of 6)', 200, N'From Regular Budget', 11, 1, 1,GETDATE() UNION ALL
	SELECT 12, N'NotePad(in no.)', 213, N'From Regular Budget', 11, 1, 1,GETDATE() UNION ALL
	SELECT 13, N'Marker(per pack of 6)', 206, N'From Regular Budget', 11, 1, 1,GETDATE() UNION ALL
	SELECT 14, N'Tea Bags(in no.)', 190, N'From Regular Budget', 11, 0, 1,GETDATE() UNION ALL
	SELECT 15, N'Cups', 110, N'From Regular Budget', 11, 1, 1,GETDATE() UNION ALL
	SELECT 16, N'Ram', 98, N'From College Fund', 22, 1, 1,GETDATE() UNION ALL
	SELECT 17, N'Network Cable', 98, N'From College Fund', 22, 0, 1,GETDATE() UNION ALL
	SELECT 18, N'Plates', 100, N'From College Fund', 11, 1, 1,GETDATE() UNION ALL
	SELECT 20, N'abc', 0, N'abc', 22, 0, 1, GETDATE()  UNION ALL
	SELECT 21, N'abc', 0, N'abc', 11, 1, 1, GETDATE()

)
As Source (ItemId, ItemName, Quantity,Description, Type, IsActive, CreatedBy, CreatedOn)
ON Target.ItemId = Source.ItemId

WHEN MATCHED THEN
UPDATE SET 
	ItemName = Source.ItemName,
	Quantity = Source.Quantity,
	Description = Source.Description,
	Type = Source.Type,
	IsActive =Source.IsActive
WHEN NOT MATCHED BY TARGET THEN
INSERT (ItemId, ItemName, Quantity,Description, Type, IsActive, CreatedBy, CreatedOn)
VALUES (ItemId, ItemName, Quantity,Description, Type, IsActive, CreatedBy, CreatedOn);

SET IDENTITY_INSERT dbo.Items OFF;