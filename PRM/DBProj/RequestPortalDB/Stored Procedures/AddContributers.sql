---------------------------------

CREATE PROCEDURE [dbo].[AddContributers]
      @FormID int,
      @ApproverID int,
      @AltApproverID int,
      @ApprovalOrder int,
      @IsForNewCampus bit,
      @IsForOldCampus bit
AS
BEGIN
	INSERT INTO dbo.ApproverHierarchy(
      [FormID] ,
      [ApproverID] ,
      [AltApproverID] ,
      [ApprovalOrder] ,
      [IsForNewCampus] ,
      [IsForOldCampus] )
	VALUES(@FormID,@ApproverID,NULL,@ApprovalOrder,@IsForNewCampus,@IsForOldCampus)
	select @FormID=scope_identity()
	select @FormID
END













