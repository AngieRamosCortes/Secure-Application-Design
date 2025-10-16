# Aplicación Web Segura - Diseño de Arquitectura Empresarial

Este proyecto demuestra una **aplicación web segura y escalable** desplegada en infraestructura AWS utilizando una arquitectura de dos servidores con cifrado TLS, hashing de contraseñas BCrypt y autenticación mediante API RESTful. La implementación sigue las mejores prácticas de seguridad y patrones arquitectónicos.

**Autor**: Angie Ramos  
**Curso**: Taller de Arquitectura Empresarial  
**Institución**: Universidad Escuela Colombiana de Ingeniería Julio Garavito 
**Fecha**: Octubre 2025  
**Versión**: 1.0

## 📋 Descripción del Proyecto

Esta aplicación implementa un sistema de autenticación seguro utilizando una arquitectura de dos servidores separados:

- **Servidor Apache**: Sirve el cliente HTML/JavaScript mediante HTTPS, proporcionando la interfaz de usuario de forma segura.
- **Servidor Spring Boot**: Proporciona servicios backend mediante una API REST segura, manejando la lógica de autenticación y almacenando contraseñas como hashes BCrypt.

La aplicación cumple con todos los requisitos del taller de arquitectura empresarial, incluyendo:

✅ **Arquitectura de dos servidores** (Apache + Spring Boot)  
✅ **Cifrado TLS/HTTPS** en ambos servidores  
✅ **Cliente HTML+JavaScript asíncrono**  
✅ **API RESTful** con endpoints seguros  
✅ **Hashing de contraseñas BCrypt** para almacenamiento seguro  
✅ **Configuración CORS** para solicitudes entre orígenes  
✅ **Despliegue en AWS** con instancias EC2  
✅ **Certificados SSL** para conexiones seguras  
✅ **Documentación completa** y pruebas automatizadas

## 🚀 Comenzando

Estas instrucciones te permitirán obtener una copia del proyecto funcionando en tu máquina local para propósitos de desarrollo y pruebas. Consulta la sección de **Despliegue** para notas sobre cómo desplegar el proyecto en un sistema en vivo.

### 📋 Pre-requisitos

Qué cosas necesitas para instalar el software y cómo instalarlas:

#### En tu máquina local (Windows/Mac/Linux):

```bash
# Git para clonar el repositorio
git --version

# Java 17 o superior
java -version

# Maven 3.6 o superior
mvn -version

# SSH client (generalmente viene preinstalado)
ssh -V
```

#### En AWS:

- **Cuenta de AWS** activa con permisos para crear instancias EC2
- **2 instancias EC2** t3.micro con Amazon Linux 2023
- **Security Groups** configurados para permitir:
  - Puerto 22 (SSH)
  - Puerto 80 (HTTP)
  - Puerto 443 (HTTPS)
- **Par de claves SSH** (.pem) para acceso a las instancias

### 🔧 Instalación

Una serie de ejemplos paso a paso que te indica cómo obtener un entorno de desarrollo ejecutándose.

#### Paso 1: Clonar el Repositorio

```bash
# Clonar el proyecto
git clone https://github.com/tu-usuario/secure-application-design.git

# Navegar al directorio del proyecto
cd secure-application-design
```

#### Paso 2: Compilar la Aplicación Localmente

```bash
# Compilar el proyecto con Maven
mvn clean package -DskipTests

# Verificar que el JAR se generó correctamente
ls -lh target/secure-app-0.0.1-SNAPSHOT.jar
```

Deberías ver un archivo JAR de aproximadamente 20-30 MB.

#### Paso 3: Configurar las Instancias AWS

```bash
# Conectarse al Servidor Apache (reemplaza con tu IP, esta es la original)
ssh -i "SecurityDesignKey.pem" ec2-user@34.228.157.43

# Actualizar el sistema
sudo dnf update -y
```

#### Paso 4: Desplegar el Servidor Apache

```bash
# En el servidor Apache, ejecutar el script de deployment
chmod +x deploy-apache.sh
./deploy-apache.sh
```

