/*
 * https://github.com/grpc/grpc-go/tree/master/examples
 * http://krishicks.com/post/2016/11/01/using-grpc-with-mutual-tls-in-golang/
 */

// Package main implements a client for Greeter service.
package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"io/ioutil"
	"log"
	"os"
	"time"

	pb "../helloworld"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

const (
	host        = "greeter.server"
	port        = "50051"
	address     = host + ":" + port
	defaultName = "world"
)

func dialWithTls(crtPath string, keyPath string, caCrtPath string) grpc.DialOption {
	certificate, err := tls.LoadX509KeyPair(
		crtPath,
		keyPath,
	)
	certPool := x509.NewCertPool()
	bs, err := ioutil.ReadFile(caCrtPath)
	if err != nil {
		log.Fatalf("failed to read ca cert: %s", err)
	}

	ok := certPool.AppendCertsFromPEM(bs)
	if !ok {
		log.Fatal("failed to append certs")
	}

	transportCreds := credentials.NewTLS(&tls.Config{
		ServerName:   host,
		Certificates: []tls.Certificate{certificate},
		RootCAs:      certPool,
	})

	return grpc.WithTransportCredentials(transportCreds)
}

func main() {

	tlsEnable := os.Getenv("TLS_ENABLE")
	clientCrtPath := os.Getenv("CLIENT_CRT")
	clientKeyPath := os.Getenv("CLIENT_KEY")
	caCrtPath := os.Getenv("CA_CRT")

	if len(tlsEnable) == 0 {
		panic("need to TLS_ENABLE")
	}
	if len(clientCrtPath) == 0 {
		panic("need to CLIENT_CRT")
	}
	if len(clientKeyPath) == 0 {
		panic("need to CLIENT_KEY")
	}
	if len(caCrtPath) == 0 {
		panic("need to CA_CRT")
	}

	var dialOption grpc.DialOption

	switch tlsEnable {
	case "ON":
		dialOption = dialWithTls(clientCrtPath, clientKeyPath, caCrtPath)
	default:
		dialOption = grpc.WithInsecure()
	}

	// Set up a connection to the server.
	conn, err := grpc.Dial(address, dialOption)
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)

	// Contact the server and print out its response.
	name := defaultName
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}
	log.Printf("Greeting: %s", r.Message)
}
