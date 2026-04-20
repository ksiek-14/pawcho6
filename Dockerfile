# syntax=docker/dockerfile:1

# ETAP 1: Klonowanie repozytorium przez SSH (BuildKit secret)
FROM alpine:latest AS cloner

RUN apk add --no-cache git openssh-client

# Dodaje GH do known_hosts
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Klonuje repo przez SSH
RUN --mount=type=ssh \
    git clone git@github.com:ksiek-14/pawcho6.git /repo_src

# Nadaje prawa wykonywania
RUN chmod +x /repo_src/start.sh

# ETAP 2: Finalny obraz produkcyjny
FROM nginx:alpine

# adnotacja OCI
LABEL org.opencontainers.image.source="https://github.com/ksiek-14/pawcho6"

# Wersja aplikacji
ARG VERSION=v6.0.0
ENV APP_VERSION=${VERSION}

# curl tylko do healthchecka
RUN apk add --no-cache curl

# Kopiuje pliki z etapu cloner
COPY --from=cloner /repo_src/index.html /usr/share/nginx/html/index.html
COPY --from=cloner /repo_src/start.sh /start.sh

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["/start.sh"]
