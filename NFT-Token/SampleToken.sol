
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
contract SampleToken {
    
    struct Token{
        string dogsName;
        string breed;
        uint weight;
        uint price; 
        bool flag;
    }

    Token[] public tokensArr;
    mapping(uint => uint) tokenToOwner;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

    /// @dev Allows to create a token
    /// @param dogName token's name.
    /// @param breed dog breed.
    /// @param weight dog weight.
    function createToken(string dogName, string breed, uint weight) public checkOwnerAndAccept{
        for(uint i = 0; i < tokensArr.length; ++i) {
            // check duplicate
            require(tokensArr[i].dogsName != dogName, 101);
        }  
        
        tokensArr.push(Token(dogName, breed, weight, 0, false));
        tokenToOwner[tokensArr.length - 1] = msg.pubkey();
    }

    /// @dev Allows to indicate price
    /// @param tokenId id owner
    /// @param price price.
    function indicatePrice(uint tokenId, uint price) public checkOwnerAndAccept{
        // check token owner
        require(msg.pubkey() == tokenToOwner[tokenId], 101);
        tokensArr[tokenId].price = price;
        tokensArr[tokenId].flag = true;
    }
}
