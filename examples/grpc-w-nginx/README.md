# Greeter Example

* go grpc server/client +nginx gateway

## W/O TLS + NGINX Layer 7 load balancing

Execute example

```bash
docker-compose up
```

Cleanup example

```bash
docker-compose up
```

## W/ TLS + NGINX Layer 4 load balancing

Execute example

```bash
docker-compose -f docker-compose-w-tls up
```

Cleanup example

```bash
docker-compose -f docker-compose-w-tls down
```
