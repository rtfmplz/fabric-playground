package example02

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

const (
	pdcName = "pdc_org1_org2"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

// private data APIs are not allowed in chaincode Init()
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()

	if function == "init" {
		return t.init(stub, args)
	} else if function == "invoke" {
		return t.invoke(stub, args)
	} else if function == "delete" {
		return t.delete(stub, args)
	} else if function == "query" {
		return t.query(stub, args)
	}

	return shim.Error("Invalid invoke function name. Expecting \"init\" \"invoke\" \"delete\" \"query\"")
}

func (t *SimpleChaincode) init(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var err error

	stub.SetEvent("init", []byte("payload"))

	type example02PdcTransientInput struct {
		Aname string `json:"a_name"`
		Aval  int    `json:"a_val"`
		Bname string `json:"b_name"`
		Bval  int    `json:"b_val"`
	}

	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	if _, ok := transMap["initData"]; !ok {
		return shim.Error("initData must be a key in the transient map")
	}

	if len(transMap["initData"]) == 0 {
		return shim.Error("initData value in the transient map must be a non-empty JSON string")
	}

	var transientInput example02PdcTransientInput
	err = json.Unmarshal(transMap["initData"], &transientInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(transMap["initData"]))
	}

	err = stub.PutPrivateData(pdcName, transientInput.Aname, []byte(strconv.Itoa(transientInput.Aval)))
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutPrivateData(pdcName, transientInput.Bname, []byte(strconv.Itoa(transientInput.Bval)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

// Transaction makes payment of X units from A to B
func (t *SimpleChaincode) invoke(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var Aval, Bval int // Asset holdings
	var X int          // Transaction value
	var err error

	stub.SetEvent("invoke", []byte("payload"))

	type transferTransientInput struct {
		Sender   string `json:"sender"`
		Receiver string `json:"receiver"`
		Val      int    `json:"val"`
	}

	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	if _, ok := transMap["transferData"]; !ok {
		return shim.Error("transferData must be a key in the transient map")
	}

	if len(transMap["transferData"]) == 0 {
		return shim.Error("transferData value in the transient map must be a non-empty JSON string")
	}

	var transientInput transferTransientInput
	err = json.Unmarshal(transMap["transferData"], &transientInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(transMap["transferData"]))
	}

	// Get the state from the ledger
	// TODO: will be nice to have a GetAllState call to ledger
	Avalbytes, err := stub.GetPrivateData(pdcName, transientInput.Sender)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if Avalbytes == nil {
		return shim.Error("Entity not found")
	}
	Aval, _ = strconv.Atoi(string(Avalbytes))

	Bvalbytes, err := stub.GetPrivateData(pdcName, transientInput.Receiver)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if Bvalbytes == nil {
		return shim.Error("Entity not found")
	}
	Bval, _ = strconv.Atoi(string(Bvalbytes))

	// Perform the execution
	X = transientInput.Val
	if err != nil {
		return shim.Error("Invalid transaction amount, expecting a integer value")
	}
	Aval = Aval - X
	Bval = Bval + X
	fmt.Printf("Aval = %d, Bval = %d\n", Aval, Bval)

	// Write the state back to the ledger
	err = stub.PutPrivateData(pdcName, transientInput.Sender, []byte(strconv.Itoa(Aval)))
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutPrivateData(pdcName, transientInput.Receiver, []byte(strconv.Itoa(Bval)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

// Deletes an entity from state
func (t *SimpleChaincode) delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	stub.SetEvent("delete", []byte("payload"))
	A := args[0]

	// Delete the key from the state in ledger
	err := stub.DelState(A)
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	return shim.Success(nil)
}

// query callback representing the query of a chaincode
func (t *SimpleChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var A string // Entities
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the person to query")
	}

	stub.SetEvent("query", []byte("payload"))
	A = args[0]

	// Get the state from the ledger
	Avalbytes, err := stub.GetPrivateData(pdcName, A)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	if Avalbytes == nil {
		jsonResp := "{\"Error\":\"Nil amount for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	jsonResp := "{\"Name\":\"" + A + "\",\"Amount\":\"" + string(Avalbytes) + "\"}"
	fmt.Printf("Query Response:%s\n", jsonResp)
	return shim.Success(Avalbytes)
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
