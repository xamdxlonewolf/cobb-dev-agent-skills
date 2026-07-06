-- install.sql — production-safe master install
-- Run from SQL*Plus or SQLcl: @database/install/install.sql
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET DEFINE ON

-- Pass recreate=1 via install-dev.sql only (drops and rebuilds tables in dev)
DEFINE recreate = 0

-- Install order: tables → sequences → indexes → constraints → views → mviews
--   → types → packages/spec → packages/body → procedures → functions
--   → triggers → seeds → grants → synonyms
--
-- Example (uncomment and adjust as objects are added):
-- @@../tables/order_statuses.sql
-- @@../indexes/orders.sql
-- @@../views/vw_open_orders.sql
-- @@../packages/spec/acme_orders_pkg.pks
-- @@../packages/body/acme_orders_pkg.pkb
-- @@../seeds/seed_order_statuses.sql
-- @@../grants/app_user.sql
