# Private Data Collection Unit Test

20190713일 기준 Private Data Collection의 Unittest를 위한 함수들이 Mockstub에 구현이 덜 되어 있다. 관련 JIRA Issue는 아래와 같다.

* [FAB-13140 - Implement GetTransient() method of MockStub](https://jira.hyperledger.org/browse/FAB-13140)

구현 다 해놓고 왜 반영을 안했는지 모르겠다.

## Implementation Details

[FAB-13140](https://jira.hyperledger.org/browse/FAB-13140)의 내용을 보면 구현해야 할 내용들을 이미 다 구현해 놓았다. 다음과 같다.

### New transient field in MockStub

```go
type MockStub struct {
//[...]
// TransientMap arguments
TransientMap map[string][]byte

//[...]
}
```

### New method SetTransient

```go
func (stub *MockStub) setTransient(tMap map[string][]byte) {
   stub.TransientMap = tMap
}
```

### GetTransient will return transient field

```go
func (stub *MockStub) GetTransient() (map[string][]byte, error) {
    return stub.TransientMap, nil
}
```

### Constructor to initialize

```go
// Constructor to initialise the internal State map
func NewMockStub(name string, cc Chaincode) *MockStub {
   //[..]
   s.TransientMap = make(map[string][]byte)
   //[...]
   return s
}
```

## Docker 기반 Private Data Collection Unit Test 

위의 내용을 어떻게 반영해서 Unit Test를 할 까 고민하다가.. `hyperledger/fabric-ccenv` Docker image를 이용해서 간단하게 Unit Test 환경을 구성해서 사용하기로 했다.

Unittest를 실행하기 위한 Container를 구동하기 위한 docker-compose.yaml의 내용은 아래와 같다.

```bash
version: "3"

services:
  pdc_unittester:
    image: hyperledger/fabric-ccenv
    container_name: pdc_unittester
    volumes:
      - ./mockstub.go:/opt/gopath/src/github.com/hyperledger/fabric/core/chaincode/shim/mockstub.go
      - ./chaincode:/chaincode
    working_dir: /chaincode
    command: go test
```

## Execute Unit Test

현재 폴더에서 아래 명령을 실행하면 유명 예제인 `chaincode_example02`를 private data collection 버전으로 살짝 변경해 놓은 `example02_pdc`를 테스트해 볼 수 있다.

```bash
docker-compose up
```
