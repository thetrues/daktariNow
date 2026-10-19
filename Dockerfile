# Static image for the Flutter web build. Build the app first:
#   flutter build web --release --dart-define=API_BASE_URL=https://api.<domain>/api/v1
# (GitHub Actions does both; see .github/workflows/docker.yml.)
FROM nginx:1.27-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/health || exit 1
