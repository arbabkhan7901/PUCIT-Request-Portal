CREATE TABLE [dbo].[Approvers] (
    [ApproverID]    INT IDENTITY (1, 1) NOT NULL,
    [UserID]        INT NOT NULL,
    [IsActive]      BIT CONSTRAINT [DF_Approvers_IsActive] DEFAULT ((1)) NOT NULL,
    [DesignationID] INT NULL,
    CONSTRAINT [PK_Approvers] PRIMARY KEY CLUSTERED ([ApproverID] ASC)
);

