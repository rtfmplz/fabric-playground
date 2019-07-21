# Greeter Example

* go grpc + nginx gateway

## Getting Started

* docker-compose up

```bash
docker-compose -f docker-compose-greeter.yaml up [--build]
```

### W/O TLS + NGINX Layer 7 load balancing

#### Config

* W/O TLS
  * `.env`: `TLS=OFF`
* NGINX Layer 7 load balancing
  * ./greeter_server/nginx/nginx.conf
    * include /etc/nginx/conf.d/gw-http-inbound.conf;
    * #include  /etc/nginx/conf.d/gw-stream-outbound.conf;
  * ./greeter_client/nginx/nginx.conf
    * include /etc/nginx/conf.d/gw-http-inbound.conf;
    * #include  /etc/nginx/conf.d/gw-stream-outbound.conf;

> Layer 7 load balancing 설정 상태에서 `TLS=ON` 으로 환경변수를 설정하면 아래와 같은 error 가 발생한다.
>
> ```bash
> Attaching to greeter-example_greeter_server_1, greeter-example_client_gw_1, greeter-example_server_gw_1, greeter-example_greeter_client_1
> greeter_client_1  | 2019/06/25 13:37:12 could not greet: rpc error: code = Unavailable desc = all SubConns are in TransientFailure, latest connection error: connection error: desc = "transport: authentication handshake failed: tls: first record does not look like a TLS handshake"
>```

#### Result

```bash
server_gw_1       | 172.25.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "172.26.0.3"
greeter_server_1  | 2019/06/24 07:04:32 Received: world
client_gw_1       | 172.26.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "-"
greeter_client_1  | 2019/06/24 07:04:32 Greeting: Hello world
greeter-example_greeter_client_1 exited with code 0
```

### W/ TLS + NGINX Layer 4 load balancing

#### Config

* W/O TLS
  * `.env`: `TLS=ON`
* NGINX Layer 4 load balancing
  * ./greeter_server/nginx/nginx.conf
    * #include /etc/nginx/conf.d/gw-http-inbound.conf;
    * include /etc/nginx/conf.d/gw-stream-outbound.conf;
  * ./greeter_client/nginx/nginx.conf
    * #include /etc/nginx/conf.d/gw-http-inbound.conf;
    * include /etc/nginx/conf.d/gw-stream-outbound.conf;

#### Result

```bash
greeter_server_1  | 2019/06/24 16:03:43 Received: world
greeter_client_1  | 2019/06/24 16:03:43 Greeting: Hello world
greeter-example_greeter_client_1 exited with code 0
```
