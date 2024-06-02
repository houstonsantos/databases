-- INFORMAÇÕES DAS DATABASES
SELECT DB_NAME() AS BANCO,
    NAME AS ARQUIVO,
    FILE_ID AS ID_ARQUIVO,
    PHYSICAL_NAME AS NOME_FISICO,
    (SIZE * 8.0/1024) AS TAMANHO_TOTAL,
    ((SIZE * 8.0/1024) - (FILEPROPERTY(NAME, 'SpaceUsed') * 8.0/1024)) AS LIVRE
FROM SYS.DATABASE_FILES;
GO


-- INFORMAÇÕES DE TABELA
SELECT name, crdate
FROM sysobjects
WHERE xtype='U' AND NAME LIKE 'Z%'
ORDER BY crdate DESC
GO

-- BACKUPS
-- STATUS DOS BACKUPS
SELECT A.DATABASE_NAME,
B.PHYSICAL_DEVICE_NAME,
A.BEGINS_LOG_CHAIN,
A.TYPE
FROM MSDB..BACKUPSET A
JOIN MSDB..BACKUPMEDIAFAMILY B
ON A.MEDIA_SET_ID = B.MEDIA_SET_ID
WHERE A.DATABASE_NAME = 'TESTE'
GO

-- VERIFICANDO HISTORICO DE BACKUPS
SELECT * FROM MSDB..RESTOREHISTORY
GO

-- SETANDO MODO DE BACKUP
ALTER DATABASE TESTE 
SET RECOVERY FULL WITH NO_WAIT
GO

ALTER DATABASE TESTE 
SET RECOVERY SIMPLE WITH NO_WAIT
GO

-- BACKUP FULL
BACKUP DATABASE TESTE
TO DISK = N'C:\SQL\TESTE_FULL.BAK'
GO

-- BACKUP DE LOG
BACKUP LOG TESTE
TO DISK = N'C:\SQL\TESTE_LOG.TRN'
GO

-- BACKUP DIFERENCIAL
BACKUP DATABASE TESTE
TO DISK = N'C:\SQL\TESTE_DIFF.BAK'
WITH DIFFERENTIAL
GO

-- RESTAURANDO OS BACKUPS E CHAMANDO A NOVA DATABASE DE LOJA_NOVA
USE MASTER
GO

RESTORE DATABASE LOJA_NOVA
FROM DISK = 'C:\SQL\LOJA_FULL.BAK'
WITH FILE = 1,
MOVE N'LOJA' TO 'C:\SQL\LOJA_NOVA.MDF',
MOVE N'LOJA_LOG' TO 'C:\SQL\LOJA_NOVA_LOG.LDF',
NORECOVERY
GO

RESTORE DATABASE LOJA_NOVA
FROM DISK = 'C:\SQL\LOJA_NOVA_FULL.BAK'
WITH MOVE N'CLIENTE' TO 'C:\SQL\LOJA_NOVA_DADOS.MDF',
MOVE N'CLIENTE_LOG' TO 'C:\SQL\LOJA_NOVA_LOG.LDF',
REPLACE, RECOVERY
GO


-- COLOCANDO A DATABASE EM MODO DE SINGLE USER
-- PARA RESTAURAR OS LOGS
USE MASTER
GO

ALTER DATABASE LOJA_NOVA
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

-- RESTAURANDO LOGS
RESTORE LOG LOJA_NOVA
FROM DISK = N'C:\SQL\LOJA_LOG.TRN'
WITH FILE = 1,
NORECOVERY
GO

-- RESTAURANDO OS LOGS
RESTORE LOG CLIENTES_NOVA
FROM DISK = 'C:\SQL\CLIENTES_LOG1.TRN'
WITH NORECOVERY
GO

-- APOS O RESTORE, COLOCAR A DATABASE ONLINE
USE MASTER
GO

RESTORE DATABASE LOJA_NOVA
WITH RECOVERY
GO


-- COLOCANDO DATABASE OFFLINE PARA REMOVER O MDF
USE MASTER
GO

ALTER DATABASE TESTE
SET OFFLINE
WITH ROLLBACK IMMEDIATE
GO

-- COLOCAR DATABASE ONLINE
ALTER DATABASE TESTE
SET ONLINE
GO


-- SETAR OPÇÃO AUTO_CLOSE
USE master
GO

ALTER DATABASE TESTE SET AUTO_CLOSE OFF
GO


-- PROCEDURES
sp_readerrorlog
dbcc showfilestats
sp_who2
dbcc inputbuffer(108)


-- INSERTS
INSERT INTO HOUSTONSANTOS.PROTHEUS.dbo.SQ3990 SELECT * FROM SQ3030;
SELECT * INTO HOUSTONSANTOS.PROTHEUS.dbo.SQ3990 FROM SQ3030;

-- INSERINDO 1000 REGISTROS 'TESTE'
INSERT INTO SQ3990 VALUES ('TESTE')
GO 1000;

INSERT INTO TESTE DEFAULT VALUES
GO 1000;


-- CRIANDO TABELA EXPLICITANDO FILEGROUP
CREATE TABLE TESTE (
    NUMERO INT IDENTITY
) ON [FOLIGROUP]
GO


--UNION
SELECT E2_EMISSAO, E2_VALOR, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000001'
UNION
SELECT E2_EMISSAO, E2_VALOR, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000002';

SELECT E2_EMISSAO, E2_VALOR, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000001'
UNION
SELECT E2_EMISSAO, E2_VALOR + E2_SALDO, E2_VALOR, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000002';

