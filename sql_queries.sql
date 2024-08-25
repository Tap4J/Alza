SELECT docs.Firm_ID, docs.Document_ID, items.Product_ID, items.Amount, items.UnitPriceExclVat, 
		items.PriceExclVat, docs.TotalPriceExclVat, docs.VatDate, benefit.ValidFrom, benefit.ValidTo,
		CASE 
			WHEN benefit.Firm_ID IS NOT NULL THEN 'True' ELSE 'False'
		END AS IsInBenefitProgram
FROM dbo.Documents as docs
JOIN dbo.DocumentItems as items ON docs.Document_ID = items.Document_ID
JOIN dbo.Firms as firms ON docs.Firm_ID = firms.Firm_ID
LEFT JOIN dbo.BenefitProgramFirms as benefit ON docs.Firm_ID = benefit.Firm_ID
WHERE firms.IsActive = 1



WITH BenefitProgramData AS (
	SELECT docs.Firm_ID, docs.Document_ID, items.Product_ID, items.Amount, items.UnitPriceExclVat, 
		items.PriceExclVat, docs.TotalPriceExclVat, docs.VatDate, benefit.ValidFrom, benefit.ValidTo,
		CASE 
			WHEN benefit.Firm_ID IS NOT NULL THEN 'True' ELSE 'False'
		END AS IsInBenefitProgram
	FROM dbo.Documents as docs
	JOIN dbo.DocumentItems as items ON docs.Document_ID = items.Document_ID
	JOIN dbo.Firms as firms ON docs.Firm_ID = firms.Firm_ID
	LEFT JOIN dbo.BenefitProgramFirms as benefit ON docs.Firm_ID = benefit.Firm_ID
	WHERE firms.IsActive = 1
)
SELECT 
    IsInBenefitProgram,
    AVG(TotalPriceExclVat) AS AvgPurchaseValue,
    COUNT(Document_ID) AS TransactionCount,
    SUM(Amount) AS TotalAmount,
    AVG(UnitPriceExclVat) AS AvgUnitPrice,
	COUNT(DISTINCT Firm_ID) AS NumberOfFirms
FROM 
    BenefitProgramData
GROUP BY 
    IsInBenefitProgram;




WITH BenefitProgramData AS (
	SELECT DISTINCT
        docs.Firm_ID,
		CASE 
			WHEN benefit.Firm_ID IS NOT NULL THEN 'True' ELSE 'False'
		END AS IsInBenefitProgram
	FROM dbo.Documents as docs
	JOIN dbo.DocumentItems as items ON docs.Document_ID = items.Document_ID
	JOIN dbo.Firms as firms ON docs.Firm_ID = firms.Firm_ID
	LEFT JOIN dbo.BenefitProgramFirms as benefit ON docs.Firm_ID = benefit.Firm_ID
	WHERE firms.IsActive = 1
),
TransactionCounts AS (
    SELECT
		bpd.IsInBenefitProgram,
        docs.Firm_ID,
        COUNT(docs.Document_ID) as TransactionCount
    FROM dbo.Documents as docs
    JOIN BenefitProgramData as bpd ON docs.Firm_ID = bpd.Firm_ID
    GROUP BY docs.Firm_ID, bpd.IsInBenefitProgram
)

SELECT
    IsInBenefitProgram,
    AVG(TransactionCount) AS AvgTransactionCount
FROM 
    TransactionCounts
GROUP BY 
    IsInBenefitProgram;


WITH ProgramEntryDates AS (
    SELECT 
        Firm_ID,
        MIN(ValidFrom) as StartProgram
    FROM 
        dbo.BenefitProgramFirms
    GROUP BY 
        Firm_ID
),
PurchasesBeforeAfter AS (
    SELECT 
        docs.Firm_ID,
        CASE 
            WHEN docs.VatDate < entryProgram.StartProgram THEN 'Before'
            WHEN docs.VatDate >= entryProgram.StartProgram THEN 'After'
            ELSE 'Never in program'
        END AS BenefitProgramPeriod,
        SUM(docs.TotalPriceExclVat) AS TotalSpent,
        COUNT(DISTINCT docs.Document_ID) AS PurchaseCount
    FROM 
        dbo.Documents as docs
    LEFT JOIN 
        ProgramEntryDates as entryProgram ON docs.Firm_ID = entryProgram.Firm_ID
    WHERE 
        docs.VatDate IS NOT NULL
    GROUP BY 
        docs.Firm_ID, 
        CASE 
            WHEN docs.VatDate < entryProgram.StartProgram THEN 'Before'
            WHEN docs.VatDate >= entryProgram.StartProgram THEN 'After'
            ELSE 'Never in program'
        END
)
SELECT 
    Firm_ID,
    BenefitProgramPeriod,
    SUM(TotalSpent) as TotalSpent,
	SUM(PurchaseCount) as TotalPurchases,
	(SUM(TotalSpent)/SUM(PurchaseCount)) as AvgSpentOnTransaction
