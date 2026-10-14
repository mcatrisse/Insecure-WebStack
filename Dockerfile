FROM debian:bookworm

# Evitar prompts interactivos durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalamos supervisor y pre-instalamos los servicios pesados
RUN apt-get update && apt-get install -y \
    curl wget supervisor \
    nginx mariadb-server  \
    php8.2-fpm php8.2-mysql \
    build-essential git make gcc net-tools \
    && rm -rf /var/lib/apt/lists/*


# Descargar e instalar la aplicación frontend (Pokedex)
RUN wget https://github.com/mcatrisse/pokedex-angular-app/releases/download/v2.0.0/dist.tar.gz && \
    tar -zxvf dist.tar.gz && \
    mkdir -p /var/www/html && \
    cp -r dist/pokedex/* /var/www/html/ && \
    rm -rf dist/ dist.tar.gz && \
    # Ajustar propietario para que Nginx pueda servirlo sin problemas
    chown -R www-data:www-data /var/www/html

# Copiamos todo el workspace actual (el repositorio) al directorio de trabajo del contenedor
COPY . /opt/Insecure-WebStack/

WORKDIR /opt/Insecure-WebStack

# Ubicamos el entrypoint y la configuración de supervisor
RUN cp ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
    cp ./docker/entrypoint.sh /entrypoint.sh && \
    chmod +x /entrypoint.sh


# Exponer puertos (FTP, HTTP, MySQL)
EXPOSE 21 80 3306

# Definir el entrypoint
ENTRYPOINT ["/entrypoint.sh"]