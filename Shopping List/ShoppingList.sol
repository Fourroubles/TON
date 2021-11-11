pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "DataAndInter.sol";

contract ShoppingList is IShoppingList {

    mapping(uint32 => Purchase) m_purchase;
    uint256 m_ownerPubkey;
    uint32 m_count;

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function getPurchase() public override returns (Purchase[] purchases) {
        Purchase tmp;

        for((uint32 id, Purchase purchase) : m_purchase) {
            tmp.name = purchase.name;
            tmp.amount = purchase.amount;
            tmp.timeCreate = purchase.timeCreate;
            tmp.isBuy = purchase.isBuy;
            tmp.price = purchase.price;
            purchases.push(Purchase(id, tmp.name, tmp.amount, tmp.timeCreate, tmp.isBuy, tmp.price));
        }
    }

    function addPurchase(string name, uint amount) public override onlyOwner {
        tvm.accept();
        m_count++;
        m_purchase[m_count] = Purchase(m_count, name, amount, now, false, 0);
    }

    function deletePurchase(uint32 id) public override onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }

    function buy(uint32 id, uint32 price) public override onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        m_purchase[id].isBuy = true;
        m_purchase[id].price = price;
    }

    function getSummaryPurchase() public override returns (SummaryPurchase summaryPurchase) {
        uint32 paidCount;
        uint32 unPaidCount;
        uint32 totalPrice;

        for((, Purchase purchase) : m_purchase) {
            if  (purchase.isBuy) {
                unPaidCount++;
                totalPrice += purchase.price;
            } 
            else {
                paidCount++;
            }
        }

        summaryPurchase = SummaryPurchase(paidCount, unPaidCount, totalPrice);
    }
}