
CREATE Procedure [dbo].[HandleRecieving]
	@RequestID int,
	@ApproverId int,
	@CreationDate datetime,
	@Comment varchar(200),
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

		Update dbo.RequestMainData SET IsRecievingDone = 1 where RequestID = @RequestID

		Declare @username varchar(100)

		SELECT @username=DesigWithName
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId


		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable)
		Values(@RequestID, @ApproverId, @Comment, @username + ' has performed recieving activity.' ,@CreationDate,0)
	
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable)
		Values(@RequestID, @ApproverId, '', 'Application is closed now!' ,@CreationDate,0)

		Select @RequestID
End







