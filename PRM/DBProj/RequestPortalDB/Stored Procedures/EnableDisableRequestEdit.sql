
CREATE Procedure [dbo].[EnableDisableRequestEdit]
	@RequestID int,
	@DateTime datetime,
	@ApproverId int,
	@flag bit,
	@remarks varchar(200),
	@ReqUniqueId varchar (40)
As 
Begin

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			SELECT cast(0 as int)
		END

		ELSE
		BEGIN

	   Update dbo.RequestMainData Set CanStudentEdit = @flag, [LastModifiedOn] = @DateTime Where RequestID = @RequestID

	   Declare @text varchar(20) = 'disabled'

	   if @flag = 1
	   begin
		Set @text = 'enabled'
	   end

		Declare @username varchar(100)

		SELECT @username = DesigWithName 
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @ApproverId,'Application is ' + @text + ' for editing: ' + @remarks , @username + ' updated request.' ,@DateTime,0,0,0)
	
		Select @RequestID
		END
End






