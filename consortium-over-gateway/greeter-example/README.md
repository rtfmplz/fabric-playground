# Greeter Example

* go grpc + nginx gateway

## Getting Started

* docker-compose up

```
docker-compose -f docker-compose-greeter.yaml up [--build]
```

### W/O TLS

* 설정 변경
    * `.env`: `TLS=OFF`
    * ./greeter_server/nginx/nginx.conf
        * #include /etc/nginx/conf.d/gw-http-*.conf;
        * include	/etc/nginx/conf.d/gw-stream-*.conf;

* Result

```
server_gw_1       | 172.25.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "172.26.0.3"
greeter_server_1  | 2019/06/24 07:04:32 Received: world
client_gw_1       | 172.26.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "-"
greeter_client_1  | 2019/06/24 07:04:32 Greeting: Hello world
greeter-example_greeter_client_1 exited with code 0
```

### W/ TLS

* 설정 변경
    * `.env`: `TLS=OFF`
    * ./greeter_server/nginx/nginx.conf
        * include /etc/nginx/conf.d/gw-http-*.conf;
        * #include	/etc/nginx/conf.d/gw-stream-*.conf;

* Result

```
greeter_server_1  | 2019/06/24 16:03:43 Received: world
greeter_client_1  | 2019/06/24 16:03:43 Greeting: Hello world
greeter-example_greeter_client_1 exited with code 0
```