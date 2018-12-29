#!/bin/bash
# wait-for-postgres.sh
set -Eeuo pipefail

# Load values from config file with last ocurrence
	files=($(grep -lR "${ODOO_RC}" -e '^db_host'))
	if [ "$files" ]; then
		PGHOST=$(awk -F "=" '/db_host/ {print $2}' "${files[-1]}" | tr -d ' '); fi
	files=($(grep -lR "${ODOO_RC}" -e '^db_user'))
	if [ "$files" ]; then
		PGUSER=$(awk -F "=" '/db_user/ {print $2}' "${files[-1]}" | tr -d ' '); fi
	files=($(grep -lR "${ODOO_RC}" -e '^db_port'))
	if [ "$files" ]; then
		PGPORT=$(awk -F "=" '/db_port/ {print $2}' "${files[-1]}" | tr -d ' '); fi
	files=($(grep -lR "${ODOO_RC}" -e '^db_password'))
	if [ "$files" ]; then
		PGPASSWORD=$(awk -F "=" '/db_password/ {print $2}' ${files[-1]} | tr -d ' '); fi


RETRIES=5

until export PGPASSWORD; psql -h $PGHOST -U $PGUSER -d "postgres" -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
  sleep 1
done
