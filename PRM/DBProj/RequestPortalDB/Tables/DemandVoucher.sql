CREATE TABLE [dbo].[DemandVoucher] (
    [demandId]  INT          IDENTITY (1, 1) NOT NULL,
    [RequestID] INT          NOT NULL,
    [ItemId]    INT          NOT NULL,
    [ItemName]  VARCHAR (50) NOT NULL,
    [Quantity]  INT          NOT NULL,
    [Budget]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_DemandVoucher] PRIMARY KEY CLUSTERED ([demandId] ASC)
);

