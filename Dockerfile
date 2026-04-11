FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG FLUTTER_VERSION=3.32.0
RUN git clone https://github.com/flutter/flutter.git /flutter \
    --branch ${FLUTTER_VERSION} \
    --single-branch \
    --depth 1

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"
ENV PUB_HOSTED_URL=https://pub.dev
ENV FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com


# Fully initiallize Flutter
RUN flutter precache --web
RUN flutter config --enable-web


WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --no-tree-shake-icons

FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

ENV PORT=10000
EXPOSE 10000

CMD ["nginx", "-g", "daemon off;"]


