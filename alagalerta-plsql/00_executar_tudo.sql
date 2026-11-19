-- Executar com F5 no SQL Developer, conectado ao schema Oracle da equipe.
-- O 01 recria somente as tabelas GS_* desta entrega e apaga seus dados anteriores.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
SET FEEDBACK ON
SPOOL evidencias/execucao-oracle.log
@@01_ddl.sql
@@02_carga.sql
@@03_bloco_anonimo_decisao.sql
@@04_repeticao.sql
@@05_cursor_explicito.sql
@@06_procedures.sql
@@07_execucao_procedures.sql
@@08_verificacao.sql
SPOOL OFF
