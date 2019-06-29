CREATE TABLE [dbo].[DemandForm] (
    [demandId]  INT          IDENTITY (1, 1) NOT NULL,
    [RequestID] INT          NOT NULL,
    [ItemId]    INT          NOT NULL,
    [ItemName]  VARCHAR (50) NOT NULL,
    [Quantity]  INT          NOT NULL,
    [IssuedQty] INT          NULL,
    CONSTRAINT [PK_DemandForm_1] PRIMARY KEY CLUSTERED ([demandId] ASC)
);