FROM 
    PurchasesBeforeAfter
GROUP BY 
    Firm_ID, BenefitProgramPeriod;



WITH ProgramEntryDates AS (
    SELECT 
        Firm_ID,
        MIN(ValidFrom) as StartProgram
    FROM 
        dbo.BenefitProgramFirms
    GROUP BY 
        Firm_ID
),
PurchasesBeforeAfter AS (
    SELECT 
        docs.Firm_ID,
        CASE 
            WHEN docs.VatDate < entryProgram.StartProgram THEN 'Before'
            WHEN docs.VatDate >= entryProgram.StartProgram THEN 'After'
            ELSE 'Never in program'
        END AS BenefitProgramPeriod,
        SUM(docs.TotalPriceExclVat) AS TotalSpent,
        COUNT(DISTINCT docs.Document_ID) AS PurchaseCount
    FROM 
        dbo.Documents as docs
    LEFT JOIN 
        ProgramEntryDates as entryProgram ON docs.Firm_ID = entryProgram.Firm_ID
    WHERE 
        docs.VatDate IS NOT NULL
    GROUP BY 
        docs.Firm_ID, 
        CASE 
            WHEN docs.VatDate < entryProgram.StartProgram THEN 'Before'
            WHEN docs.VatDate >= entryProgram.StartProgram THEN 'After'
            ELSE 'Never in program'
        END
),
FilteredPurchases AS (
    SELECT 
        Firm_ID,
        BenefitProgramPeriod,
        SUM(TotalSpent) AS TotalSpent,
		(SUM(TotalSpent)/SUM(PurchaseCount)) as AvgSpentOnTransaction,
        SUM(PurchaseCount) AS TotalPurchases
    FROM 
        PurchasesBeforeAfter
    WHERE 
        BenefitProgramPeriod IN ('Before', 'After')
    GROUP BY 
        Firm_ID, BenefitProgramPeriod
)
SELECT 
    Firm_ID,
    BenefitProgramPeriod,
    TotalSpent,
    AvgSpentOnTransaction,
    TotalPurchases
FROM 
    FilteredPurchases
ORDER BY 
    Firm_ID, BenefitProgramPeriod;


WITH ProgramEntryDates AS (
    SELECT 
        Firm_ID,
        MIN(ValidFrom) as EntryDate
    FROM 
        dbo.BenefitProgramFirms
    GROUP BY 
        Firm_ID
),
PurchasesSummary AS (
    SELECT 
        docs.Firm_ID,
        CASE 
            WHEN entryProgram.Firm_ID IS NOT NULL THEN 'True'
            ELSE 'False'
        END AS IsInBenefitProgram,
        SUM(docs.TotalPriceExclVat) as TotalSpent,
        COUNT(DISTINCT docs.Document_ID) as PurchaseCount
    FROM 
        dbo.Documents as docs
    LEFT JOIN 
        ProgramEntryDates as entryProgram ON docs.Firm_ID = entryProgram.Firm_ID
    WHERE 
        docs.VatDate IS NOT NULL
    GROUP BY 
        docs.Firm_ID, 
        CASE 
            WHEN entryProgram.Firm_ID IS NOT NULL THEN 'True'
            ELSE 'False'
        END
)
SELECT 
    IsInBenefitProgram,
    SUM(TotalSpent) as TotalSpent,
    AVG(TotalSpent) as AvgSpent,
    SUM(PurchaseCount) as TotalPurchases
FROM 
    PurchasesSummary
GROUP BY 
    IsInBenefitProgram;