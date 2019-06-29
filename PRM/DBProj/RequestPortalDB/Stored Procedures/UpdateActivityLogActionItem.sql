

CREATE Procedure [dbo].[UpdateActivityLogActionItem]
	@RequestID int,
	@ActID int,
	@DateTime datetime,
	@UserId int,
	@type int,
	@value int,
	@ReqUniqueId varchar(40)
As 
Begin

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			Select cast(0 as int);
			return;
		END



	IF @type = 1 
	BEGIN
	 Update [dbo].[ActivityLogTable]
	 SET VisibleToUserID = @value, UpdatedTime = @DateTime
	 Where Id = @ActID and UserId = @UserId and RequestId = @RequestID
	END

	IF @type = 2
	BEGIN
	 Update [dbo].[ActivityLogTable]
	 SET CanReplyUserID = @value, UpdatedTime = @DateTime
	 Where Id = @ActID and UserId = @UserId and RequestId = @RequestID
	END
	  
	select cast(1 as int)
End





