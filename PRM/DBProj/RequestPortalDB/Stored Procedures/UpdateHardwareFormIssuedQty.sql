CREATE Procedure [dbo].[UpdateHardwareFormIssuedQty]
	@qty int,
	@id int
As 
Begin
	Update [dbo].[HardwareForm] 
	SET IssuedQty = @qty
	--from [dbo].[HardwareForm] t inner join dbo.Items rmc on t.ItemId = rmc.ItemId
	Where [dbo].[HardwareForm].demandId  =@id
End







