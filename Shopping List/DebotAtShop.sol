pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DebotListInitialization.sol";

contract DebotAtShop is DebotListInitialization {

    uint32 amount;
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping List DeBot";
        version = "0.0.1";
        publisher = "";
        key = "Shopping list manager";
        author = "@Fourroubles";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Shop DeBot .";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }    

    function menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Need to buy/already bought/Total spent) shopping list",
                    m_summaryPurchase.paidCount,
                    m_summaryPurchase.isntPaidCount,
                    m_summaryPurchase.totalPrice
            ),
            sep,
            [
                MenuItem("Make a purchase","",tvm.functionId(makePurchase)),
                MenuItem("Show Shopping list","",tvm.functionId(showShoppinglist)),
                MenuItem("Delete Purchases","",tvm.functionId(deletePurchases))
            ]
        );
    }

    function makePurchase(uint32 index) public {
        index = index;
        if (m_summaryPurchase.isntPaidCount > 0) {
            Terminal.input(tvm.functionId(makePurchase_), "Enter  number of things:", false);
        } 
        else {
            Terminal.print(0, "Sorry, you don't have things to pay");
            menu();
        } 
    }

    function makePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_PurchaseId = uint32(num);
        Terminal.input(tvm.functionId(makePurchase__), "Enter amount:", false);
    }

    function makePurchase__(string value) public {
        (uint256 num,) = stoi(value);
        amount = uint32(num);
        AddressInput.get(tvm.functionId(pay),"Select a wallet for payment");
    }

    function pay(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IMsig(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(makePurchase___),
            onErrorId: tvm.functionId(onError)  
        }(m_address, amount, false, 3, empty);
    }
    
    function makePurchase___() public {     
        
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).buy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_PurchaseId, amount);        
    }    

    function showShoppinglist(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShoppingList(m_address).getPurchase {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showTasks_),
            onErrorId: 0
        }();
    }

    function showTasks_(Purchase[] _purchase) public {
        uint32 i;
        if (_purchase.length > 0 ) {
            Terminal.print(0, "Your Shopping list:");
            for (i = 0; i < _purchase.length; i++) {
                Purchase purchase = _purchase[i];
                string completed;
                if (purchase.isBuy) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"  {} {} at {}", purchase.id, completed, purchase.name, purchase.amount, purchase.timeCreate, purchase.price));
            }
        } 
        else {
            Terminal.print(0, "Your Shopping list is empty");
        }
        menu();
    }

    function deletePurchases(uint32 index) public {
        index = index;
        if (m_summaryPurchase.paidCount + m_summaryPurchase.isntPaidCount > 0) {
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