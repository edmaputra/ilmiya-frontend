# Multi-stage Dockerfile for Ilmiya Frontend (Flutter Web)
# Stage 1: Build Flutter Web application
FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app

# Disable analytics and enable web
RUN flutter config --no-analytics && flutter config --enable-web

# Cache dependencies
COPY pubspec.yaml pubspec.lock ./
COPY packages packages/
RUN flutter pub get

# Copy full source tree
COPY . .

# Build arguments for compile-time constants
ARG ILMIYA_API_BASE_URL=https://ilmiya.localhost
ARG ILMIYA_DEFAULT_TENANT_ID=tenant-lincoln-high-001

# Compile Flutter web release
# Use --no-wasm-dry-run for fast, memory-safe JavaScript compilation
RUN flutter build web --release \
    --no-wasm-dry-run \
    --dart-define=ILMIYA_API_BASE_URL=${ILMIYA_API_BASE_URL} \
    --dart-define=ILMIYA_DEFAULT_TENANT_ID=${ILMIYA_DEFAULT_TENANT_ID}

# Stage 2: Production Nginx Runtime
FROM nginx:alpine AS runner

# Configure custom Nginx SPA and healthcheck configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled web output
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy entrypoint script for dynamic Vault/Consul runtime configuration
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
