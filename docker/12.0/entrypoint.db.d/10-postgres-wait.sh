#!/bin/bash
# wait-for-postgres.sh

set -Eeuo pipefail

# Load values from config file with last ocurrence
files=($(grep -lR "${ODOO_RC}" -e '^db_host' || true))
if [ "${files[@]}" ]; then
    PGHOST=$(awk -F "=" '/db_host/ {print $2}' "${files[-1]}" | tr -d ' '); fi

files=($(grep -lR "${ODOO_RC}" -e '^db_user' || true))
if [ "${files[@]}" ]; then
    PGUSER=$(awk -F "=" '/db_user/ {print $2}' "${files[-1]}" | tr -d ' '); fi

files=($(grep -lR "${ODOO_RC}" -e '^db_port' || true))
if [ "${files[@]}" ]; then
    PGPORT=$(awk -F "=" '/db_port/ {print $2}' "${files[-1]}" | tr -d ' '); fi

files=($(grep -lR "${ODOO_RC}" -e '^db_password' || true))
if [ "${files[@]}" ]; then
    PGPASSWORD=$(awk -F "=" '/db_password/ {print $2}' ${files[-1]} | tr -d ' '); fi


: "${RETRIES:=5}"
: "${PGPORT:=5432}"

if [ -z "${PGHOST+set}" ]; then
    echo "PGHOST is neither in the environment nor in the odoo config. Exiting." && exit 1
fi

if [ -z "${PGUSER+set}" ]; then
    echo "PGUSER is neither in the environment nor in the odoo config. Exiting." && exit 1
fi

if [ -z "${PGPASSWORD+set}" ]; then
    echo "PGPASSWORD is neither in the environment nor in the odoo config. Exiting." && exit 1
fi

until export PGPASSWORD; psql -h $PGHOST -U $PGUSER -d "postgres" -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
  sleep 1
done
