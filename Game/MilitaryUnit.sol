pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";
import "BaseStantion.sol";

contract MilitaryUnit is GameObject {

    BaseStantion baseAddress;

    constructor(BaseStantion base) public {
        tvm.accept();
        base.addUnit(this);
        baseAddress = base;
    }

    function attack(InterfaceGameObject id) public {
        tvm.accept();
        id.takeAttack(powerAttack);
    }

    function resolveDeath(address id) internal override {
        tvm.accept();
        baseAddress.deleteUnit(this);
        sendCristalsAndDestroy(id);
    }
    
    function deathByBaseDestruction(address id) external {
        require(msg.sender == baseAddress, 100);
        sendCristalsAndDestroy(id);
    }
}

/*
signer 1 (owner_keys_task_3) :
B:  0:cb2756701d80b5713fef89b3fa26791626ef2bc840964ba2dab15088a04df362 10(3)  
W:  0:0bb9c4b96d61022c61af6685e215129e182ac1982cfb7b0b74879220fa172af3
A:  0:11613951690404e5a5c4007973c297b24872252f67d388822297db6df7ff54dc

signer 2 (owner_keys_task_4) :
B:  0:85a48b14d2196ae404695dd1d8a9f501c730cb991c513e87004782bfdb758d5d
W:  0:72bc55d4d51a90db65e99d2e2d6a48ab0817448059b4f9ce7f96a90c2491c35c
A:  0:3364a42f1f787503ecb8d99ec4ac90fbdea40899909841dedf94cb6a4c6354ac
 */