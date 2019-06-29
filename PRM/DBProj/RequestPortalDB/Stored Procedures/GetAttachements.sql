
CREATE PROCEDURE [dbo].[GetAttachements]
	@RequestId int,
	@ReqUniqueId varchar (40)
AS
BEGIN
	Declare @tempReqId int = 0
	Select @tempReqId = rmd.RequestId 
	from RequestMainData rmd 
	where rmd.ReqUniqueId= @ReqUniqueId

	IF (@tempReqId <> @RequestID)
	BEGIN
		return NULL;
	END

	ELSE
	BEGIN
		Select * from [dbo].[Attachments] attach where attach.RequestID = @RequestId AND attach.IsActive=1
	END

END





