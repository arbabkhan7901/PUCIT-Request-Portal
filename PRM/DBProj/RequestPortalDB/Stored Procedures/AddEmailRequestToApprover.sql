CREATE Procedure [dbo].[AddEmailRequestToApprover]
@Type int,
@RequestID int,
@ApproverId int,
@UniqueId varchar(40),
@statusText varchar(20),
@Remarks varchar(500),
@ApprovalDate datetime,
@nextApproverId int
As
BEGIN
			Declare @email_subj varchar(200)
			Declare @email_body varchar(500)
			Declare @to_email varchar(50)
			Declare @username varchar(100)
			Declare @formName varchar(100)
			Declare @requester_email varchar(50)
			Declare @requester_name varchar(100)
			Declare @requester_rollno varchar(20)

			Declare @EmailDetails varchar (500)
			Declare @emailTemplate varchar(50)
			Declare @msg varchar(100)
	
			SET @email_body ='';

			SELECT @requester_email = email,@requester_name = name,@requester_rollno = u.Login 
			from dbo.Users u INNER JOIN dbo.RequestMainData rmd on u.UserId = rmd.UserId and rmd.RequestID = @RequestID

			Select @formName = upper(Category)
			from [dbo].[FormCategories] c INNER JOIN dbo.RequestMainData rmd ON c.CategoryID = rmd.CategoryID
			Where rmd.RequestID = @RequestID

			-- Get email & Login of Approver
			SELECT @to_email = email, @username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId

	if (@Type = 1)
		Begin		
			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable, VisibleToUserID,CanReplyUserID)
			Values(@RequestID, @ApproverID, @Remarks, @username + '  has ' + @statusText +' it.',@ApprovalDate,1,0,0)

			SET @email_subj =  'ACAD/' + cast(@RequestID as varchar) + ' - ' + upper(@statusText) + ' By You';
			SET @emailTemplate = 'ActionPerformed_1A';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_STATUS:'+@statusText+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_FORMTYPE:'+@formName+',TAG_REMARKS:'+@Remarks+',TAG_URL:';

		End

		if (@Type = 2)
		BEGIN
			SELECT @to_email = email, @username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @nextApproverId

			SET @email_subj = 'ASSIGNMENT ALERT - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'ApplicationAssigned_2A';
			SET @msg = 'An application has been assigned to you for your review.';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_FORMTYPE:'+@formName+',TAG_URL:';


			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable, VisibleToUserID,CanReplyUserID)
			Values(@RequestID, @ApproverID, 'Assigned By System', 'Request is assigned to ' + @username,@ApprovalDate,0,0,0)
		END	
		
		if (@Type = 3)
		Begin
			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar) + ' unassigned from you.';
			SET @emailTemplate = 'ApplicationUnAssigned_3A';
			SET @msg ='An application is unassigned from you.';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';


			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
			Values(@RequestID, @ApproverID, @Remarks, 'Request is [Routed Back] By ' + @username + ' to previous approver',@ApprovalDate)
		End	

		if (@Type = 4)
		Begin
			Declare @to_username varchar(100)
			SELECT @to_email = email, @to_username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @nextApproverId

			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar)+ ' re-assigned to you.';
			SET @msg = 'has routed back an application. Application is re-assigned to you.';
			SET @emailTemplate = 'ApplicationReassigned_4A';
			SET @EmailDetails = 'TAG_TO_USERNAME:'+@to_username+',TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';



			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
			Values(@RequestID, @ApproverID, 'Routed Back:' + @Remarks, 'Request is re-assigned to ' + @to_username,@ApprovalDate)
		End

		if (@Type = 5) -- because 3 and 5 are same.. 
		Begin
			
			SELECT @to_email = email, @username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @nextApproverId

			SET @emailTemplate = 'ApplicationUnAssigned_3A';
			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar) + ' unassigned from you.';
			SET @msg ='An application is unassigned from you.';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';

		End

		if(@Type = 6) -- because 2 and 6 are same..
		Begin
			SELECT @to_email = email, @username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @nextApproverId

			SET @email_subj = 'ASSIGNMENT ALERT - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'ApplicationAssigned_2A';
			SET @msg = 'An application has been assigned to you for your review.';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_ROLLNUMBER:'+@requester_rollno+',TAG_REQUESTER_NAME:'+@requester_name+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';
		End

		if (@Type = 7)
		Begin

			SET @email_subj = 'Action on - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'CommentedOnApplication_7A';
			SET @msg = 'You have commented on request';
			SET @EmailDetails = 'TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';

		End

		if (@Type = 8)
		Begin
			Declare @username2 varchar (50)
			SELECT @to_email = email, @username2 = DesigWithName FROM dbo.vwApproverWithDesig WHERE ApproverID = @nextApproverId
			SET @email_subj = 'Action on - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'SomeOneCommented_8A';
			SET @msg = 'has commented on request';
			SET @EmailDetails = 'TAG_USERNAME2:'+@username2+',TAG_USERNAME:'+@username+',TAG_MESSAGE:'+@msg+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';

		End

		if (@Type = 9)
		Begin
			
			SET @email_subj = 'Action on - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'ReviewAsked_9A';
			SET @msg = 'has asked for review on request';
			SET @EmailDetails = 'TAG_USERNAME2:'+@username+',TAG_USERNAME:'+@requester_name+',TAG_MESSAGE:'+@msg+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_URL:';

		End
			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID,RequestID,EmailTemplate, EmailDetails)
			Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId,@RequestID,@emailTemplate, @EmailDetails
END