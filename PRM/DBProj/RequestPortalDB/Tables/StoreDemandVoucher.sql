CREATE TABLE [dbo].[StoreDemandVoucher] (
    [demandId]  INT          IDENTITY (1, 1) NOT NULL,
    [RequestID] INT          NOT NULL,
    [ItemId]    INT          NOT NULL,
    [ItemName]  VARCHAR (50) NOT NULL,
    [Quantity]  INT          NOT NULL,
    [Budget]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_StoreDemandVoucher] PRIMARY KEY CLUSTERED ([demandId] ASC)
);

