#!/bin/bash

##############################################################################
# Script de Prueba de la API Spring Boot
# Prueba todos los endpoints para verificar que funcionan correctamente
# Autor: Angie Ramos
##############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m'

SPRING_URL="https://54.236.29.198"

echo -e "${BLUE}================================"
echo "Testing Spring Boot API"
echo "================================${NC}"
echo ""

# Test 1: Status endpoint
echo -e "${BLUE}Test 1: GET /api/status${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" "${SPRING_URL}/api/status")
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    echo -e "${GREEN}✓ Status endpoint OK${NC}"
    echo "Response: $body"
else
    echo -e "${RED}✗ Status endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 2: Hello endpoint
echo -e "${BLUE}Test 2: GET /api/hello${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" "${SPRING_URL}/api/hello")
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    echo -e "${GREEN}✓ Hello endpoint OK${NC}"
    echo "Response: $body"
else
    echo -e "${RED}✗ Hello endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 3: Login con credenciales válidas - admin
echo -e "${BLUE}Test 3: POST /api/login (admin/password123)${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "${SPRING_URL}/api/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"password123"}')
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    if echo "$body" | grep -q '"success":true'; then
        echo -e "${GREEN}✓ Login exitoso para admin${NC}"
    else
        echo -e "${YELLOW}⚠ Login falló (credenciales incorrectas)${NC}"
    fi
    echo "Response: $body"
else
    echo -e "${RED}✗ Login endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 4: Login con credenciales válidas - angie
echo -e "${BLUE}Test 4: POST /api/login (angie/angie123)${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "${SPRING_URL}/api/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"angie","password":"angie123"}')
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    if echo "$body" | grep -q '"success":true'; then
        echo -e "${GREEN}✓ Login exitoso para angie${NC}"
    else
        echo -e "${YELLOW}⚠ Login falló (credenciales incorrectas)${NC}"
    fi
    echo "Response: $body"
else
    echo -e "${RED}✗ Login endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 5: Login con credenciales inválidas
echo -e "${BLUE}Test 5: POST /api/login (usuario/wrong)${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "${SPRING_URL}/api/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"wrongpassword"}')
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    if echo "$body" | grep -q '"success":false'; then
        echo -e "${GREEN}✓ Login rechazado correctamente${NC}"
    else
        echo -e "${YELLOW}⚠ Login debería haber fallado${NC}"
    fi
    echo "Response: $body"
else
    echo -e "${RED}✗ Login endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

# Test 6: Usuario inexistente
echo -e "${BLUE}Test 6: POST /api/login (usuario inexistente)${NC}"
response=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST "${SPRING_URL}/api/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"noexiste","password":"password"}')
http_code=$(echo "$response" | grep HTTP_CODE | cut -d: -f2)
body=$(echo "$response" | sed '/HTTP_CODE/d')

if [ "$http_code" == "200" ]; then
    if echo "$body" | grep -q '"success":false'; then
        echo -e "${GREEN}✓ Usuario inexistente manejado correctamente${NC}"
    else
        echo -e "${YELLOW}⚠ Debería rechazar usuario inexistente${NC}"
    fi
    echo "Response: $body"
else
    echo -e "${RED}✗ Login endpoint failed (HTTP $http_code)${NC}"
fi
echo ""

echo -e "${BLUE}================================"
echo "Pruebas completadas"
echo "================================${NC}"