El script instalará automáticamente:
- Apache HTTP Server 2.4
- Módulo mod_ssl para HTTPS
- Certificado SSL 
- Configuración de seguridad

#### Paso 5: Desplegar el Servidor Spring

```bash
# Conectarse al Servidor Spring (reemplaza con tu IP, esta es la original usada en el laboratorio)
ssh -i "SecurityDesignKey.pem" ec2-user@54.236.29.198

# Ejecutar el script de deployment
chmod +x deploy-spring-improved.sh
./deploy-spring-improved.sh
```

El script instalará automáticamente:
- Java 17 Amazon Corretto
- Maven 3.9
- Compilará la aplicación
- Generará keystore SSL
- Creará servicio systemd
- Iniciará la aplicación

#### Paso 6: Verificar la Instalación

```bash
# En el servidor Spring, verificar que la API responde
curl -k https://localhost:443/api/status

# Deberías ver algo como:
# {"service":"Spring Boot Secure API","users":2,"status":"OK","timestamp":"..."}
```
>>>>FOTOOOO api corriendo

#### Paso 7: Acceder a la Aplicación

Abre tu navegador web y ve a:

```
http://34.228.157.43
```

Deberías ver la página de login. Ingresa las credenciales de prueba:
- **Usuario**: `admin`
- **Contraseña**: `password123`

Al hacer clic en "Iniciar sesión", deberías ver un mensaje verde:

```
✓ Autenticación Exitosa
Autenticación exitosa - Bienvenido admin
```

Esto demuestra que:
- El servidor Apache está sirviendo el cliente HTML correctamente
- El cliente JavaScript puede comunicarse con el servidor Spring mediante HTTPS
- La autenticación con BCrypt funciona correctamente

## 🧪 Ejecutando las Pruebas

Explica cómo ejecutar las pruebas automatizadas para este sistema.

### Pruebas de Extremo a Extremo

Estas pruebas verifican que todo el flujo de autenticación funcione correctamente desde el cliente hasta el servidor backend.

#### Prueba 1: Verificar Estado del Servidor Spring

```bash
# Desde el servidor Spring o tu máquina local
curl -k https://54.236.29.198/api/status
```

**Resultado esperado:**
```json
{
  "service": "Spring Boot Secure API",
  "users": 2,
  "status": "OK",
  "timestamp": "2025-10-16T00:45:15.542915136"
}
```
>>>>FOTOOO api status

Esta prueba verifica que el servidor Spring está corriendo y respondiendo correctamente.

#### Prueba 2: Login con Credenciales Válidas

```bash
curl -k -X POST https://54.236.29.198/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}'
```
>>>>FOTOOOO true verificación credenciales válidas

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Autenticación exitosa - Bienvenido admin",
  "username": "admin",
  "timestamp": "2025-10-16T00:45:20.123456789"
}
```

Esta prueba verifica que:
- El endpoint `/api/login` funciona correctamente
- BCrypt valida correctamente las contraseñas
- La respuesta JSON tiene el formato correcto

#### Prueba 3: Login con Credenciales Inválidas

```bash
curl -k -X POST https://54.236.29.198/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"wrongpassword"}'
```
>>>>FOTOOO false ver más

**Resultado esperado:**
```json
{
  "success": false,
  "message": "Contraseña incorrecta",
  "username": "admin"
}
```

Esta prueba verifica que el sistema rechaza correctamente las contraseñas incorrectas.

#### Prueba 4: Usuario No Existente

```bash
curl -k -X POST https://54.236.29.198/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"noexiste","password":"cualquiera"}'
```
>>>>FOTOOOO juan false

**Resultado esperado:**
```json
{
  "success": false,
  "message": "Usuario no encontrado",
  "username": "noexiste"
}
```

### Pruebas de Integración del Cliente

#### Prueba 5: Servidor Apache Sirve la Página

```bash
# Verificar que Apache responde
curl http://34.228.157.43

# Deberías ver el contenido HTML completo
```

#### Prueba 6: Prueba de Login desde el Navegador

1. Abrir: `http://34.228.157.43`
2. Ingresar usuario: `admin`
3. Ingresar contraseña: `password123`
4. Hacer clic en "Iniciar sesión"
5. **Verificar**: Mensaje verde "✓ Autenticación Exitosa" aparece

