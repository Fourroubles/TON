pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DebotListInitialization.sol";

contract DebotShoppingList is DebotListInitialization {

    function menu() private override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Need to buy/already bought/Total spent) shopping list",
                    m_summaryPurchase.paidCount,
                    m_summaryPurchase.isntPaidCount,
                    m_summaryPurchase.price
            ),
            sep,
            [
                MenuItem("Add Purchases","",tvm.functionId(addPurchase)),
                //MenuItem("Show task list","",tvm.functionId(showTasks)),
                //MenuItem("Update task status","",tvm.functionId(updateTask)),
                //MenuItem("Delete task","",tvm.functionId(deleteTask))
            ]
        );
    }

    function addPurchase(uint32 index) piblic {
        index = index; 
        Terminal.input(tvm.functionId(addNamePurchase), "Item name: ", false);
    }

    function addNamePurchase(string name) piblic {
        index = index; 
        Terminal.input(tvm.functionId(addPurchaseName), "Count: ", false);
    }

    function addCountPurchases(uint index) piblic {
        index = index; 
        Terminal.input(tvm.functionId(addPurchaseName), "Count: ", false);
    }

    function createTask_(string value) public view {
        optional(uint256) pubkey = 0;
        ITodo(m_address).createTask{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(value);
    }
}