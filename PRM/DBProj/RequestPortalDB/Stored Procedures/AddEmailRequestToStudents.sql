CREATE Procedure [dbo].[AddEmailRequestToStudents]
@Type int,
@RequestID int,
@ApproverId int,
@UniqueId varchar(40),
@statusText varchar(20),
@Remarks varchar(500),
@ApprovalDate datetime,
@msg varchar(100),
@subj varchar(100),
@prevApproverId int
As
BEGIN
	Declare @requester_email varchar(50)
	Declare @requester_name varchar(100)
	Declare @requester_rollno varchar(20)
	Declare @email_subj varchar(200)
	Declare @email_body varchar(500)
	Declare @username varchar(100)
	Declare @formName varchar(100)

	Declare @EmailDetails varchar (500)
	Declare @emailTemplate varchar(50)
	
	SET @email_body ='';

	Select @formName = upper(Category)
	from [dbo].[FormCategories] c INNER JOIN dbo.RequestMainData rmd ON c.CategoryID = rmd.CategoryID
	Where rmd.RequestID = @RequestID

	SELECT @requester_email = email,@requester_name = name,@requester_rollno = u.Login 
	from dbo.Users u INNER JOIN dbo.RequestMainData rmd on u.UserId = rmd.UserId and rmd.RequestID = @RequestID

	SELECT @username = DesigWithName 
	FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId

	if (@Type = 1)
		Begin		
			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar) + ' -  ACTION TAKEN';
			SET @emailTemplate = 'ActionPerformed_1S';
			--SET @email_body = 'Dear '+@requester_name+',<br><br> '+@username+' has '+@statusText+' your application. <br>-----<br>Roll no: ' + @requester_rollno + '<br>Name:'+@requester_name+'<br>Type:'+@formName+'<br>Remarks:TAG_REMARKS<br>For Detail: <a href="TAG_APP_URL">TAG_APP_URL</a><br>----<br><br>Request Portal';
			SET @EmailDetails ='TAG_REQUESTER_NAME:'+@requester_name+',TAG_USERNAME:'+@username+',TAG_STATUS:'+@statusText+',TAG_ROLLNO:'+@requester_rollno+',TAG_FORMTYPE:'+@formName+',TAG_REMARKS:'+@Remarks+',TAG_URL:';
		End

		if (@Type = 2)
		BEGIN	
			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar) + ' - APPLICATION IS CLOSED';
			SET @emailTemplate = 'ApplicationClosed_2S';
			SET @msg = 'Your application is closed now.';
			SET @EmailDetails = 'TAG_REQUESTER_NAME:'+@requester_name+',TAG_MESSAGE:'+@msg+',TAG_ROLLNO:'+@requester_rollno+',TAG_FORMTYPE:'+@formName+',TAG_URL:';

			-- SET @email_body = 'Dear '+@requester_name+',<br><br> Your application is closed now. <br>-----<br>Roll no: ' + @requester_rollno + '<br>Name:'+@requester_name+'<br>Type:'+@formName+'<br>Status:'+@msg+'<br>For Detail: <a href="TAG_APP_URL">TAG_APP_URL</a><br>----<br><br>Request Portal';
		END

		if (@Type = 3)
		Begin
			Declare @to_username varchar(100)
			SELECT @to_username = DesigWithName 
			FROM dbo.vwApproverWithDesig WHERE ApproverID = @prevApproverId

			SET @email_subj = 'ACAD/' + cast(@RequestID as varchar) + ' -  ACTION TAKEN';
			SET @emailTemplate = 'ApplicationReassigned_3S';
			SET @EmailDetails ='TAG_REQUESTER_NAME:'+@requester_name+',TAG_REASSIGNED_USER:'+@to_username+',TAG_ROLLNO:'+@requester_rollno+',TAG_FORMTYPE:'+@formName+',TAG_REMARKS:'+@Remarks+',TAG_URL:';
			
			--SET @email_body = 'Dear '+@requester_name+',<br><br> '+'Your application is re-assigned to ' +@to_username+'. <br>-----<br>Roll no: ' + @requester_rollno + '<br>Name:'+@requester_name+'<br>Type:'+@formName+'<br>Remarks:TAG_REMARKS<br>For Detail: <a href="TAG_APP_URL">TAG_APP_URL</a><br>----<br><br>Request Portal';
		End

		if (@Type = 4)
		BEGIN
			SET @email_subj = 'APPLICATION SUBMITTED - ACAD/' + cast(@RequestID as varchar);
			-- SET @email_body = 'Dear '+@requester_name+',<br><br> Application has been created. <br>-----<br>Roll no: ' + @requester_rollno + '<br>Name:'+@requester_name+'<br>Type:'+@formName+'<br>For Detail: <a href="TAG_APP_URL">TAG_APP_URL</a><br>----<br><br>Request Portal';
			SET @msg = 'Application has been created';
			SET @emailTemplate = 'ApplicationCreation_4S'
			
			SET @EmailDetails = 'TAG_REQUESTER_NAME:'+@requester_name+',TAG_MESSAGE:'+@msg+',TAG_ROLLNO:'+@requester_rollno+',TAG_FORMTYPE:'+@formName+',TAG_URL:';
		END

		if (@Type = 5)
		Begin
			SET @email_subj = 'Action on - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'CommentedOnApplication_5S';
			SET @msg = 'has commented on request';
			SET @EmailDetails ='TAG_REQUESTER_NAME:'+@requester_name+',TAG_MESSAGE:'+@msg+',TAG_USERNAME:'+@username+',TAG_ROLLNO:'+@requester_rollno+',TAG_FORMTYPE:'+@formName+',TAG_REMARKS:'+@Remarks+',TAG_URL:';

			-- SET @email_body = 'Dear '+@requester_name+',<br><br> ' + @username + ' has commented on request <a href="TAG_APP_URL">TAG_APP_URL</a> <br><br><b>Remarks:</b><br>----<br> TAG_REMARKS <br>----<br> Request Portal';
		End

		if (@Type = 6)
		Begin
			SET @email_subj = 'Action on - ACAD/' + cast(@RequestID as varchar);
			SET @emailTemplate = 'ReviewAsked_6S';
			SET @msg = 'You have asked for review.';
			SET @EmailDetails ='TAG_REQUESTER_NAME:'+@requester_name+',TAG_MESSAGE:'+@msg+',TAG_REMARKS:'+@Remarks+',TAG_FORMTYPE:'+@formName+',TAG_ROLLNO:'+@requester_rollno+',TAG_URL:';
			--SET @temp_email_body = 'Dear '+@username+',<br><br> You have asked for review on request <a href="TAG_APP_URL">TAG_APP_URL</a> <br><br><b>Review:</b><br>----<br> TAG_REMARKS <br>----<br> Request Portal';

		End

		INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID,RequestID,EmailDetails, EmailTemplate)
		Select @email_subj, @email_body, @requester_email, 1, 1,@UniqueId,@RequestID, @EmailDetails, @emailTemplate
END