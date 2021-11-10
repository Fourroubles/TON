pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Purchase {
    uint32 id;
    string name;
    uint amount;
    uint64 timeCreate;
    bool isBuy;
    uint32 price;
}

struct SummaryPurchase {
    uint32 paidCount;
    uint32 unPaidCount;
    uint32 totalPrice;
}

abstract contract HasConstructorWithPubKey {
    constructor(uint256 pubkey) public {}
}

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

interface IShoppingList {
   function addPurchase(string name, uint amount) external;
   function deletePurchase(uint32 id) external;
   function buy(uint32 id, uint32 price) external;
   function getPurchase() external returns (Purchase[] tasks);
   function getSummaryPurchase() external returns (SummaryPurchase);
}
