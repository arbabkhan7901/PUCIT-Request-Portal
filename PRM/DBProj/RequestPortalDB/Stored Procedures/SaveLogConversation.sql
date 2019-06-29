

CREATE Procedure [dbo].[SaveLogConversation]
	@RequestId int,
	@ActivityLogID bigint,
	@UserID int,
	@accessType int,
	@MessageTime datetime,
	@Message varchar(200),
	@ApproverId int,
	@ReqUniqueId varchar(40)
As 
Begin

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			Select cast(0 as bigint);
			return;
		END
		
		declare @id int = @UserID
		if @accessType =2 --Assigned
		begin
			Set @id = @ApproverId
		end

		if dbo.IsValidLogId(@RequestId,@ActivityLogID,@id,@accessType,@ReqUniqueId) = 1
		begin
			INSERT INTO [dbo].[ActivityLogConversations](ActivityLogID, UserID, Message, MessageTime)
			Values(@ActivityLogID,@UserID,@Message,@MessageTime)
			Select cast(SCOPE_IDENTITY() as bigint)
		end
		else
		begin
			select cast(-1 as bigint)
		end
		
End





