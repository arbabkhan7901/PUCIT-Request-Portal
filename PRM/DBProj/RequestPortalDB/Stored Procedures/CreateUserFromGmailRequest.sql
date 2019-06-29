CREATE Procedure [dbo].[CreateUserFromGmailRequest]
@Email varchar(100),
@RoleId int,
@CreatedOn datetime,
@UniqueID varchar(40)
As
Begin

	if(Exists(Select * from dbo.Users where Email = @Email))
	BEGIN
		Select cast(-1 as int);
	END
	ELSE
	BEGIN

		Declare @Name varchar(100) ='';
		Declare @GmailRequestID bigint = 0;

		SELECT @GmailRequestID = ID, @Name = Name FROM dbo.GmailLoginRequests WHERE Email = @Email AND IsUsed = 0 

		IF(ISNULL(@GmailRequestID,0) > 0)
		BEGIN
			Declare @Login varchar(100) = ''
			Declare @Title varchar(100) = ''
			Declare @section varchar(10) = ''
			Declare @emailPrefix varchar(3) =''
			Declare @isoldcampus bit = 1
			Declare @atposition int = charindex('@',@Email);
		 
			Select @Login = left(@Email, @atposition-1)
			Select @emailPrefix = left(@Email, 3)
		
			if(@emailprefix = 'BCS' OR @emailprefix = 'BIT' OR @emailprefix = 'BSE' OR @emailprefix = 'MCS' OR @emailprefix = 'PHD')
			BEGIN
				SET @Title = 'Student';
				Select @section = left(@Email, @atposition-4)

				Declare @roll_no int =0
				select @roll_no  = substring(@Email, @atposition-3,3)
				if(@roll_no >= 500)
					SET @isoldcampus =0
			END

			Declare @UserId int = 0
			INSERT INTO dbo.Users(Login, Password, Name, Title, Email, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus, CreatedBy, CreatedOn, IsActive, IsDisabledForLogin)
			Select @Login,'123',@Name,@Title,@Email,'','',@section,0,@isoldcampus,1,@CreatedOn,1,0

			select @UserId =  scope_identity();

			insert into [dbo].[UserRoles](UserId, RoleId)
			select @UserId,@RoleId

			Update dbo.GmailLoginRequests Set UserId = @UserId, UserCreatedOn = @CreatedOn, IsUsed = 1 Where ID = @GmailRequestID
			
			Declare @email_subj varchar(200)
			Declare @email_body varchar(500)
			Declare @emailTemplate varchar(50)
			Declare @emailDetails varchar(500)

			SET @email_subj = 'Account Creation Request - Request Portal';
			SET @email_body ='';
			SET @emailTemplate = 'CreateUserFromGmail' ;
			SET @emailDetails = 'TAG_NAME:'+@Name+',TAG_LOGIN:'+@Email +',TAG_URL:';

			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID,RequestID, EmailTemplate, EmailDetails)
			Select @email_subj, @email_body, @Email, 1, 1,@UniqueID,0, @emailTemplate, @emailDetails
			

			--Select 'Account Creation Request - Request Portal','Dear '+@Name+',<br><br> Your user is created. Please go to <a href="TAG_APP_URL">TAG_APP_URL</a> and set your password using [Forgot Password] option or use Login with Gmail<br>......<br>Your Login:'+@Email+'<br>.....<br><br>Request Portal' , @Email, 1, 1,@UniqueID,0


			Select @UserId
		END
		ELSE
			SELECT cast(-1 as int);
	END
End







