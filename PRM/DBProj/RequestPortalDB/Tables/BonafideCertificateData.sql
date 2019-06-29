CREATE TABLE [dbo].[BonafideCertificateData] (
    [RequestID]   INT          NOT NULL,
    [CGPA]        FLOAT (53)   NOT NULL,
    [ChallanForm] VARCHAR (15) NOT NULL,
    [PUreg]       VARCHAR (50) NOT NULL,
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [UpdatedTime] DATETIME     NULL,
    [ModifiedBy]  INT          NULL,
    CONSTRAINT [PK_BonafideCertificateData] PRIMARY KEY CLUSTERED ([ID] ASC)
);

