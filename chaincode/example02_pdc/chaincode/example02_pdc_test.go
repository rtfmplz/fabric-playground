/*
Copyright IBM Corp. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package example02

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

func checkInit(t *testing.T, stub *shim.MockStub, args [][]byte) {
	res := stub.MockInit("1", args)
	if res.Status != shim.OK {
		fmt.Println("Init failed", string(res.Message))
		t.FailNow()
	}
}

func checkState(t *testing.T, stub *shim.MockStub, name string, value string) {
	bytes := stub.State[name]
	if bytes == nil {
		fmt.Println("State", name, "failed to get value")
		t.FailNow()
	}
	if string(bytes) != value {
		fmt.Println("State value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

func checkPvtState(t *testing.T, stub *shim.MockStub, collection string, name string, value string) {
	bytes := stub.PvtState[collection][name]
	if bytes == nil {
		fmt.Println("PvtState", name, "failed to get value")
		t.FailNow()
	}
	if string(bytes) != value {
		fmt.Println("PvtState value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

func checkQuery(t *testing.T, stub *shim.MockStub, name string, value string) {
	res := stub.MockInvoke("1", [][]byte{[]byte("query"), []byte(name)})
	if res.Status != shim.OK {
		fmt.Println("Query", name, "failed", string(res.Message))
		t.FailNow()
	}
	if res.Payload == nil {
		fmt.Println("Query", name, "failed to get value")
		t.FailNow()
	}
	if string(res.Payload) != value {
		fmt.Println("Query value", name, "was not", value, "as expected")
		t.FailNow()
	}
}

func checkInvoke(t *testing.T, stub *shim.MockStub, args [][]byte) {
	res := stub.MockInvoke("1", args)
	if res.Status != shim.OK {
		fmt.Println("Invoke", args, "failed", string(res.Message))
		t.FailNow()
	}
}

func TestExample02_Init(t *testing.T) {
	scc := new(SimpleChaincode)
	stub := shim.NewMockStub("ex02", scc)

	type pdcTransientInput struct {
		Aname string `json:"a_name"`
		Aval  int    `json:"a_val"`
		Bname string `json:"b_name"`
		Bval  int    `json:"b_val"`
	}

	result, err := json.Marshal(pdcTransientInput{"A", 123, "B", 234})
	if err != nil {
		panic(err)
	}

	transientMap := map[string][]byte{"initData": result}
	stub.SetTransient(transientMap)

	checkInvoke(t, stub, [][]byte{[]byte("init")})

	checkPvtState(t, stub, "pdc_org1_org2", "A", "123")
	checkPvtState(t, stub, "pdc_org1_org2", "B", "234")
}
