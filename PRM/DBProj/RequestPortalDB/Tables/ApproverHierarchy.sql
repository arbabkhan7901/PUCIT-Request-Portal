CREATE TABLE [dbo].[ApproverHierarchy] (
    [ID]             INT IDENTITY (1, 1) NOT NULL,
    [FormID]         INT NOT NULL,
    [ApproverID]     INT NOT NULL,
    [AltApproverID]  INT NULL,
    [ApprovalOrder]  INT NOT NULL,
    [IsForNewCampus] BIT NULL,
    [IsForOldCampus] BIT NULL,
    CONSTRAINT [PK_ApproverHierarchy] PRIMARY KEY CLUSTERED ([ID] ASC)
);



