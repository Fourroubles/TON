pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DebotInter.sol";

contract DebotAtShop is DebotInter {
   

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Need to buy/already bought/Total spent) shopping list",
                    m_summaryPurchase.paidCount,
                    m_summaryPurchase.unPaidCount,
                    m_summaryPurchase.totalPrice
            ),
            sep,
            [
                MenuItem("Make a purchase","",tvm.functionId(makePurchase)),
                MenuItem("Show Shopping list","",tvm.functionId(showShoppingList)),
                MenuItem("Delete Purchases","",tvm.functionId(deletePurchases))
            ]
        );
    }

    function makePurchase(uint32 index) public {
        index = index;
        if (m_summaryPurchase.paidCount > 0) {
            Terminal.input(tvm.functionId(makePurchase_), "Enter  number of things:", false);
        } 
        else {
            Terminal.print(0, "Sorry, you don't have things to pay");
            _menu();
        } 
    }

    function makePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_PurchaseId = uint32(num);
        Terminal.input(tvm.functionId(buy), "Enter price:", false);
    }

    function buy(string value) public {
        optional(uint256) pubkey = 0;
        (uint256 num,) = stoi(value);
        IShoppingList(m_address).buy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_PurchaseId, uint32(num));
    }  
}