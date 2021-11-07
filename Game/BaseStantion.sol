
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";

contract BaseStantion is GameObject {

    address[] addressUnits;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        health = 10;
        powerArmor = 3;
    }

    function addUnit(address id) public {
        tvm.accept();
        addressUnits.push(id);
    }
    
    function deleteUnit(address id) public {
        for(uint i = 0; i < addressUnits.length; ++i){
            if(addressUnits[i] == id) {
                for(uint j = i; j < addressUnits.length - 1; ++j){
                    addressUnits[i] = addressUnits[i + 1];
                }

                addressUnits.pop();
                break;
            }
        }
    }

    function resolveDeath(address id) internal override {
        tvm.accept();
        id.transfer(0, true, 160);
    }

}
