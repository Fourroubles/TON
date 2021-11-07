pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Multiplication {

	// State variable storing the sum of arguments that were passed to function 'add',
	uint public mult = 1;

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	// Modifier that allows to accept some external messages
	modifier checkOwnerAndAccept(uint value) {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
        // Сheck that the number is in the range
        require(value > 0 && value <= 10 , 101, "number is not in the range");
		tvm.accept();
		_;
	}

	// Function that multiplications its argument to the state variable.
	function multiplication(uint value) public checkOwnerAndAccept(value) {
		mult *= value;
	}
}