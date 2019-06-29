
CREATE Procedure [dbo].[RemoveAttachment]
	@RequestID int,
	@attachment varchar(50),
	@DateTime datetime,
	@UserId int,
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


	   Update dbo.Attachments SET IsActive = 0 Where [FileName] = @attachment

	   Declare @fileName varchar(50)
	   
	   Select @fileName = typeName from dbo.AttachmentTypes where AttachmentTypeID = (Select AttachmentTypeID from dbo.Attachments Where [FileName] = @attachment)

	   Declare @username varchar(100)
		Select @username= Title + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, 'Attachment [' + @fileName + '] has been removed', @username + ' removed a file.' ,@DateTime,0,0,0)
	
		Select @RequestID
End