SELECT E2_EMISSAO, E2_VALOR + E2_SALDO, E2_SALDO, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000001'
UNION
SELECT E2_EMISSAO, E2_VALOR + E2_SALDO, E2_VALOR, E2_SALDO FROM SE2040 WHERE E2_NUM = '000000002';


-- LENDO PLANILHA EXCEL
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0','Excel 12.0; Database=C:\NOME_DO_ARQUIVO.xlsx;','SELECT * FROM [NOME_DA_PLANILHA$]') AS TESTE


-- SELECT EM TABELAS EM USO
SELECT * FROM SRM020 WITH (NOLOCK)


-- RETIRANDO ASPAS
SELECT * FROM NOTFIS WHERE NUM_DOC_NOTFIS LIKE '%''%'
UPDATE NOTFIS SET NUM_DOC_NOTFIS = REPLACE(NUM_DOC_NOTFIS, '''', '"') WHERE NUM_DOC_NOTFIS LIKE '%''%';


-- VERIFICANDO E ALTERANDO OS COLLATIONS DOS CAMPOS DE UMA TABELA
SELECT col.name, col.collation_name FROM sys.columns col WHERE object_id = OBJECT_ID('ProdutoTeknisa')
ALTER TABLE ProdutoTeknisa ALTER COLUMN NCM VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL


-- TRABALHANDO COM STRING
SELECT B1_CODTEKN, * FROM dbo.SB1010 WHERE SUBSTRING(B1_CODTEKN, 9, 2) = '02'
SELECT ASCII(SUBSTRING(F1_USERLGI, 3,1)), ASCII(F1_USERLGI), * FROM SF1020 WHERE F1_USERLGI <> '' OR F1_USERLGI <> ''


-- CURSOR
DECLARE 
	@vR_E_C_N_O_ VARCHAR(4),
    @x_FORMATADO VARCHAR(6),
	@x			 NUMERIC(6,0)	  
BEGIN
  SET @X = 0;
  DECLARE CS CURSOR FOR SELECT R_E_C_N_O_ FROM SA2990
  OPEN CS
	FETCH NEXT FROM CS INTO @vR_E_C_N_O_
	WHILE (@@FETCH_STATUS = 0)
	  BEGIN
	    SET @X = @X + 1;
		SET @x_FORMATADO = RIGHT('00000' + CONVERT(VARCHAR, @X), 6)
		UPDATE SA2990 SET A2_COD = @x_FORMATADO WHERE R_E_C_N_O_ = @vR_E_C_N_O_ 
		FETCH NEXT FROM CS INTO @vR_E_C_N_O_
	  END
  CLOSE CS
  DEALLOCATE CS
END
GO

DECLARE
    @D2_COD VARCHAR(15),
    @xD2_COD VARCHAR(6)
BEGIN
    DECLARE NH CURSOR FOR SELECT D2_COD FROM SD2040
    OPEN NH 
        FETCH NEXT FROM NH INTO @D2_COD
        WHILE (@@FETCH_STATUS = 0)
            BEGIN
                SET @xD2_COD = RIGHT(@D2_COD, 6)
                UPDATE SD2040 SET D2_COD = @xD2_COD WHERE D2_COD = @D2_COD
                PRINT @D2_COD
                PRINT @xD2_COD
                FETCH NEXT FROM NH INTO @D2_COD
            END
    CLOSE NH
    DEALLOCATE NH
END
GO

DECLARE
    @VF_FILIAL VARCHAR(2),
    @VF_DELETE VARCHAR(1),
    @VF_RECNO NUMERIC(4),
    @VF_RECDEL NUMERIC(4)
BEGIN
    DECLARE NH CURSOR FOR SELECT CVF_FILIAL, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_ FROM CVF020 WHERE CVF_FILIAL IN('01','02') AND D_E_L_E_T_ <> '*'
    OPEN NH 
        FETCH NEXT FROM NH INTO @VF_FILIAL, @VF_DELETE, @VF_RECNO, @VF_RECDEL
        WHILE (@@FETCH_STATUS = 0)
            BEGIN
                UPDATE CVF020 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = @VF_RECNO WHERE R_E_C_N_O_ = @VF_RECNO
                PRINT @VF_RECNO
                FETCH NEXT FROM NH INTO @VF_FILIAL, @VF_DELETE, @VF_RECNO, @VF_RECDEL
            END
    CLOSE NH
    DEALLOCATE NH
END
GO


-- HABILITANDO CDC
-- VERICANDO DATABASE COM CDC HABILITADO
SELECT name, is_cdc_enabled 
FROM sys.databases

-- HABILITANDO CDC EM DATABASE
USE base
GO
EXEC sys.sp_cdc_enable_db
GO

-- HABILITANDO CDC EM TABELA
USE base
GO
sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name   = N'tabela',
@role_name     = N'NULL',
@supports_net_changes = 0
GO

-- CONSULTADO TABELAS COM CDC HABILITADO
USE base
GO
EXEC sys.sp_cdc_help_change_data_capture
GO

-- VERIFICAR OWNERS DE DATABASES
SELECT 
    databases.NAME as 'database',
    server_Principals.NAME as owner
FROM 
    sys.[databases]
INNER JOIN sys.[server_principals] 
ON [databases].owner_sid = [server_principals].sid

-- ALTERAR OWNER DE DATABASE
USE mdb EXEC sp_changedbowner 'sa'