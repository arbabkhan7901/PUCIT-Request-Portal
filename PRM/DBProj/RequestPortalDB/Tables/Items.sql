CREATE TABLE [dbo].[Items] (
    [ItemId]      INT          IDENTITY (1, 1) NOT NULL,
    [ItemName]    VARCHAR (50) NOT NULL,
    [Quantity]    INT          NULL,
    [Description] VARCHAR (50) NULL,
    [Type]        INT          NULL,
    [IsActive]    BIT          NULL,
    [CreatedBy]   INT          NULL,
    [CreatedOn]   DATETIME     NULL,
    [ModifiedBy]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
    CONSTRAINT [PK_Items] PRIMARY KEY CLUSTERED ([ItemId] ASC)
);



