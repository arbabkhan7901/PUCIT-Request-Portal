CREATE Procedure [dbo].[getItemQuantityFromItemsTable]
	
	@id int
As 
Begin
	 SELECT Quantity FROM [dbo].[Items] WHERE ItemId=@id
End







