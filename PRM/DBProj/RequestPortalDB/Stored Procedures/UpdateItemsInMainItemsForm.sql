CREATE Procedure [dbo].[UpdateItemsInMainItemsForm]
	@qty int,
	@id int
As 
Begin
	
	Update [dbo].[Items] 
	SET Quantity = Quantity-@qty
	--from [dbo].[DemandForm] t inner join dbo.Items rmc on t.ItemId = rmc.ItemId
	Where [dbo].[Items].ItemId  =@id
	
End
