CREATE TABLE [dbo].[InQuantityRec] (
    [RecordId] INT          IDENTITY (1, 1) NOT NULL,
    [LoginId]  VARCHAR (50) NULL,
    [Name]     VARCHAR (50) NULL,
    [ItemName] VARCHAR (50) NULL,
    [Date]     DATE         NULL,
    [InQty]    INT          NULL,
    CONSTRAINT [PK_InQuantityRec] PRIMARY KEY CLUSTERED ([RecordId] ASC)
);

