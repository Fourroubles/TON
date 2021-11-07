pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";
import "BaseStantion.sol";

contract Warrior is MilitaryUnit {
    uint fj;
    constructor(BaseStantion base) MilitaryUnit(base) public {
        tvm.accept();
        health = 10;
        powerArmor = 2;
        powerAttack = 2;
    }
}
