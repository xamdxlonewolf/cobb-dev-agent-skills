-- install-dev.sql — development install (enables table recreate)
-- Run from SQL*Plus or SQLcl: @database/install/install-dev.sql
DEFINE recreate = 1
@@install.sql
