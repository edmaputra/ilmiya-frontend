# How-To: Backend API Integration & CORS Configuration

This guide walks through connecting the **Ilmiya** Flutter frontend to an external backend service, configuring required headers, resolving Cross-Origin Resource Sharing (CORS) policies, and handling RFC 9457 standard errors.

---

## Overview

When running in **Live REST API** mode, the application delegates all data operations to `ApiClient` (`lib/core/services/api_client.dart`). All outgoing HTTP traffic is normalized with standard headers and wrapped with automatic error parsing and token refresh interceptors.

```mermaid
sequenceDiagram
    autonumber
    participant UI as Flutter UI
    participant Client as ApiClient
    participant BE as Backend API Gateway
    
    UI->>Client: request(endpoint, method, body)
    Client->>Client: Attach X-Tenant-ID & Authorization Header
    Client->>BE: HTTP Request (GET/POST/PUT/PATCH/DELETE)
    alt Successful (200..299)
        BE-->>Client: JSON Response Body
        Client-->>UI: Parsed Data Map / Model
    else 401 Unauthorized (Expired Token)
        BE-->>Client: 401 Unauthorized
        Client->>BE: POST /api/v1/auth/refresh { refreshToken }
        BE-->>Client: 200 OK { accessToken, refreshToken }
        Client->>BE: Retry Original Request with New Bearer
        BE-->>Client: 200 OK
        Client-->>UI: Parsed Data
    else Error (4xx / 5xx Problem Details)
        BE-->>Client: RFC 9457 Problem Details JSON
        Client-->>UI: throws ApiException(status, message, data)
        UI->>UI: Render Toast / Error Banner
    end
```

---

## Step 1: Mandatory Request Headers

Every request issued by `ApiClient` includes four core headers:

```http
Content-Type: application/json
Accept: application/json
X-Tenant-ID: tenant-lincoln-high-001
Authorization: Bearer eyJhbGciOiJSUzI1NiIsIn...
```

- **`X-Tenant-ID`**: Transmits the active tenant partition. Required by downstream multi-tenant microservices to scope queries.
- **`Authorization`**: Transmits the JWT access token for authenticated endpoints. Omitted only when unauthenticated or during initial login.

---

## Step 2: Backend API Contract Reference

Your backend service must implement the following REST endpoints at `ILMIYA_API_BASE_URL`:

### 1. Authentication & Session
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Email/password sign-in. Returns access token, refresh token, tenantId, and roles. |
| `POST` | `/api/v1/auth/refresh` | Exchanges `{ "refreshToken": "..." }` for renewed tokens. |
| `POST` | `/api/v1/auth/logout` | Invalidation endpoint for current session. |
| `POST` | `/api/v1/auth/switch-tenant` | Changes tenant context. Body: `{ "tenantId": "..." }`. |

### 2. IAM & Directory
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/iam/users/me` | Fetches current user profile and permission list. |
| `GET` | `/api/v1/iam/users` | Lists users scoped to the active tenant. |
| `POST` | `/api/v1/iam/users` | Provisions a new user account. |
| `PATCH` | `/api/v1/iam/users/{userId}/status` | Updates user state (`ACTIVE`, `SUSPENDED`, etc.). |
| `POST` | `/api/v1/iam/users/{userId}/roles` | Assigns an RBAC role to a user. |
| `DELETE` | `/api/v1/iam/users/{userId}` | Deletes a user account. |
| `GET` | `/api/v1/iam/roles` | Lists available roles. |
| `POST` | `/api/v1/iam/roles` | Creates a custom role. |
| `GET` | `/api/v1/iam/groups` | Lists organizational directory groups. |
| `POST` | `/api/v1/iam/groups` | Creates a new group. |
| `POST` | `/api/v1/iam/groups/{groupId}/members` | Adds a user to a group. |
| `GET` | `/api/v1/iam/scopes` | Retrieves the permission scope hierarchy tree. |

### 3. Institutional Settings & Academic Calendar
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/schools/profile` | Retrieves tenant school profile details. |
| `PUT` | `/api/v1/schools/profile` | Updates school profile details. |
| `GET` | `/api/v1/schools/settings` | Fetches operational settings (working days, hours). |
| `PUT` | `/api/v1/schools/settings` | Updates operational settings. |
| `GET` | `/api/v1/academic-years` | Lists all academic years for the tenant. |
| `GET` | `/api/v1/academic-years/active` | Retrieves the currently active academic year. |
| `POST` | `/api/v1/academic-years` | Provisions a new academic year. |
| `POST` | `/api/v1/academic-years/{yearId}/activate` | Sets an academic year as active. |
| `POST` | `/api/v1/academic-years/{yearId}/terms` | Appends a term to an academic year. |

