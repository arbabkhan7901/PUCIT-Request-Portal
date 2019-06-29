CREATE TABLE [dbo].[Designations] (
    [DesignationID] INT          IDENTITY (1, 1) NOT NULL,
    [Designation]   VARCHAR (50) NOT NULL,
    [IsActive]      BIT          CONSTRAINT [DF_ApproverDesig_IsActive] DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([DesignationID] ASC)
);

