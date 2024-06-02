#!/bin/bash


if [ "$1" = 'mssql' ]; then
    # Criando database
    /opt/mssql/db_mssql.sh

    # Iniciando serviço MSSQL
    exec /opt/mssql/bin/sqlservr
fi
