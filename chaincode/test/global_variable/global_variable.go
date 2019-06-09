package main

/**
 * global variable 이 chaincode에서 어떻게 동작하는지 확인하기 위한 chaincode
 * 결론: global variable은 chaincode가 실행된 peer에는 유지되지만, 다른 peer에는 공유되지 않는다.
 *
 * peer chaincode install -n count -v 1.0 -p github.com/chaincode/test/global_variable/
 * peer chaincode instantiate -o orderer1.ordererorg:7050 -C ch1 -n count -v 1.0 -c '{"Args":["init", ""]}' -P "OR ('Org1MSP.member')"
 * peer chaincode query -C ch1 -n count -c '{"Args":["count", ""]}'
 *
 * CORE_PEER_ADDRESS=peer2.org1:7051 peer chaincode install -n count -v 1.0 -p github.com/chaincode/test/global_variable/
 * CORE_PEER_ADDRESS=peer2.org1:7051 peer chaincode query -C ch1 -n count -c '{"Args":["count", ""]}'
 */
import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

var Count int

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	Count = 0
	fmt.Println("test_global_variable Init")

	return shim.Success(nil)
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("test_global_variable Invoke")
	function, _ := stub.GetFunctionAndParameters()
	if function == "count" {
		return t.count(stub)
	}

	return shim.Error("Invalid invoke function name. Expecting \"invoke\"")
}

func (t *SimpleChaincode) count(stub shim.ChaincodeStubInterface) pb.Response {
	Count = Count + 1
	CountAsByte := []byte(strconv.Itoa(Count))

	return shim.Success(CountAsByte)
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
