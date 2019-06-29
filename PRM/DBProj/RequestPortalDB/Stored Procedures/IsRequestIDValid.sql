

CREATE Procedure [dbo].[IsRequestIDValid]
	@requestId int,
	@userid int,
	@accessType int
AS 
BEGIN

	if @accessType = 1  --It means self created
	BEGIN
		SELECT count(*) from [dbo].[RequestMainData] where RequestID = @requestId and UserID = @userid
	END
	ELSE if @accessType = 2  --It means assigned
	BEGIN
		Select count(*) from [dbo].[ReqWorkflow] where RequestID = @requestId and ApproverID = @userid
	END
	ELSE if @accessType = 4 --It means All
	BEGIN
		Select 1
	END

END












