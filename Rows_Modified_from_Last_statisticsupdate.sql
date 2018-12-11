--https://littlekendra.com/2016/12/06/when-did-sql-server-last-update-that-statistic-how-much-has-been-modified-since-and-what-columns-are-in-the-stat/
-- Works SQL 2008 and above

USE [DB_NAME]
GO
SELECT 
    stat.auto_created,
    stat.name as stats_name,
	so.name as Table_Name,
    STUFF((SELECT ', ' + cols.name
        FROM sys.stats_columns AS statcols
        JOIN sys.columns AS cols ON
            statcols.column_id=cols.column_id
            AND statcols.object_id=cols.object_id
        WHERE statcols.stats_id = stat.stats_id and
            statcols.object_id=stat.object_id
        ORDER BY statcols.stats_column_id
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')  as stat_cols,
    stat.filter_definition,
    stat.is_temporary,
    stat.no_recompute,
    sp.last_updated,
    sp.modification_counter,
    sp.rows,
    sp.rows_sampled
FROM sys.stats as stat
CROSS APPLY sys.dm_db_stats_properties (stat.object_id, stat.stats_id) AS sp
JOIN sys.objects as so on 
    stat.object_id=so.object_id
JOIN sys.schemas as sc on
    so.schema_id=sc.schema_id
-- *** uncomment the below lines if you need to select specific table
--WHERE 
--    sc.name= 'Warehouse'
--    and so.name='StockItemTransactions'
ORDER BY modification_counter desc
GO