### Script de Pruebas Automatizadas

Puedes ejecutar todas las pruebas de una vez usando el script incluido:

```bash
# En el servidor Spring
chmod +x test-api.sh
./test-api.sh
```

Este script ejecuta automáticamente todas las pruebas y muestra los resultados con colores:
- ✅ Verde = Prueba exitosa
- ❌ Rojo = Prueba fallida
- ⚠️ Amarillo = Advertencia

### Pruebas de Seguridad

#### Verificar Hashing de Contraseñas

```bash
# En el servidor Spring, verificar los logs
sudo journalctl -u secureapp | grep "hash"

# Deberías ver los hashes BCrypt generados:
# Admin hash: $2a$10$Y7kQvUY0Q8aliNpBwWE57O...
# Angie hash: $2a$10$9.uFhOT1pYim0vrAVmwYbu...
```

Verifica que:
- Los hashes comienzan con `$2a$10$` (BCrypt con factor 10)
- Cada hash es diferente y único
- Las contraseñas nunca aparecen en texto plano en los logs

#### Verificar Conexión TLS/HTTPS

```bash
# Verificar certificado SSL del servidor Spring
openssl s_client -connect 54.236.29.198:443 -showcerts

# Deberías ver información del certificado SSL
```

### Monitoreo y Logs

#### Ver Logs del Servidor Spring en Tiempo Real

```bash
# En el servidor Spring
sudo journalctl -u secureapp -f
```

#### Ver Logs de Apache

```bash
# En el servidor Apache
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

### Resultados Esperados de las Pruebas

Todas las pruebas deberían pasar exitosamente:

| Prueba | Resultado Esperado | Estado |
|--------|-------------------|--------|
| API Status | Responde con JSON | ✅ |
| Login válido | success: true | ✅ |
| Login inválido | success: false | ✅ |
| Usuario no existe | "Usuario no encontrado" | ✅ |
| Apache sirve HTML | Código 200 | ✅ |
| Hashes BCrypt | Formato $2a$10$... | ✅ |
| Conexión TLS | Certificado válido | ✅ |

## 🏗️ Arquitectura del Sistema

### Diseño de Dos Servidores

La aplicación utiliza una arquitectura moderna de dos servidores para separar las responsabilidades y mejorar la seguridad:
**Servidor 1: Apache Web Server**
- **Propósito**: Sirve el cliente HTML/JavaScript estático
- **Seguridad**: HTTP con capacidad HTTPS
- **Instancia**: EC2 t3.micro (Amazon Linux 2023)
- **IP**: 34.228.157.43
- **Puertos**: 80 (HTTP), 443 (HTTPS), 22 (SSH)

**Servidor 2: Aplicación Spring Boot**
- **Propósito**: Servicios backend de API REST
- **Seguridad**: HTTPS con TLS, hashing de contraseñas BCrypt
- **Instancia**: EC2 t3.micro (Amazon Linux 2023)
- **IP**: 54.236.29.198
- **Puerto**: 443 (HTTPS), 22 (SSH)

### Flujo de Comunicación

```
Navegador del Usuario → Servidor Apache (HTTP/HTTPS) → Entrega Cliente HTML/JS
     ↓
     └──→ Servidor Spring (HTTPS) → Endpoints de API REST → Validación BCrypt
```

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     Usuario Final                           │
│                  (Navegador Web)                            │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            Servidor 1: Apache HTTP Server                   │
│            (EC2: 34.228.157.43)                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  - Sirve contenido estático (HTML, CSS, JS)          │   │
│  │  - Puerto 80 (HTTP) y 443 (HTTPS)                    │   │
│  │  - Certificado SSL configurado                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ Fetch API (JavaScript)
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────┐
│           Servidor 2: Spring Boot API                       │
│           (EC2: 54.236.29.198)                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Controladores REST                                  │   │
│  │  - POST /api/login (Autenticación)                   │   │
│  │  - GET  /api/status (Estado del servidor)            │   │
│  │  - GET  /api/hello (Prueba de conectividad)          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Spring Security                                     │   │
│  │  - BCrypt Password Encoder (Factor 10)               │   │
│  │  - Configuración CORS                                │   │
│  │  - Validación de autenticación                       │   │
│  └──────────────────────────────────────────────────────┘   │
│  - Puerto 443 (HTTPS)                                       │
│  - Certificado SSL                                          │
└─────────────────────────────────────────────────────────────┘
```

