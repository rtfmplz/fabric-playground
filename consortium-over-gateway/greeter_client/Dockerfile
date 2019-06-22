FROM golang
RUN go get -u google.golang.org/grpc
WORKDIR $GOPATH/src/google.golang.org/grpc/examples/helloworld
COPY ./greeter_client/greeter_client.go .
ARG host
COPY ./certs/CertAuth.crt .
COPY ./certs/${host}.crt .
COPY ./certs/${host}.key .

ENV host ${host}

EXPOSE 80
CMD go run greeter_client.go $host

