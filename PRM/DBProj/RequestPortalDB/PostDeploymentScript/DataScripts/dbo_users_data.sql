


SET IDENTITY_INSERT dbo.users ON


MERGE INTO dbo.users AS Target 
USING (
	Select '8','test1','123111','Mehwish Khurshid','Student Affairs Coordinator','bilal.shahzad@pucit.edu.pk','1','bfb541e6-f191-4f04-961c-f1881a3aaee4.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1010','test2','123','Dr. Syed Masoor Sarwar','Principal','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1015','test3','123','Amir Raza','Program Coordinator','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1016','Asim Rasul','123','Asim Rasul','Exam Coordinator','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1017','Shakeel','123','Shakeel','Admin Officer','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1018','Adnan','123','Adnan','Assistant Treasurer','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1019','Librarian','123','librarian','Librarian','bilal.shahzad@yahoo.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1020','BITF13M077','123','Sabah','','bilal.shahzad@yahoo.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','0','1' UNION ALL
	Select '1021','BITF13M005','123','Maryam','Student','bilal.shahzad@gmail.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','0','1' UNION ALL
	Select '1022','Secretary','123','Secretary DC','Secretary DC','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	Select '1023','Rizwan','123','Rizwan','Network Admin','bilal.shahzad@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
	SELECT 1025, N'Admin', '123', N'Admin', N'Admin', N'bilal.shahzad@pucit.edu.pk', 1, N'c59e908a-bffc-43c0-a865-6bd59e8c21f7.png', N'ABC', N'BSSE (AFTERNOON)', 0, 1 UNION ALL
	SELECT 55, N'teacher', '123', N'Mr. Mubasher', N'Teacher', N'bilal.shahzad@pucit.edu.pk', 1, N'c59e908a-bffc-43c0-a865-6bd59e8c21f7.png', N'ABC', N'', 1, 1 UNION ALL
	SELECT 1027, N'manager', N'123', N'Muhammad Suleman', N'Store Keeper', N'bilal.shahzad@pucit.edu.pk',1,N'f0e9ad33-99f8-487e-b02c-b65b14cb0325.jpg', NULL, N'Morning & AfterNoon', 1, 1 UNION ALL
	SELECT 1028, N'account', N'123', N'naeem', N'account officer', N'asma.eadf15@gmail.com',1, NULL, N'ABC', N'Morning', 1, 1 
) 
AS Source (UserId, Login, Password, Name, Title, Email, isActive, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus) 
ON Target.UserId = Source.UserId
WHEN MATCHED THEN 
UPDATE SET 
	Login = Source.Login,
	Password = Source.Password,
	Name = Source.Name,
	Title = Source.Title,
	Email = Source.Email,
	SignatureName = Source.SignatureName,
	StdFatherName = Source.StdFatherName,
	Section = Source.Section,
	IsContributor = Source.IsContributor,
	IsOldCampus = Source.IsOldCampus,
	IsActive = Source.IsActive,
	IsDisabledForLogin = 1,
	ResetToken = null
WHEN NOT MATCHED BY TARGET THEN 
INSERT (UserId, Login, Password, Name, Title, Email, isActive, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus) 
VALUES (UserId, Login, Password, Name, Title, Email, isActive, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.users OFF;

