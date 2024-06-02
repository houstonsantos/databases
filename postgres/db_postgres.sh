#!/bin/bash


# Criação da database rules e tablespace para o protheus, ou qualquer outro sistema no postgres.
mkdir /var/lib/postgresql/data/protheus
chown postgres:postgres /var/lib/postgresql/data/protheus

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE "db_protheus" WITH
	    NOSUPERUSER 
	    CREATEDB 
	    NOCREATEROLE
	    REPLICATION
	    NOINHERIT;
	
    CREATE ROLE $POSTGRES_USER_TOTVS LOGIN PASSWORD '$POSTGRES_PASS_TOTVS'
	    NOSUPERUSER 
	    CREATEDB 
	    NOCREATEROLE
	    REPLICATION
	    NOINHERIT;
	
    GRANT "db_protheus" TO $POSTGRES_USER_TOTVS;
	
	CREATE TABLESPACE db_protheus OWNER $POSTGRES_USER_TOTVS LOCATION '/var/lib/postgresql/data/protheus/';
    
    CREATE DATABASE $DATABASE WITH
		OWNER = '$POSTGRES_USER_TOTVS'
		ENCODING = 'WIN1252'
    	LC_COLLATE = 'C'
    	LC_CTYPE = 'C'
    	TABLESPACE = db_protheus
		IS_TEMPLATE = False
    	CONNECTION LIMIT = -1;
EOSQL
