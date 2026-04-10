# Stage 1: Build Flutter Web
FROM debian:bookworm-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter \
    --branch dev --single-branch --depth 1

# Add Flutter to PATH
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Enable web and pre-cache
RUN flutter precache --web
RUN flutter config --enable-web

# Set working directory and copy project
WORKDIR /app
COPY . .

# Install dependencies and build
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]