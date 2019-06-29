
CREATE Procedure [dbo].[UpdateCGPA]
	@RequestID int,
	@CGPA float,
	@DateTime datetime,
	@ApproverId int,
	@otherUserLogin varchar(50),
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


	
	-- Append in comment if A user is doing this on behalf of
	if(@otherUserLogin != '')
		SET @otherUserLogin = '---------[By '+@otherUserLogin+' on behalf of]'

	Declare @old_cgpa float =0

	select @old_cgpa=isnull(CGPA,0) from [dbo].[BonafideCertificateData] Where RequestID  = @RequestID

	Update t SET CGPA = @CGPA, UpdatedTime = @DateTime, ModifiedBy = @ApproverId
	from [dbo].[BonafideCertificateData] t inner join dbo.RequestMainData rmc on t.RequestID = rmc.RequestID and rmc.CategoryID = 8
	Where t.RequestID  = @RequestID  
	 
	
	Declare @username varchar(100)
		
	SELECT @username = DesigWithName 
	FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId
	
	INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID,ShowActionPanel)
	Values(@RequestID, @ApproverId, 'CGPA is updated from ['+cast(@old_cgpa as varchar)+'] to ['+ cast(@CGPA as varchar)+']' + @otherUserLogin, @username + ' update CGPA.' ,@DateTime,0,0,0,0)
	

	  
	select cast(1 as int)
End






