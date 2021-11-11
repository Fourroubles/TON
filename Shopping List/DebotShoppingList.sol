pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DebotInter.sol";

contract DebotShoppingList is DebotInter {

    string _name;  
    

    function _menu() override internal {
        Menu.select(
            format(
                "You have {}/{}/{} (Need to buy/already bought/Total spent) shopping list ",
                    m_summaryPurchase.paidCount,
                    m_summaryPurchase.unPaidCount,
                    m_summaryPurchase.totalPrice
            ),
            "---",
            [
                MenuItem("Show Shopping list","",tvm.functionId(showShoppingList)),
                MenuItem("Add Purchases","",tvm.functionId(addPurchase)),
                MenuItem("Delete Purchases","",tvm.functionId(deletePurchases))
            ]
        );
    }

    function addPurchase() public { 
        Terminal.input(tvm.functionId(addPurchase_), "Item name: ", false);
    }

    function addPurchase_(string value) public {
        _name = value;
        Terminal.input(tvm.functionId(createPurchase), "Amount: ", false);
    }


    function createPurchase(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).addPurchase {
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(_name, uint32(num));
    }

    
}