#!/bin/bash


# Criando diretórios para tablespace
mkdir /var/lib/postgresql/data/teste

# Criação da databases para, postgresql
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE "db_teste" WITH
	    NOSUPERUSER 
	    CREATEDB 
	    NOCREATEROLE
	    REPLICATION
	    NOINHERIT;

    CREATE ROLE $DB_ADM_USER LOGIN PASSWORD '$DB_ADM_PASS'
	    NOSUPERUSER 
	    CREATEDB 
	    NOCREATEROLE
	    REPLICATION
	    NOINHERIT;

    GRANT "db_teste" TO teste;

	CREATE TABLESPACE db_teste OWNER $DB_ADM_USER LOCATION '/var/lib/postgresql/data/teste/';

    CREATE DATABASE teste WITH
        OWNER = '$DB_ADM_USER'
		ENCODING = 'UTF8'
    	LC_COLLATE = 'en_US.utf8'
    	LC_CTYPE = 'en_US.utf8'
    	TABLESPACE = db_teste
    	CONNECTION LIMIT = -1;

EOSQL
