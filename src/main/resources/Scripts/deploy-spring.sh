#!/bin/bash

echo "======================================"
echo "Spring Boot Deployment Script"
echo "======================================"
echo ""

APP_NAME="secure-app"
APP_VERSION="0.0.1-SNAPSHOT"
JAR_FILE="target/${APP_NAME}-${APP_VERSION}.jar"
SERVICE_NAME="secureapp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$USER" != "ec2-user" ]; then
    echo -e "${RED}This script should be run as ec2-user${NC}"
    exit 1
fi

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

echo "Checking prerequisites..."
if ! command -v mvn &> /dev/null; then
    print_error "Maven is not installed"
    print_info "Installing Maven..."
    sudo dnf install maven -y
    print_success "Maven installed"
else
    print_success "Maven is installed"
fi

if ! command -v java &> /dev/null; then
    print_error "Java is not installed"
    print_info "Installing Java 17..."
    sudo dnf install java-17-amazon-corretto-devel -y
    print_success "Java installed"
else
    print_success "Java is installed ($(java -version 2>&1 | head -n 1))"
fi

echo ""
echo "Building the application..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    print_error "Build failed"
    exit 1
fi

print_success "Build successful"

if [ ! -f "$JAR_FILE" ]; then
    print_error "JAR file not found: $JAR_FILE"
    exit 1
fi

print_success "JAR file found: $JAR_FILE"

KEYSTORE_PATH="/home/ec2-user/keystore.p12"
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_error "Keystore not found: $KEYSTORE_PATH"
    print_info "Generating self-signed certificate..."
    
    keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 \
        -keystore "$KEYSTORE_PATH" -keypass password123 \
        -storepass password123 -validity 365 \
        -dname "CN=100.25.218.56, OU=Development, O=SecureApp, L=City, ST=State, C=US" \
        -ext SAN=dns:ec2-100-25-218-56.compute-1.amazonaws.com,ip:100.25.218.56 \
        -storetype PKCS12
    
    print_success "Keystore generated"
else
    print_success "Keystore found: $KEYSTORE_PATH"
fi

echo ""
echo "Service Management Options:"
echo "1. Start application as systemd service"
echo "2. Run application in foreground (for testing)"
echo "3. Stop service"
echo "4. Restart service"
echo "5. View logs"
echo "6. Check status"
echo ""
read -p "Select option (1-6): " option

case $option in
    1)
        print_info "Setting up systemd service..."
        
        sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Secure Spring Boot Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/Secure-Application-Design
ExecStart=/usr/bin/java -jar /home/ec2-user/Secure-Application-Design/${JAR_FILE}
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload
        sudo systemctl enable ${SERVICE_NAME}
        sudo systemctl start ${SERVICE_NAME}
        
        print_success "Service started"
        print_info "Check status with: sudo systemctl status ${SERVICE_NAME}"
        print_info "View logs with: sudo journalctl -u ${SERVICE_NAME} -f"
        ;;
        
    2)
        print_info "Running application in foreground..."
        print_info "Press Ctrl+C to stop"
        echo ""
        sudo java -jar "$JAR_FILE"
        ;;
        
    3)
        print_info "Stopping service..."
        sudo systemctl stop ${SERVICE_NAME}
        print_success "Service stopped"
        ;;
        
    4)
        print_info "Restarting service..."
        sudo systemctl restart ${SERVICE_NAME}
        print_success "Service restarted"
        sudo systemctl status ${SERVICE_NAME}
        ;;
        
    5)
        print_info "Viewing logs (press Ctrl+C to exit)..."
        sudo journalctl -u ${SERVICE_NAME} -f
        ;;
        
    6)
        sudo systemctl status ${SERVICE_NAME}
        echo ""
        print_info "Testing endpoints..."
        curl -k https://localhost:443/api/status 2>/dev/null | jq .
        ;;
        
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
print_success "Done!"
