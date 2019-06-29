
CREATE Procedure [dbo].[UpdateDemandFormIssuedQty]
	@qty int,
	@id int,
	@CategoryId int
As 
Begin
	if @CategoryId = 14 --For Item Demand Application
	BEGIN
		Update [dbo].[DemandForm] 
		SET IssuedQty = @qty
		Where [dbo].[DemandForm].demandId  =@id
	END

	ELSE IF @CategoryId = 15 -- For Hardware Demand application
	BEGIN
		Update [dbo].[HardwareForm] 
		SET IssuedQty = @qty
		Where [dbo].[HardwareForm].demandId  =@id
	END
	
End


