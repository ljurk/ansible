# traefik

This role deploys Traefik as a quadlet (systemd service) using podman. Traefik is configured via YAML files and does not have access to the Docker socket.

## Requirements

- podman
- quadlet support (podman >= 4.4)

### Defaults

```yaml
::include{file=defaults/main.yml}
```

## Overview

Traefik uses the [file provider](https://doc.traefik.io/traefik/providers/file/) for configuration. The main configuration is stored in `traefik.yml` and routes are placed in `routes.yml`.

### Directories

- Config: `{{ traefik__dir }}`
- ACME (TLS certificates): `{{ traefik__dir }}/acme`

### Ports

By default, the following ports are exposed: HTTP (80), HTTPS (443).

## Configuration

### Main configuration

Customize the main Traefik configuration via `traefik__config`. This directly maps to the Traefik static configuration:

```yaml
traefik__config:
  log:
    level: INFO
  entryPoints:
    http:
      address: ":80"
    https:
      address: ":443"
```

### Routes

Define router and service configurations using `traefik__routes`. This creates a `routes.yml` file that Traefik watches for changes:

```yaml
traefik__routes:
  http:
    routers:
      my-service:
        rule: "Host(`service.example.com`)"
        service: my-service
        entryPoints:
          - https
        tls: {}

    services:
      my-service:
        loadBalancer:
          servers:
            - url: "http://backend:80"
```

To enable TLS with the LetsEncrypt certificate resolver, add:

```yaml
        tls:
          certResolver: letsencrypt
```

See also [Traefik HTTP routing](https://doc.traefik.io/traefik/routing/overview/).

### ACME / TLS

The role configures the Harica certificate resolver by default (TU Dresden specific). The ACME storage is located at `{{ traefik__dir }}/acme/acme.json`.

See [Traefik HTTPS & TLS](https://doc.traefik.io/traefik/https/overview/) for more information.

### Dashboard

The Traefik dashboard is disabled by default. To enable it:

```yaml
traefik__config:
  api:
    dashboard: true
    insecure: true
```

Note: When enabling the dashboard, you must also expose port 8080 in `traefik__ports`.
