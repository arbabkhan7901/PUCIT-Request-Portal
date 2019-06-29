CREATE TABLE [dbo].[VehicalTokenData] (
    [RequestID]    INT          NOT NULL,
    [VehicalRegNo] VARCHAR (50) NOT NULL,
    [Model]        VARCHAR (10) NOT NULL,
    [Manufacturer] VARCHAR (50) NOT NULL,
    [ownerName]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_VehicalTokenData] PRIMARY KEY CLUSTERED ([VehicalRegNo] ASC)
);

