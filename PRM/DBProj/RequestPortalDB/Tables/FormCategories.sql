CREATE TABLE [dbo].[FormCategories] (
    [CategoryID]             INT           NOT NULL,
    [Category]               VARCHAR (100) NOT NULL,
    [IsParalApprovalAllowed] BIT           CONSTRAINT [DF__FormCateg__IsPar__29221CFB] DEFAULT ((0)) NOT NULL,
    [IsRecievingAllowed]     BIT           CONSTRAINT [DF__FormCateg__IsRec__2A164134] DEFAULT ((0)) NOT NULL,
    [Instructions]           VARCHAR (500) NULL,
    [MaxPendingRequets]      INT           NULL,
    CONSTRAINT [PK_FormCategories] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

