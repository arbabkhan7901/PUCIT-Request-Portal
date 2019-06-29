CREATE procedure [dbo].[SaveGmailLoginRequest]
@Email varchar(100),
@Name varchar(100),
@Gmail_Id varchar(50),
@Gmail_Pic varchar(200),
@CreatedOn datetime,
@UniqueID varchar(40)
As
Begin



	DECLARE @ID BIGINT = 0

	if(Exists(Select * from dbo.Users where Email = @Email))
	BEGIN
		SET @ID = -1
	END
	ELSE
	BEGIN
		Declare @IsUsed bit = 0
		SELECT @ID = ID, @IsUsed = IsUsed FROM dbo.GmailLoginRequests WHERE Email = @Email
		IF ISNULL(@ID,0) > 0
		BEGIN
			UPDATE dbo.GmailLoginRequests 
			SET EntryTime = @CreatedOn,  Name = @Name, Gmail_Id = @Gmail_Id,Gmail_Pic = @Gmail_Pic
			WHERE ID = @ID AND IsUsed = 0
		END
		ELSE
		BEGIN
			
			Declare @email_subj varchar (50)
			Declare @email_details_Requester varchar (500)
			Declare @email_details_Admin varchar (500)

			Declare @msg_requester varchar (500)
			Declare @msg_admin varchar (500)

			Declare @email_template varchar(50)

			SET @email_subj = 'New User Request via Google Login - Request Portal';
			SET @email_template = 'SaveGmailLoginRequest';


			SET @msg_admin = 'A user with Email '+@Email +' and Name '+ @Name+' is requested to be the part of the systemm';
			SET @email_details_Admin = 'TAG_MSG:'+@msg_admin;

			SET @msg_requester = 'Your user does not exist in our system. Your request is noted. We''ll let you know once your user is created.';
			SET @email_details_Requester ='TAG_MSG:'+@msg_requester;

			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID,RequestID,EmailTemplate, EmailDetails)
			Select @email_subj,'', 'asmamunir731@gmail.com', 1, 1,@UniqueId,0, @email_template, @email_details_Admin
			UNION ALL
			Select @email_subj,'', @Email, 1, 1,@UniqueId,0,@email_template,@email_details_Requester

			INSERT INTO dbo.GmailLoginRequests(Email, Name, Gmail_Id, Gmail_Pic, EntryTime, IsUsed)
			Select @Email,@Name,@Gmail_Id,@Gmail_Pic,@CreatedOn,0
			SET @ID = SCOPE_IDENTITY()
		END
	END

	Select @ID
End







