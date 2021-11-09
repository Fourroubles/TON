pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../base/Debot.sol";
import "../base/Terminal.sol";
import "../base/Menu.sol";
import "../base/AddressInput.sol";
import "../base/ConfirmInput.sol";
import "../base/Upgradable.sol";
import "../base/Sdk.sol";
import "DataAndInter.sol";

abstract contract DebotListInitialization is Debot {
    bytes m_icon;

    TvmCell m_shoppingListCode; // TODO contract code
    address m_address;  // TODO contract address
    SummaryPurchase m_summaryPurchase;        // Statistics of incompleted and completed tasks
    uint32 m_PurchaseId;    // Task id for update. I didn't find a way to make this var local
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial TODO contract balance

    function setTodoCode(TvmCell code) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListCode = code;
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key", false);
    }

    function onSuccess() public view {
        _getSummaryPurchase(tvm.functionId(setSummaryPurchase));
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x" + value);

        if(status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Shopping list ...");
            TvmCell deployState = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Info: your ShoppingList contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
        }
        else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getSummaryPurchase(tvm.functionId(setSummaryPurchase));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your ShoppingList contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;

        IMsig(m_msigAddress).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }

    function waitBeforeDeploy() public {
        Sdk.getAccountType(tvm.functionId(checkDownloadedContract), m_address);
    }

    function checkDownloadedContract(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } 
        else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
        TvmCell image = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubKey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        sdkError;
        exitCode;
        deploy();
    }

    function _getSummaryPurchase(uint32 answerId) private view {
        optional(uint256) none;
        IShoppingList(m_address).getSummaryPurchase {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function setSummaryPurchase(SummaryPurchase summaryPurchase) public {
        m_summaryPurchase = summaryPurchase;
        menu();
    }

    function menu() virtual internal;
}


