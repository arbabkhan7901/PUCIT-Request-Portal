

CREATE Procedure [dbo].[SaveAttachment]
	@RequestID int,
	@fileName varchar(100),
	@attachment varchar(50),
	@CreationDate datetime,
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


	   Declare @typeId int
	   Select @typeId = AttachmentTypeID from dbo.AttachmentTypes where typeName = @fileName

	   if @typeId is null
	   Begin
		INSERT INTO dbo.AttachmentTypes(typeName) 
		Select @fileName
		Select @typeId = SCOPE_IDENTITY()
	   End 
	   
	   Insert into dbo.Attachments(RequestID, AttachmentTypeID, UploadDate, IsActive, FileName)
	   Select @RequestID, @typeId, @CreationDate, 1, @attachment


		Declare @username varchar(100)
		Select @username= Title + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, '[' + @fileName + '] is uploaded', @username + ' uploaded a file.' ,@CreationDate,0,0,0)
	
		Select @RequestID
End






