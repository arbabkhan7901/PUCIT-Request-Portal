CREATE TABLE [dbo].[HardwareForm] (
    [demandId]  INT          IDENTITY (1, 1) NOT NULL,
    [RequestID] INT          NOT NULL,
    [ItemId]    INT          NOT NULL,
    [ItemName]  VARCHAR (50) NOT NULL,
    [Quantity]  INT          NOT NULL,
    [IssuedQty] INT          NOT NULL,
    CONSTRAINT [PK_HardwareForm_1] PRIMARY KEY CLUSTERED ([demandId] ASC)
);

