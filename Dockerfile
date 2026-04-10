FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa wget \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git /flutter \
    --branch stable --single-branch --depth 1

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Skip precache — just enable web and build
RUN flutter config --enable-web

WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


