#!/bin/bash

##############################################################################
# Script de Despliegue del Servidor Apache
# Instala y configura Apache HTTP Server con el cliente HTML/JS
# Autor: Angie Ramos
# Fecha: Octubre 2025
##############################################################################

set -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' 

echo -e "${BLUE}======================================"
echo "Script de Despliegue - Apache Server"
echo "======================================${NC}"
echo ""


print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}


if [ "$USER" != "ec2-user" ] && [ "$USER" != "root" ]; then
    print_error "Este script debe ejecutarse como ec2-user o root"
    exit 1
fi

# Paso 1: Actualizar el sistema
print_step "Actualizando el sistema..."
sudo dnf update -y
print_success "Sistema actualizado"

# Paso 2: Instalar Apache
print_step "Instalando Apache HTTP Server..."
sudo dnf install -y httpd mod_ssl
print_success "Apache instalado"

# Paso 3: Verificar instalación
if ! command -v httpd &> /dev/null; then
    print_error "Apache no se instaló correctamente"
    exit 1
fi
print_success "Apache verificado: $(httpd -v | head -n 1)"

# Paso 4: Configurar firewall (firewalld)
print_step "Configurando firewall..."
if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
    print_success "Firewall configurado"
else
    print_info "firewalld no está instalado, asegúrate de configurar Security Group en AWS"
fi

# Paso 5: Copiar el archivo index.html
print_step "Desplegando la aplicación web..."
if [ -f "index.html" ]; then
    sudo cp index.html /var/www/html/
    sudo chown apache:apache /var/www/html/index.html
    sudo chmod 644 /var/www/html/index.html
    print_success "index.html copiado a /var/www/html/"
else
    print_error "No se encontró index.html en el directorio actual"
    exit 1
fi

# Paso 6: Crear página de prueba
print_step "Creando página de prueba..."
sudo bash -c 'cat > /var/www/html/test.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test - Apache Server</title>
</head>
<body>
    <h1>Apache Server Funcionando</h1>
    <p>Servidor: Apache/2.4</p>
    <p>Estado: Activo</p>
    <p>Fecha: $(date)</p>
</body>
</html>
EOF'
print_success "Página de prueba creada en /var/www/html/test.html"

# Paso 7: Configurar Apache para HTTPS 
print_step "Configurando certificado SSL..."
sudo mkdir -p /etc/pki/tls/certs /etc/pki/tls/private

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/apache-selfsigned.key \
    -out /etc/pki/tls/certs/apache-selfsigned.crt \
    -subj "/C=CO/ST=Bogota/L=Bogota/O=Uniandes/OU=Arquitectura/CN=34.228.157.43" \
    2>/dev/null

print_success "Certificado SSL generado"

print_step "Configurando SSL en Apache..."
sudo bash -c 'cat > /etc/httpd/conf.d/ssl-custom.conf << EOF
<VirtualHost *:443>
    ServerName 34.228.157.43
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Configuración de seguridad
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    
    ErrorLog /var/log/httpd/ssl_error_log
    CustomLog /var/log/httpd/ssl_access_log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName 34.228.157.43
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/httpd/error_log
    CustomLog /var/log/httpd/access_log combined
</VirtualHost>
EOF'
print_success "SSL configurado"

# Paso 9: Verificar configuración de Apache
print_step "Verificando configuración de Apache..."
sudo httpd -t
if [ $? -eq 0 ]; then
    print_success "Configuración de Apache válida"
else
    print_error "Error en la configuración de Apache"
    exit 1
fi

# Paso 10: Habilitar e iniciar Apache
print_step "Iniciando Apache..."
sudo systemctl enable httpd
sudo systemctl restart httpd

if sudo systemctl is-active --quiet httpd; then
    print_success "Apache está corriendo"
else
    print_error "Apache no se inició correctamente"
    sudo systemctl status httpd
    exit 1
fi

# Paso 11: Mostrar información del servidor
echo ""
echo -e "${GREEN}======================================"
echo "¡Despliegue completado exitosamente!"
echo "======================================${NC}"
echo ""
echo -e "${BLUE}Información del Servidor:${NC}"
echo "• HTTP:  http://34.228.157.43"
echo "• HTTPS: https://34.228.157.43"
echo "• Test:  http://34.228.157.43/test.html"
echo ""
echo -e "${BLUE}Archivos desplegados:${NC}"
echo "• /var/www/html/index.html (Aplicación principal)"
echo "• /var/www/html/test.html (Página de prueba)"
echo ""
echo -e "${BLUE}Comandos útiles:${NC}"
echo "• Ver logs: sudo tail -f /var/log/httpd/access_log"
echo "• Ver errores: sudo tail -f /var/log/httpd/error_log"
echo "• Reiniciar Apache: sudo systemctl restart httpd"
echo "• Estado de Apache: sudo systemctl status httpd"
echo ""
echo -e "${YELLOW}NOTA: El certificado SSL es self-signed. Para producción, usa Let's Encrypt.${NC}"
echo ""
echo -e "${BLUE}Para instalar Let's Encrypt (opcional):${NC}"
echo "sudo dnf install -y certbot python3-certbot-apache"
echo "sudo certbot --apache -d tu-dominio.com"
echo ""
