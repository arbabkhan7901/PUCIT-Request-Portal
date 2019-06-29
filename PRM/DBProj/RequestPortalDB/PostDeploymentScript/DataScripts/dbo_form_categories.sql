

MERGE INTO dbo.FormCategories AS Target 
USING (
Select '1','Clearance Form','1','0',1,'In order to apply for the clearance form it is necessary that your dues are paid and that you are clear of any charges from the accounts office or library.' UNION ALL
Select '2','Leave Application Form','0','0',1,'You must have a legitimate reason when applying for the leave application form. In case there is a medical issue you must attach medical certificate as proof which should be verified by PU Medical Officer.
Leave on medical ground will be governed as PUCIT statues and regulations.
Leave will not be counted as presence towards attendance requirements.' UNION ALL
Select '3','Option for Bsc Degree Form','0','0',1,'This is only available for students who have completed at least 2 years of their bachelor’s degree.' UNION ALL
Select '4','Final Academic Transcript Form','0','1',1,'Student must attach copy of Clearance form, the final academic transcript will be issued on completion of degree.' UNION ALL
Select '5','College ID Card Form','0','1',1,'The college id card will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form.' UNION ALL
Select '6','Vehical Token Form','0','1',1,'You need to attach a copy  of your college id card, a copy of the vehicle’s registration and a photograph.' UNION ALL
Select '7','Reciept of Orignal Documents Form','0','1',1,'' UNION ALL
Select '8','Bonafide Character Certificate Form','0','1',1,'If you are applying for the bonafide certificate form before completion of your degree then you need to deposit Rs 250/- otherwise you dont have to pay any fee.' UNION ALL
Select '9','Semester Freeze/Withdraw Form','0','0',1,'' UNION ALL
Select '10','Semester Rejoin Form','0','0',1,'' UNION ALL
Select '11','Semester Academic Transcript Form','0','0',1,'The semester (s) academic transcript will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form' UNION ALL
Select '12','Course Withdraw Form','0','0',1,'Maximum 50% courses of a semester can be withdrawn' UNION ALL
Select '13','General Request Form','0','0',1,'Please write a suitable title for your request. In case there are any attachments, name them precisely.' UNION ALL
Select '14', 'Item Demand Requisition Form', 0, 1, 1, 'Item Demand Requisition Form' UNION ALL
Select 15, 'Hardware Request Form', 0, 1, 1, 'Please proceeed' UNION ALL
Select 16, 'Demand Voucher Form', 0, 1, 1, 'Please proceeed' UNION ALL
Select 17, 'Store Demand Voucher Form', 0, 1, 1, 'Store Demand Voucher' UNION ALL
Select 18, 'Lab Reservation Form', 0, 1,1, 'Lab Reservation' UNION ALL
SELECT 19, 'Room Reservation Form', 0, 1, 1, 'Room Reservation '
) 
AS Source (CategoryID, Category, IsParalApprovalAllowed, IsRecievingAllowed,MaxPendingRequets, Instructions) 
ON Target.CategoryID = Source.CategoryID
WHEN MATCHED THEN 
UPDATE SET 	
	Category = Source.Category,
	IsParalApprovalAllowed = Source.IsParalApprovalAllowed,
	IsRecievingAllowed = Source.IsRecievingAllowed,
	Instructions = Source.Instructions,
	MaxPendingRequets = Source.MaxPendingRequets
WHEN NOT MATCHED BY TARGET THEN 
INSERT (CategoryID, Category, IsParalApprovalAllowed, IsRecievingAllowed,MaxPendingRequets, Instructions) 
VALUES (CategoryID, Category, IsParalApprovalAllowed, IsRecievingAllowed,MaxPendingRequets, Instructions);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;


