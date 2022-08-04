#!/bin/bash

# Executando script sql de criação da database protheus
sleep 25s
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ${SA_PASSWORD} -d master -i /opt/mssql/db_mssql.sql