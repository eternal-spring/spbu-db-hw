DROP INDEX IF EXISTS idx_client_id;


EXPLAIN ANALYZE
SELECT * FROM clients_currency_operations_count WHERE client_id < 10 LIMIT 15;

--Limit  (cost=0.00..66.75 rows=15 width=24) (actual time=0.021..0.069 rows=15 loops=1)
--  ->  Seq Scan on clients_currency_operations_count  (cost=0.00..93.45 rows=21 width=24) (actual time=0.020..0.068 rows=15 loops=1)
--        Filter: (client_id < 10)
--        Rows Removed by Filter: 2161
--Planning Time: 0.498 ms
--Execution Time: 0.077 ms


CREATE INDEX IF NOT EXISTS idx_client_id ON clients_currency_operations_count(client_id);


EXPLAIN ANALYZE
SELECT * FROM clients_currency_operations_count WHERE client_id < 10 LIMIT 15;

--Limit  (cost=4.47..25.45 rows=15 width=24) (actual time=0.017..0.025 rows=15 loops=1)
--  ->  Bitmap Heap Scan on clients_currency_operations_count  (cost=4.47..38.04 rows=24 width=24) (actual time=0.016..0.023 rows=15 loops=1)
--        Recheck Cond: (client_id < 10)
--        Heap Blocks: exact=10
--        ->  Bitmap Index Scan on idx_client_id  (cost=0.00..4.46 rows=24 width=0) (actual time=0.009..0.009 rows=21 loops=1)
--              Index Cond: (client_id < 10)
--Planning Time: 1.699 ms
--Execution Time: 0.037 ms


EXPLAIN ANALYZE 
SELECT * FROM clients_currency_operations_count WHERE client_id < 100 LIMIT 15;

--Limit  (cost=0.00..5.10 rows=15 width=24) (actual time=0.010..0.018 rows=15 loops=1)
--  ->  Seq Scan on clients_currency_operations_count  (cost=0.00..93.45 rows=275 width=24) (actual time=0.009..0.017 rows=15 loops=1)
--        Filter: (client_id < 100)
--        Rows Removed by Filter: 234
--Planning Time: 0.083 ms
--Execution Time: 0.026 ms


EXPLAIN ANALYZE
SELECT * FROM clients_currency_operations_count WHERE client_id < 100;

--Bitmap Heap Scan on clients_currency_operations_count  (cost=6.41..44.85 rows=275 width=24) (actual time=0.022..0.092 rows=248 loops=1)
--  Recheck Cond: (client_id < 100)
--  Heap Blocks: exact=35
--  ->  Bitmap Index Scan on idx_client_id  (cost=0.00..6.34 rows=275 width=0) (actual time=0.009..0.009 rows=248 loops=1)
--        Index Cond: (client_id < 100)
--Planning Time: 0.128 ms
--Execution Time: 0.113 ms
