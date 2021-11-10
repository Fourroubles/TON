pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DebotListInitialization.sol";

contract DebotShoppingList is DebotListInitialization {

    string _name;  
    

    function menu() override internal {
        Menu.select(
            format(
                "You have {}/{}/{} (Need to buy/already bought/Total spent) shopping list",
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

    function addPurchase(uint32 index) public {
        index = index; 
        Terminal.input(tvm.functionId(createPurchase), "Item name: ", false);
    }

    function addNamePurchase(string name) public {
        _name = name;
        Terminal.input(tvm.functionId(createPurchase), "Count: ", false);
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
            }(value, uint32(num));
    }

    function showShoppingList(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShoppingList(m_address).getPurchase {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showShoppingList_),
            onErrorId: 0
        }();
    }

    function showShoppingList_(Purchase[] purchase) public {
        if (purchase.length > 0 ) {
            Terminal.print(0, "Your Shopping list:");
            for (uint i = 0; i < purchase.length; i++) {
                string completed;
                if (purchase[i].isBuy) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {} {} {} {} {}", purchase[i].id, completed, purchase[i].name, purchase[i].amount, purchase[i].price, purchase[i].timeCreate));
            }
        } 
        else {
            Terminal.print(0, "Your Shopping list is empty");
        }

        menu();
    }

    function deletePurchases(uint32 index) public {
        index = index;
        if (m_summaryPurchase.paidCount + m_summaryPurchase.unPaidCount > 0) {
            Terminal.input(tvm.functionId(deletePurchases_), "Enter task number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no tasks to delete");
            menu();
        }
    }

    function deletePurchases_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).deletePurchase {
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
        }(uint32(num));
    }
}