### Capas de la Arquitectura

| Capa | Componente | Tecnología | Propósito |
|------|-----------|------------|-----------|
| **Presentación** | Servidor Apache | Apache HTTP 2.4 | Servir contenido estático |
| **Lógica del Cliente** | Cliente JavaScript | HTML5, ES6+ JS | Interfaz de usuario y solicitudes asíncronas |
| **Aplicación** | Spring Boot | Java 17, Spring 2.7 | Lógica de negocio y API |
| **Seguridad** | Spring Security | BCrypt, TLS | Autenticación y cifrado |
| **Infraestructura** | AWS EC2 | Amazon Linux 2023 | Alojamiento en la nube |

## 🔐 Características de Seguridad

✅ **Cifrado TLS/HTTPS**: Todos los datos en tránsito están cifrados  
✅ **Hashing de Contraseñas BCrypt**: Contraseñas almacenadas de forma segura con salt  
✅ **Configuración CORS**: Control de recursos compartidos entre orígenes  
✅ **Security Groups**: Reglas de firewall de AWS restringen el acceso  
✅ **Certificados SSL**: Certificados SSL configurados en ambos servidores  
✅ **Validación de Entrada**: Validación null-safe y sanitización de datos  
✅ **Logging de Seguridad**: Registro detallado de intentos de autenticación  

### Implementación de Seguridad Detallada

#### 1. Hashing de Contraseñas con BCrypt

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(); // Factor de trabajo: 10
}

// Las contraseñas NUNCA se almacenan en texto plano
String adminHash = passwordEncoder.encode("password123");
// Resultado: $2a$10$Y7kQvUY0Q8aliNpBwWE57OtQe...
```

**Características de BCrypt:**
- Factor de trabajo ajustable (actualmente 10)
- Salt único generado automáticamente para cada contraseña
- Resistente a ataques de fuerza bruta
- Estándar de la industria para almacenamiento de contraseñas

#### 2. Cifrado TLS/HTTPS

**Servidor Apache:**
```apache
SSLEngine on
```

**Servidor Spring:**
```properties
server.ssl.enabled=true
server.ssl.key-store=/home/ec2-user/keystore.p12
server.ssl.key-store-password=password123
server.ssl.keyStoreType=PKCS12
```

#### 3. Configuración CORS

```java
@Bean
CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(Arrays.asList(
        "http://34.228.157.43",
        "https://34.228.157.43",
        "http://54.236.29.198",
        "https://54.236.29.198"
    ));
    configuration.setAllowedMethods(Arrays.asList(
        "GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"
    ));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);
    return source;
}
```

#### 4. Headers de Seguridad HTTP

```apache
Header always set Strict-Transport-Security "max-age=31536000"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
```

#### 5. Validación de Entrada

```java
String inputUsername = user.getUsername() == null ? "" : user.getUsername().trim();
String inputPassword = user.getPassword() == null ? "" : user.getPassword();

