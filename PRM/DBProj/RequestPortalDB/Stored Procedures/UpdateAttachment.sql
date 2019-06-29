

CREATE Procedure [dbo].[UpdateAttachment]
	@RequestID int,
	@attachment varchar(50),
	@Datetime datetime,
	@UserId int,
	@oldattachment varchar(50),
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


	   Declare @fileName varchar(50)
	   Select @fileName = typeName from dbo.AttachmentTypes where AttachmentTypeID = (Select AttachmentTypeID from dbo.Attachments Where [FileName] = @oldattachment)
	   
	   Update dbo.Attachments SET FileName = @attachment Where FileName = @oldattachment

		Declare @username varchar(100)
		Select @username= Title + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, '[' + @fileName + '] is uploaded again', @username + ' updated a file.' ,@Datetime,0,0,0)
	
		Select @RequestID
End