---

## Step 3: CORS Configuration on the Backend

When Flutter runs on the Web (`localhost:8080` or a browser domain), the browser enforces strict CORS preflight checks (`OPTIONS`). The backend **must** permit the `X-Tenant-ID` and `Authorization` headers.

### Option A: Spring Boot / Java

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.cors.CorsConfigurationSource;
import java.util.List;

@Configuration
public class WebCorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        
        // Allowed origins for Flutter web development & production
        config.setAllowedOrigins(List.of(
            "http://localhost:8080",
            "http://127.0.0.1:8080",
            "https://app.ilmiya.edu"
        ));
        
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        
        // Critical headers: X-Tenant-ID must be explicitly allowed
        config.setAllowedHeaders(List.of(
            "Authorization",
            "Content-Type",
            "Accept",
            "X-Tenant-ID"
        ));
        
        config.setExposedHeaders(List.of("Authorization"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

### Option B: Node.js / Express

```javascript
const express = require('express');
const cors = require('cors');
const app = express();

const corsOptions = {
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080', 'https://app.ilmiya.edu'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Authorization', 'Content-Type', 'Accept', 'X-Tenant-ID'],
  exposedHeaders: ['Authorization'],
  credentials: true,
};

app.use(cors(corsOptions));
```

### Option C: Python / FastAPI

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "https://app.ilmiya.edu"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type", "Accept", "X-Tenant-ID"],
    expose_headers=["Authorization"],
)
```

### Option D: Nginx Ingress / Reverse Proxy

If terminating CORS at Nginx:

```nginx
server {
    listen 80;
    server_name api.ilmiya.edu;

    location /api/ {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '$http_origin' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept, X-Tenant-ID' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        add_header 'Access-Control-Allow-Origin' '$http_origin' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;

        proxy_pass http://backend_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Step 4: RFC 9457 Problem Details Error Format

When a request fails (`status >= 400`), `ApiClient` expects the backend to return an **RFC 9457 Problem Details** JSON object:

```json
{
  "type": "https://api.ilmiya.edu/errors/tenant-suspended",
  "title": "Tenant Account Suspended",
  "status": 403,
  "detail": "Subscription billing lapsed for tenant-lincoln-high-001. Access is temporarily restricted.",
  "instance": "/api/v1/schools/profile"
}
```

### How ApiClient Handles It:
```dart
// lib/core/services/api_client.dart
String message = 'Request failed with status ${response.statusCode}';
Map<String, dynamic>? errorData;
try {
  final decoded = jsonDecode(response.body);
  if (decoded is Map<String, dynamic>) {
    errorData = decoded;
    message = decoded['detail'] as String? ??
        decoded['title'] as String? ??
        decoded['message'] as String? ??
        message;
  }
} catch (_) {}

throw ApiException(response.statusCode, message, errorData);
```

The parsed `detail` or `title` is caught by presentation screens and rendered in feedback banners or toasts:
```dart
} on ApiException catch (e) {
  _showErrorSnackBar(e.message);
}
```

---

## Step 5: Verification & Inspection

### 1. Test Backend Connectivity via cURL
Simulate a request with all required headers:

```bash
curl -i -X GET http://localhost:8080/api/v1/schools/profile \
  -H "Accept: application/json" \
  -H "X-Tenant-ID: tenant-lincoln-high-001" \
  -H "Authorization: Bearer <your_jwt_token>"
```

### 2. Verify CORS Preflight via cURL
```bash
curl -i -X OPTIONS http://localhost:8080/api/v1/schools/profile \
  -H "Origin: http://localhost:8080" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization,X-Tenant-ID"
```
**Expected Response:** `200 OK` or `204 No Content` containing `Access-Control-Allow-Headers: ...X-Tenant-ID...`.

### 3. Inspect In-Browser (Chrome DevTools)
1. Open Chrome DevTools (`F12` or `Cmd+Option+I`) and switch to the **Network** tab.
2. Filter by `Fetch/XHR`.
3. Perform an action in Ilmiya (e.g. refresh School Profile or Academic Years).
4. Inspect the request: verify `X-Tenant-ID` is present in request headers and the response code is `200 OK`.
