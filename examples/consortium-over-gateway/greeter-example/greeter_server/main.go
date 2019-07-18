/*
 * https://github.com/grpc/grpc-go/tree/master/examples
 * http://krishicks.com/post/2016/11/01/using-grpc-with-mutual-tls-in-golang/
 */

//go:generate protoc -I ../helloworld --go_out=plugins=grpc:../helloworld ../helloworld/helloworld.proto

// Package main implements a server for Greeter service.
package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"io/ioutil"
	"log"
	"net"
	"os"

	pb "../helloworld"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

const (
	port = ":50051"
)

// server is used to implement helloworld.GreeterServer.
type server struct{}

// SayHello implements helloworld.GreeterServer
func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received: %v", in.Name)
	return &pb.HelloReply{Message: "Hello " + in.Name}, nil
}

func main() {

	tlsEnable := os.Getenv("TLS_ENABLE")
	serverCrtPath := os.Getenv("SERVER_CRT")
	serverKeyPath := os.Getenv("SERVER_KEY")
	caCrtPath := os.Getenv("CA_CRT")

	if len(tlsEnable) == 0 {
		panic("need to TLS_EANBLE")
	}
	if len(serverCrtPath) == 0 {
		panic("need to SERVER_CRT")
	}
	if len(serverKeyPath) == 0 {
		panic("need to SERVER_KEY")
	}
	if len(caCrtPath) == 0 {
		panic("need to CA_CRT")
	}

	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	var s *grpc.Server

	switch tlsEnable {
	case "ON":
		certificate, err := tls.LoadX509KeyPair(
			serverCrtPath,
			serverKeyPath,
		)

		certPool := x509.NewCertPool()
		bs, err := ioutil.ReadFile(caCrtPath)
		if err != nil {
			log.Fatalf("failed to read client ca cert: %s", err)
		}

		ok := certPool.AppendCertsFromPEM(bs)
		if !ok {
			log.Fatal("failed to append client certs")
		}

		tlsConfig := &tls.Config{
			ClientAuth:   tls.RequireAndVerifyClientCert,
			Certificates: []tls.Certificate{certificate},
			ClientCAs:    certPool,
		}
		serverOption := grpc.Creds(credentials.NewTLS(tlsConfig))
		s = grpc.NewServer(serverOption)

	default:
		s = grpc.NewServer()
	}

	pb.RegisterGreeterServer(s, &server{})
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
