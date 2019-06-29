CREATE Procedure [dbo].[UpdateHardwareItemsinMainItemsForm]
	@qty int,
	@id int
As 
Begin
	
	Update [dbo].[HardwareItems] 
	SET Quantity = Quantity-@qty
	--from [dbo].[DemandForm] t inner join dbo.Items rmc on t.ItemId = rmc.ItemId
	Where [dbo].[HardwareItems].ItemId  =@id
	
End