if (inputUsername.isEmpty() || inputPassword.isEmpty()) {
    return ResponseEntity.ok(
        new LoginResponse(false, "Usuario y contraseña son requeridos", null)
    );
}
```  

## 🚀 Stack Tecnológico

### Frontend
- **HTML5** - Estructura de la página web
- **JavaScript (ES6+)** - Lógica del cliente y manejo de eventos
- **Fetch API** - Solicitudes asíncronas al servidor
- **CSS3** - Estilos y diseño responsivo

### Backend
- **Java 17** - Lenguaje de programación principal
- **Spring Boot 2.7.x** - Framework de aplicación
- **Spring Security** - Autenticación y autorización
- **BCrypt** - Algoritmo de hashing de contraseñas
- **Maven 3.9** - Gestión de dependencias y construcción

### Infraestructura
- **AWS EC2** - Instancias de computación en la nube
- **Amazon Linux 2023** - Sistema operativo
- **Apache HTTP Server 2.4** - Servidor web
- **OpenSSL** - Generación de certificados SSL

### Herramientas de Desarrollo
- **Git** - Control de versiones
- **cURL** - Pruebas de API
- **systemd** - Gestión de servicios
- **journalctl** - Visualización de logs

## 📦 Estructura del Proyecto

```
Secure-Application-Design/
├── src/
│   └── main/
│       ├── java/com/angie/secureapp/
│       │   ├── SecureAppApplication.java      # Aplicación principal Spring Boot
│       │   ├── PasswordVerifier.java          # Utilidad para verificar hashes
│       │   ├── config/
│       │   │   └── SecurityConfig.java        # Configuración de Spring Security
│       │   ├── controller/
│       │   │   └── ApiController.java         # Endpoints REST
│       │   └── model/
│       │       ├── User.java                  # Modelo de usuario
│       │       └── LoginResponse.java         # Modelo de respuesta
│       └── resources/
│           └── application.properties         # Configuración de la aplicación
├── index.html                                 # Cliente web
├── pom.xml                                    # Dependencias Maven
├── README.md                                  # Este archivo
├── deploy-apache.sh                          # Script de despliegue Apache
├── deploy-spring-improved.sh                 # Script de despliegue Spring
├── test-api.sh                               # Script de pruebas automatizadas
```

### Descripción de Archivos Principales

| Archivo | Descripción |
|---------|-------------|
| `SecureAppApplication.java` | Punto de entrada de la aplicación Spring Boot |
| `ApiController.java` | Define los endpoints REST y lógica de autenticación |
| `SecurityConfig.java` | Configuración de Spring Security, CORS y BCrypt |
| `index.html` | Interfaz de usuario del cliente web |
| `application.properties` | Configuración del servidor, SSL y logging |
| `pom.xml` | Definición de dependencias Maven |
| `deploy-apache.sh` | Script automatizado para instalar y configurar Apache |
| `deploy-spring-improved.sh` | Script automatizado para desplegar Spring Boot |

## 🔧 Endpoints de la API

### POST /api/login
Autenticar usuario con nombre de usuario y contraseña.

**Solicitud:**
```json
{
  "username": "admin",
  "password": "password123"
}
```

**Respuesta (Éxito):**
```json
{
  "success": true,
  "message": "Autenticación exitosa - Bienvenido admin",
  "username": "admin",
  "timestamp": "2025-10-16T00:45:20.123456789"
}
```

**Respuesta (Fallo):**
```json
{
  "success": false,
  "message": "Contraseña incorrecta",
  "username": "admin",
  "timestamp": "2025-10-16T00:45:20.123456789"
}
```

**Ejemplo de uso con cURL:**
```bash
curl -k -X POST https://54.236.29.198/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}'
```

### GET /api/hello
Endpoint simple de saludo para probar conectividad.

**Respuesta:**
```json
{
  "message": "¡Hola desde el servicio REST seguro!",
  "timestamp": "2025-10-16T00:45:15.542915136"
}
```

**Ejemplo de uso:**
```bash
curl -k https://54.236.29.198/api/hello
```

### GET /api/status
Endpoint de verificación de estado que muestra el estado del servidor.

**Respuesta:**
```json
{
  "status": "OK",
  "service": "Spring Boot Secure API",
  "users": 2,
  "timestamp": "2025-10-16T00:45:15.542915136"
}
```

**Ejemplo de uso:**
```bash
curl -k https://54.236.29.198/api/status
```

## 👤 Credenciales de Prueba

| Usuario | Contraseña    | Descripción        | Hash BCrypt (Ejemplo) |
|---------|---------------|--------------------|-----------------------|
| admin   | password123   | Usuario administrador | $2a$10$Y7kQvUY0Q8aliNpBwWE57O... |
| angie   | angie123      | Usuario regular    | $2a$10$9.uFhOT1pYim0vrAVmwYbu... |

**Nota de Seguridad**: Estos son usuarios de demostración. En producción, las contraseñas deben cumplir con políticas de seguridad robustas y los usuarios deben crearse dinámicamente desde una base de datos.

---

## 🤝 Contribuciones

Las contribuciones son lo que hacen que la comunidad de código abierto sea un lugar increíble para aprender, inspirar y crear. Cualquier contribución que hagas será **muy apreciada**.

### Cómo Contribuir

1. **Fork el Proyecto**
   ```bash
   # Haz clic en el botón "Fork" en GitHub
   ```

2. **Crea tu Rama de Característica**
   ```bash
   git checkout -b feature/CaracteristicaIncreible
   ```

3. **Realiza tus Cambios**
   - Sigue las convenciones de código del proyecto
   - Agrega comentarios claros y descriptivos
   - Actualiza la documentación si es necesario

4. **Commit de tus Cambios**
   ```bash
   git commit -m 'Add: Agregada característica increíble'
   ```
   
   **Convención de mensajes de commit:**
   - `Add:` - Nueva característica
   - `Fix:` - Corrección de bug
   - `Update:` - Actualización de código existente
   - `Docs:` - Cambios en documentación
   - `Style:` - Cambios de formato (no afectan funcionalidad)
   - `Refactor:` - Refactorización de código
   - `Test:` - Agregando o actualizando tests

5. **Push a la Rama**
   ```bash
   git push origin feature/CaracteristicaIncreible
   ```

6. **Abre un Pull Request**
   - Describe claramente qué cambios realizaste
   - Referencia cualquier issue relacionado
   - Incluye screenshots si es aplicable

### Directrices de Contribución

- **Código limpio**: Sigue las mejores prácticas de Java/Spring Boot
- **Seguridad primero**: Cualquier cambio debe mantener o mejorar la seguridad
- **Testing**: Agrega tests para nuevas características
- **Documentación**: Actualiza README y comentarios según sea necesario
- **Commits atómicos**: Un commit por característica/fix

### Reportar Bugs

Si encuentras un bug, por favor abre un **Issue** con:
- Descripción clara del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Screenshots si es aplicable
- Información del entorno (OS, Java version, etc.)

### Solicitar Características

Para solicitar nuevas características, abre un **Issue** con:
- Descripción detallada de la característica
- Casos de uso
- Beneficios esperados
- Posibles implementaciones

---

## 📌 Versionamiento

Este proyecto usa [SemVer](http://semver.org/) para el versionamiento. 

### Historial de Versiones

#### **v1.0.0** - 2025-01-15
**Lanzamiento**
- ✨ Implementación de autenticación con Spring Security
- 🔒 Hashing de contraseñas con BCrypt (factor 10)
- 🌐 API REST con endpoints de login y estado
- 🖥️ Frontend HTML/JavaScript con validación
- 🔐 Configuración SSL/TLS en ambos servidores
- 📋 Configuración CORS para comunicación cross-origin
- 🚀 Scripts automatizados de despliegue
- 📚 Documentación
---

## ✒️ Autores

* **Angie Ramos** - *Desarrollo Completo* - [@AngieRamos](https://github.com/AngieRamos)
  - Diseño de arquitectura de seguridad
  - Implementación backend con Spring Boot
  - Desarrollo frontend con JavaScript
  - Configuración de infraestructura AWS
  - Documentación técnica

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

---

## 🎁 Agradecimientos

Este proyecto fue desarrollado como parte del **Workshop de Enterprise Architecture** en la Universidad Escuela Colombiana de Ingeniería.

### Reconocimientos Especiales

* **Profesores del Workshop**: Por proporcionar los requisitos y guía del proyecto
* **Universidad Escuela Colombiana de Ingeniería**: Por el apoyo académico
* **Comunidad Spring Boot**: Por la excelente documentación y frameworks
* **AWS**: Por proporcionar infraestructura cloud confiable
* **Stack Overflow**: Por resolver innumerables dudas técnicas