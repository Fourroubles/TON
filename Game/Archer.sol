pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";
import "BaseStantion.sol";

contract Archer is MilitaryUnit {
    constructor(BaseStantion base) MilitaryUnit(base) public {
        tvm.accept();
        health = 7;
        powerArmor = 0;
        powerAttack = 4;
    }
}