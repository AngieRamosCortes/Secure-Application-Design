#!/bin/bash

##############################################################################
# Script de Despliegue Mejorado del Servidor Spring Boot
# Instala, compila y despliega la aplicación Spring Boot con SSL
# Autor: Angie Ramos
# Fecha: Octubre 2025
##############################################################################

set -e  # Exit on error


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'


APP_NAME="secure-app"
APP_VERSION="0.0.1-SNAPSHOT"
JAR_FILE="target/${APP_NAME}-${APP_VERSION}.jar"
SERVICE_NAME="secureapp"
KEYSTORE_PATH="/home/ec2-user/keystore.p12"
KEYSTORE_PASSWORD="password123"
APP_PORT="443"
SPRING_SERVER_IP="54.236.29.198"

echo -e "${BLUE}======================================"
echo "Script de Despliegue - Spring Server"
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

# Paso 2: Instalar Java 17
print_step "Verificando Java..."
if ! command -v java &> /dev/null; then
    print_info "Instalando Java 17 Amazon Corretto..."
    sudo dnf install -y java-17-amazon-corretto-devel
    print_success "Java instalado"
else
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_success "Java ya está instalado: $JAVA_VERSION"
fi


java -version

# Paso 3: Instalar Maven
print_step "Verificando Maven..."
if ! command -v mvn &> /dev/null; then
    print_info "Instalando Maven..."
    sudo dnf install -y maven
    print_success "Maven instalado"
else
    MAVEN_VERSION=$(mvn -version | head -n 1)
    print_success "Maven ya está instalado: $MAVEN_VERSION"
fi

# Paso 4: Compilar la aplicación
print_step "Compilando la aplicación Spring Boot..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    print_error "Falló la compilación"
    exit 1
fi

print_success "Compilación exitosa"

# Verificar que el JAR existe
if [ ! -f "$JAR_FILE" ]; then
    print_error "No se encontró el archivo JAR: $JAR_FILE"
    exit 1
fi

JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
print_success "JAR generado: $JAR_FILE ($JAR_SIZE)"

# Paso 5: Generar keystore para SSL
print_step "Configurando certificado SSL..."
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_info "Generando keystore con certificado self-signed..."
    
    keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 \
        -keystore "$KEYSTORE_PATH" \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEYSTORE_PASSWORD" \
        -validity 365 \
        -dname "CN=${SPRING_SERVER_IP}, OU=Arquitectura, O=Uniandes, L=Bogota, ST=Bogota, C=CO" \
        -ext SAN=dns:ec2-54-236-29-198.compute-1.amazonaws.com,ip:${SPRING_SERVER_IP} \
        -storetype PKCS12
    
    chmod 600 "$KEYSTORE_PATH"
    print_success "Keystore generado en $KEYSTORE_PATH"
else
    print_success "Keystore ya existe: $KEYSTORE_PATH"
fi

# Mostrar información del keystore
print_info "Información del certificado:"
keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" | grep -A 5 "Alias name"

# Paso 6: Crear archivo de configuración para producción
print_step "Creando configuración de producción..."
cat > application-prod.properties << EOF
# Spring Boot Production Configuration
server.port=${APP_PORT}
server.address=0.0.0.0

# SSL Configuration
server.ssl.enabled=true
server.ssl.key-store=${KEYSTORE_PATH}
server.ssl.key-store-password=${KEYSTORE_PASSWORD}
server.ssl.keyStoreType=PKCS12
server.ssl.keyAlias=tomcat

# Security
spring.security.user.name=admin
spring.security.user.password=password

# Logging
logging.level.org.springframework.security=INFO
logging.level.com.angie.secureapp=INFO
logging.file.name=/home/ec2-user/logs/secureapp.log
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
EOF

mkdir -p /home/ec2-user/logs
print_success "Configuración de producción creada"

# Paso 7: Crear servicio systemd
print_step "Configurando servicio systemd..."
sudo bash -c "cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=Secure Spring Boot Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/java -jar /home/ec2-user/${JAR_FILE} --spring.config.location=file:/home/ec2-user/application-prod.properties
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

# Security
NoNewPrivileges=true
PrivateTmp=true

# Allow binding to port 443
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF"

print_success "Servicio systemd creado"

# Paso 8: Habilitar e iniciar el servicio
print_step "Iniciando el servicio..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl restart ${SERVICE_NAME}

sleep 3

# Verificar estado
if sudo systemctl is-active --quiet ${SERVICE_NAME}; then
    print_success "Servicio está corriendo"
else
    print_error "El servicio no se inició correctamente"
    print_info "Mostrando logs:"
    sudo journalctl -u ${SERVICE_NAME} -n 50 --no-pager
    exit 1
fi

# Paso 9: Verificar que la aplicación responde
print_step "Verificando endpoints..."
sleep 2

# Test endpoint /api/status
if curl -k -s https://localhost:${APP_PORT}/api/status > /dev/null 2>&1; then
    print_success "Endpoint /api/status responde correctamente"
else
    print_info "El endpoint puede tardar en estar disponible"
fi

# Paso 10: Mostrar información final
echo ""
echo -e "${GREEN}======================================"
echo "¡Despliegue completado exitosamente!"
echo "======================================${NC}"
echo ""
echo -e "${BLUE}Información del Servidor:${NC}"
echo "• URL Base: https://${SPRING_SERVER_IP}:${APP_PORT}"
echo "• API Login: https://${SPRING_SERVER_IP}:${APP_PORT}/api/login"
echo "• API Status: https://${SPRING_SERVER_IP}:${APP_PORT}/api/status"
echo "• API Hello: https://${SPRING_SERVER_IP}:${APP_PORT}/api/hello"
echo ""
echo -e "${BLUE}Credenciales de prueba:${NC}"
echo "• Usuario: admin  | Contraseña: password123"
echo "• Usuario: angie  | Contraseña: angie123"
echo ""
echo -e "${BLUE}Comandos útiles:${NC}"
echo "• Ver logs en tiempo real: sudo journalctl -u ${SERVICE_NAME} -f"
echo "• Ver últimos logs: sudo journalctl -u ${SERVICE_NAME} -n 100"
echo "• Reiniciar servicio: sudo systemctl restart ${SERVICE_NAME}"
echo "• Estado del servicio: sudo systemctl status ${SERVICE_NAME}"
echo "• Detener servicio: sudo systemctl stop ${SERVICE_NAME}"
echo ""
echo -e "${BLUE}Archivos importantes:${NC}"
echo "• JAR: /home/ec2-user/${JAR_FILE}"
echo "• Config: /home/ec2-user/application-prod.properties"
echo "• Keystore: ${KEYSTORE_PATH}"
echo "• Logs: /home/ec2-user/logs/secureapp.log"
echo "• Service: /etc/systemd/system/${SERVICE_NAME}.service"
echo ""
echo -e "${YELLOW}NOTA: Certificado SSL es self-signed. Para producción, usa Let's Encrypt.${NC}"
echo ""
echo -e "${BLUE}Prueba la API:${NC}"
echo 'curl -k -X POST https://localhost:443/api/login \\'
echo '  -H "Content-Type: application/json" \\'
echo '  -d '"'"'{"username":"admin","password":"password123"}'"'"
echo ""
