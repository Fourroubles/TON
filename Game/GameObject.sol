pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "InterfaceGameObject.sol";

contract GameObject is InterfaceGameObject {
    uint public health = 5;
    uint public powerArmor;
    uint public powerAttack;

    function getPowerArmor() public view returns (uint) {
        tvm.accept();
        return powerArmor;
    }

    function takeAttack(uint damage) external override {
        tvm.accept();

        if(damage - powerArmor > health) {
            health = 0;
        }
        else {
            health -= (damage - powerArmor); 
        }

        if(checkDied()) {
            resolveDeath(msg.sender);
        }
    }

    function checkDied() private returns (bool) {
        if(health <= 0 ) {
            return true;
        }
        else {
            return false;
        }
    }

    function resolveDeath(address id) virtual internal {
        sendCristalsAndDestroy(id);
    }

    function sendCristalsAndDestroy(address id) internal {
        tvm.accept();
        id.transfer(0, true, 160);
    }
}
