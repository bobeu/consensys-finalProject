// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/utils/EnumerableMap.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/introspection/IERC1820Registry.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/token/ERC777/IERC777Recipient.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/token/ERC777/ERC777.sol";

contract GRT is ERC777 {
    constructor (address[] memory owner, string memory _name, string memory _symbol) ERC777(_name, _symbol, owner) public{
        _mint(owner[1], 50000000000000000000000000, bytes(""), bytes(""));
    }
}

// Online MarketPlace running on the blockchain
abstract contract GMart is IERC777Recipient{
    
    // Implementing an ERC777 token - enabling more token information
    
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    
    IERC777 token;
    
    address private owner;
    uint totalItem = 0;
    uint8 defaultId = 10;
    uint8 defaultId_storeOwner = 0;
    uint public totalStorefronts = 0;
    
    enum ItemStatus{Unavailable, Available}
    ItemStatus available = ItemStatus(1);
    ItemStatus unavailable = ItemStatus(0);
    
    
    struct Admins {
        address addr;
        bytes id;
    }
    
    struct StoreOwners{
        address addr;
        bytes id;
    }
    
    // Store details for adding a store to the storefront.
    struct Storefront {
        address payable storeOwner; // storeowner's public key
        string name;
        bytes storeref;
        uint dateCreated;
        bool active;
        uint storecount;
        uint itemCount;
    }
    
    struct Item {
        string name;
        uint price;
        uint quantity;
        address payable sellerAddress;
        bytes itemRef;
        ItemStatus status;
        bytes description;
        uint itemCountId;
    }

    struct Shoppers {
        mapping(address => Shoppers[]) shoppers;
    }
    
    Admins[] public adminList;
    StoreOwners[] public storeOwnerslist;
    Storefront[] storesList;
    Item[] public allItem;

    event ApprovedStoreOwner(address indexed _addr, bytes _ref);
    event NewAdmin(address indexed _addr, bytes _ref);
    event NewStoreFront(address indexed _newstore, bytes indexed _storeId, string _name);
    event UnregisteredStore(address indexed _storeOwnerAddress);
    event NewItem(address indexed _addr, string indexed _itemName, bytes _itemRef);
    event PriceChange(bytes indexed _referenceId, uint256 _newSetPrice);
    event Withdrawal(address indexed _from, address indexed _to, uint _amount);
    event RemovedItem(address indexed _msgsender, bytes _refId);
    event ReceivedEther(address, uint);
    

    mapping(address => bool) isAdmin;
    mapping(address => Admins) adminMap;
    mapping(address => bool) adminApprovalToAdd;
    mapping(address => bool) public isStoreOwnerApproved;
    mapping(address => StoreOwners) storeOwnerMap;
    mapping(address => bool) public storeOwnerApprovalToAddItem;//marked
    mapping(address => mapping(bytes => bool)) public ifStorefAvailable;
    mapping(address => bytes) public storef;
    mapping(address => mapping(bytes => Storefront[])) storeMap; //List of storefronts
    mapping(bytes => Storefront) storeHashMap;
    mapping(address => mapping(bytes => Item)) public itemMap;
    mapping(address => mapping(uint => Item)) itemcount;
    mapping(bytes => Item) public itemRefMap;
    mapping(address => mapping(bytes => bool)) public ownerShip;
    mapping(address => mapping(bytes => bytes)) itemHashMap;
    mapping(bytes => bool) itemExist;
    mapping(address => uint256) public balance;
    // mapping(address => mapping(bytes => bool)) item
    
    
    
    
    
    
    // mapping(address => StoreOwners) storeowners;
    
    
    
    
    
    EnumerableMap.UintToAddressMap private store_list;
    
    
    // mapping(address => EnergyStream[]) public buyItem;
    
    // mapping(bytes => StreamRef[]) public bids;
    // mapping(bytes => uint) public bids_acquired; // bytes is concatenation of seller - buyer - id offer - id ask
    
    // mapping(bytes => bytes) public accepted;
    // mapping(bytes => bool) public done;
    
    // Market currentMarket;
    
    // Initialized at deployment time.
    constructor (address _token, address _owner) public {
        token = IERC777(_token);
        owner = _owner;
        _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Request failed; Not an owner");
        _;
    }
    
    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "Not Authorized address");
        require(adminApprovalToAdd[msg.sender] == true, "Not Authorized");
        _;
    }
    
    modifier approvedStoreOwner() {
        require(isStoreOwnerApproved[msg.sender] == true, "Address not authorized");
        require(storeOwnerApprovalToAddItem[msg.sender] == true, "Unauthorized to add Item to store");
        _;
    }
    
    modifier checkItemExist(bytes memory _itemRef) {
        require(itemExist[_itemRef] == true, "Item does not exist");
        _;
    }
    
    function addAdmin(address _addr, bool _approval) public onlyOwner returns(bool successful){
        require(adminList.length <= 3, "Max admin list reached");
        require(_addr != address(0), "Invalid address");
        Admins memory _adminStruct = adminMap[_addr];
        uint8 tempAdminId = defaultId += 1;
        _adminStruct.addr = _addr;
        _adminStruct.id = abi.encode(_addr, tempAdminId);
        adminList.push(_adminStruct);
        if(_approval == true){
            adminApprovalToAdd[_addr] = _approval;
        }else if(_approval == false){
            adminApprovalToAdd[_addr] = _approval;
        }
        isAdmin[msg.sender] = true;
        emit NewAdmin(_addr, _adminStruct.id);
        return successful;
    }
    
    function approve_StoreOwner(address payable _addr, bool _approval) public onlyAdmin returns(bool successful) {
        require(_addr != address(0), "Invalid address");
        StoreOwners memory _ownerStruct = storeOwnerMap[_addr];
        uint8 tempId = defaultId_storeOwner += 1;
        _ownerStruct.addr = _addr;
        _ownerStruct.id = abi.encode(_addr, tempId);
        storeOwnerslist.push(_ownerStruct);
        if(_approval == true){
            storeOwnerApprovalToAddItem[_addr] = _approval;
        }else if(_approval == false){
            storeOwnerApprovalToAddItem[_addr] = _approval;
        }
        isStoreOwnerApproved[_addr] = true;
        emit ApprovedStoreOwner(_addr, _ownerStruct.id);
        return successful;
    }
    
    function changeAdminApproval(address _addr, bool _approval) public onlyOwner returns(bool){
        require(isAdmin[_addr] == true, "Not already added");
        if(_approval == true){
            adminApprovalToAdd[_addr] == _approval;
        }else if(_approval == false){
            adminApprovalToAdd[_addr] = _approval;
        }
        return true;
    }
    
    function changeStoreOwnerApproval(address _addr, bool _approval) public onlyAdmin returns(bool){
        require(isStoreOwnerApproved[_addr] == true, "Not already added");
        if(_approval == true){
            storeOwnerApprovalToAddItem[_addr] == _approval;
        }else if(_approval == false){
            storeOwnerApprovalToAddItem[_addr] = _approval;
        }
        return true;
    }

    /**
    * StoreOwners Registers a new storefront. 
    * currently a participant self-adding strorefront
    * param: _storeName: Name of the store.
    * param: _itemName: Name of an item.
    * param: _description: Detail of an item.
    * param: _price: unit price of an item.
    * param: _storeref: A unique reference Id to the store.
    * param: _quantity: Unit of item to add.
    */
    function addStorefront(
         string memory _storeName,
         string memory _itemName,
         bytes memory _description,
         uint _price,
         bytes memory _storeref,
         uint _quantity
         ) public approvedStoreOwner returns(bool success) {
         Storefront memory _newStoreFront;
         Item memory _newItem;
         bytes memory _storeRef = abi.encode(msg.sender, _storeName);
         require(ifStorefAvailable[msg.sender][_storeref] == false, "Store already exist" );
         require(storeMap[msg.sender][_storeref].length < 3, "Address can only create two storefront");
         _newStoreFront.dateCreated = block.timestamp - 15;
         _newStoreFront.name = _storeName;
         _newStoreFront.storeOwner = msg.sender;
         _newStoreFront.storeref = _storeref;
         _newStoreFront.active = true;
         if(_newStoreFront.itemCount == 0){
             _newItem = addItemToStore(_itemName, _description, _price, _storeref, _quantity);
             _newStoreFront.storecount += 1;
         }
        //  require(_newStoreFront.shelve.length > 0, "Shelve cannot be empty");
         storeMap[msg.sender][_storeRef].push(_newStoreFront);
         ifStorefAvailable[msg.sender][_storeref] = true;
         storef[msg.sender] = _storeRef;
         storeHashMap[_storeRef] = _newStoreFront;
         emit NewStoreFront(msg.sender, _storeref, _itemName);
         return success;
        
     }
     
     function getStoreDetail(bytes memory _ref) public view approvedStoreOwner returns(string memory, uint, address, bytes memory, bool, uint) {
         require(ifStorefAvailable[msg.sender][_ref] == true, "Store does not exist" );
         Storefront memory _storeToGet = storeHashMap[_ref];
         return(
             _storeToGet.name,
             _storeToGet.dateCreated,
             _storeToGet.storeOwner,
             _storeToGet.storeref,
             _storeToGet.active,
             _storeToGet.storecount
            );
        
     }
     
          /**
     * StoreOwners Registers a new item to shelve. 
     * param: _itemName: Name of an item.
     * param: _description: Detail of an item.
     * param: _price: unit price of an item.
     * param: _storeref: A unique reference Id to the store.
     * param: _quantity: Unit of item to add.
     */
     
    function addItemToStore(
        string memory _itemName,
        bytes memory _description,
        uint _price,
        bytes memory _storeRef,
        uint _qnty
        )public 
        approvedStoreOwner 
        returns(Item memory _newItem)
        {
            require(_price > 0, "Price cannot be empty");
            _newItem.name = _itemName;
            _newItem.price = _price;
            _newItem.quantity = _qnty;
            _newItem.itemCountId += 1;
            bytes memory _itemref = abi.encode(msg.sender, _newItem.itemCountId, _itemName, _price, _description);
            _newItem.sellerAddress = msg.sender;
            itemcount[msg.sender][_newItem.itemCountId] = _newItem;
            // _newStoreFront.shelve[_itemref](_newItem);
            ownerShip[msg.sender][_itemref] = true;
            _newItem.status = available;
            allItem.push(_newItem);
            itemMap[msg.sender][_itemref] = (_newItem);
            itemRefMap[_itemref] = _newItem;
            itemHashMap[msg.sender][_storeRef] = _itemref;
            itemExist[_itemref] = true;
            // uint newItemIndex = EnumerableMap.length(allItem);
            // EnumerableMap.set(allItem, newItemIndex, msg.sender);
            emit NewItem(msg.sender, _itemName, _itemref);
            return _newItem;
     }
     
     function removeAnItem(bytes memory _itemRef) public approvedStoreOwner checkItemExist(_itemRef) {
         delete itemMap[msg.sender][_itemRef];
         emit RemovedItem(msg.sender, _itemRef);
     }
      function removeAStore(bytes memory _ref) public approvedStoreOwner {
          delete storeMap[msg.sender][_ref];
      }

     function adjustPrice(uint _newPrice, bytes calldata _itemRef) external approvedStoreOwner checkItemExist(_itemRef) {
         require(_newPrice > 0, "Price cannot be zero");
         Item memory currentItem = itemMap[msg.sender][_itemRef];
         uint _oldPrice = currentItem.price;
         _oldPrice = _newPrice;
         emit PriceChange(_itemRef, _newPrice);
     }
     
    function buyItem(
        bytes memory _itemRef,
        uint _qnty
        )public payable checkItemExist(_itemRef) returns(bool success) 
        {
            Item memory _itemToBuy = itemRefMap[_itemRef];
            uint buyUnitPrice = _itemToBuy.price;
            address _sellerAddress = _itemToBuy.sellerAddress;
            require(_qnty > 0, "Invalid quantity");
            require(balance[msg.sender] >= buyUnitPrice, "Insufficeient balance");
            require(_itemToBuy.status == available, "Item Unavailable");
            require(_qnty <= _itemToBuy.quantity, "Cannot exceed seller's preset amount.");
            uint amountToPay = _qnty * buyUnitPrice;
            balance[msg.sender] -= amountToPay;
            balance[_sellerAddress] += amountToPay;
            // itemMap[_itemRef].status = _available + 1;
            ownerShip[_sellerAddress][_itemRef] = false;
            ownerShip[msg.sender][_itemRef] = true;
            uint prevQuanty = _itemToBuy.quantity;
            prevQuanty -= _qnty;
            if(prevQuanty == 0){
                delete _itemToBuy;
                _itemToBuy.status == unavailable;
                return success;
            }else if(prevQuanty > 0){
                _itemToBuy.quantity = prevQuanty;
            }
     }
     
    function withdrawBalanceStoreOwner(address payable _addr, uint _amount) external payable approvedStoreOwner returns(bool success) {
         require(balance[msg.sender] >= _amount, "Insufficeient balance");
         balance[msg.sender] -= _amount;
         _addr.transfer(_amount);
         emit Withdrawal(msg.sender, _addr, _amount);
         return success;
     }
    
    function deleteAdmin(address _addr) public onlyOwner returns(bool success) {
        require(isAdmin[_addr] == true, "Not an admin");
        return isAdmin[_addr] = false;
    }
    
    /**
     * @dev UnRegisters a store from the Storefront 
     * currently only an admin is able to remove store
     */
    function unregisterStore(address _addr, bytes memory _ref) public onlyAdmin returns(bool success) {
        require(isStoreOwnerApproved[_addr] == true, "Not a store owner already");
        require(ifStorefAvailable[_addr][_ref] == true, "Canoot find any match");
        delete storeMap[_addr][_ref];
        emit UnregisteredStore(_addr);
        return success;
    }
    
    //@dev Withdraw funds
    function withdraw(uint _amount) onlyOwner public payable{
        msg.sender.transfer(_amount);
    }
    
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
    
}    