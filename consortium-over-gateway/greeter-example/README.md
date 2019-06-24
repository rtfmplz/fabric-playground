# Greeter Example

* go grpc + nginx gateway

## Getting Started


### Without TLS

* docker-compose up

```
docker-compose -f docker-compose-greeter.yaml up
```

* Check "Greeting: Hello world" string in log of greeter_client

```
server_gw_1       | 172.25.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "172.26.0.3"
greeter_server_1  | 2019/06/24 07:04:32 Received: world
client_gw_1       | 172.26.0.3 - - [24/Jun/2019:07:04:32 +0000] "POST /helloworld.Greeter/SayHello HTTP/2.0" 200 18 "-" "grpc-go/1.22.0-dev" "-"
greeter_client_1  | 2019/06/24 07:04:32 Greeting: Hello world
greeter-example_greeter_client_1 exited with code 0
```

* If you try to Repeat the test

```
docker restart greeter-example_greeter_client_1
```

### With TLS





