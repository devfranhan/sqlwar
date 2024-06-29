USE DB

DROP TABLE IF EXISTS #NEXIST

-- 1. Retrieving SK's that are in the fact table but have been deleted from the DM:
SELECT DISTINCT SK_LOJA
INTO #NEXIST
FROM FT_VENDA
WHERE SK_LOJA NOT IN
    (
        SELECT SK_LOJA
        FROM DM_LOJA
    )

-- Considering the subquery from the inside out:
DROP TABLE IF EXISTS #DEPARA

    -- 4. Crossing the old SK's from the fact table with the real key (ID_LOJA + GRUPO) to get the SK that is in both the fact and DM, equivalent for each key:
    SELECT DISTINCT A.SK_LOJA AS FROM_SK,
        (SELECT TOP 1 SK_LOJA FROM DBO.DM_LOJA C WHERE B.ID_LOJA = C.ID_LOJA AND B.GRUPO = C.GRUPO) AS TO_SK
    INTO #DEPARA
    FROM #NEXIST A
    LEFT JOIN
    (
        -- 3. Retrieving the old SK's for each ID_LOJA to standardize in the FT:
        SELECT DISTINCT SK_LOJA, ID_LOJA, GRUPO
        FROM Backup.DBO.DM_LOJA
        WHERE ID_LOJA IN
        (
            -- 2. Retrieving only the ID_LOJA that are missing in the fact table, using the SK's that were deleted from the DM (already using the backup): 
            SELECT DISTINCT ID_LOJA
            FROM Backup.DBO.DM_LOJA
            WHERE SK_LOJA IN (SELECT B.SK_LOJA FROM #NEXIST B)
        )
    ) AS B
    ON A.SK_LOJA = B.SK_LOJA

-- 5. Updating the SK's using the dePara table created previously:
UPDATE A
SET SK_LOJA = B.TO_SK
FROM DBO.FT_VENDA A
INNER JOIN #DEPARA B ON A.SK_LOJA = B.FROM_SK
