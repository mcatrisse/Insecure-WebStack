#!/bin/bash
set -e


# Asegurar que los directorios de MariaDB/MySQL existen
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

echo "[*] Inicializando recursos y ejecutando scripts vulnerables..."

# Iniciar MariaDB temporalmente
/usr/sbin/mariadbd --user=mysql &
MYSQL_PID=$!
sleep 5

cd /opt/Insecure-WebStack

chmod +x ./docker/script.sh
./docker/script.sh

# Detener MariaDB temporalmente
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null || true

echo "[*] Inicialización completada con éxito."

echo "[*] Iniciando servicios con supervisord..."
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf