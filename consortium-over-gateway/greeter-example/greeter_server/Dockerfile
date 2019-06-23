FROM golang:latest 
RUN mkdir /app 
ADD . /app/ 
WORKDIR /app 

# # install protobuf from source
# RUN apt-get update && \
#     apt-get -y install git unzip build-essential autoconf libtool
# RUN git clone https://github.com/google/protobuf.git && \
#     cd protobuf && \
#     ./autogen.sh && \
#     ./configure && \
#     make && \
#     make install && \
#     ldconfig && \
#     make clean && \
#     cd .. && \
#     rm -r protobuf

# # NOTE: for now, this docker image always builds the current HEAD version of
# # gRPC.  After gRPC's beta release, the Dockerfile versions will be updated to
# # build a specific version.

# # Install protoc-gen-go
# RUN go get github.com/golang/protobuf/protoc-gen-go
# # Create helloworld.pb.go
# RUN protoc -I helloworld/ helloworld/helloworld.proto --go_out=plugins=grpc:helloworld

# Get the source from GitHub
RUN go get google.golang.org/grpc

RUN go build -o main ./greeter_server 
CMD ["/app/main"]
