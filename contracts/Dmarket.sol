// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract TokenERC20 {
    // Public variables of the token
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // An array with all balances 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccounts;
    
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Alerts client when an account is frozen
    event FrozenFunds(address target, bool frozen);
    // Publishes event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    //Only sender with owner Authorization is permiitted
    modifier onlyOwner() {
        require(msg.sender == owner, "Request failed; Not an owner");
        _;
    }

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    // @notice Create `mintedAmount` tokens and send it to `target`
    // @param target Address to receive the tokens
    // @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }
    
    // @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    // @param target Address to be frozen
    // @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccounts[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccounts[_to]);
        _transfer(msg.sender, _to, _value);
        return true;
    }
    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); // Check allowance amount
        require(!frozenAccounts[_from]);        // Check if sender is frozen
        require(!frozenAccounts[_to]);          // Check if recipient is frozen
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender`: to spend no more than `_value` tokens in your behalf
     *
     * @param _spender: The address authorized to spend
     * @param _value: the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender: The address authorized to spend
     * @param _value: the max amount they can spend
     * @param _extraData :some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
    
}

// Online MarketPlace running on the blockchain
contract Dmarket is TokenERC20{
    
    uint totalItem = 0; //Total items added in contract lifetime
    uint8 defaultId_storeOwner = 0; //preset id storeOwners
    uint public adminCount = 0; //Numbers of Admins
    uint256 public storeOwnersCount = 0; //All StoreOwners
    uint256 public storeCount = 0; //Total number of stores
    uint256 public itemcount = 0; //Total number of items
    uint256 public shoppersCount; //All users
    uint public etherBalance; //Balances other than custom token
    uint public minimumDonation = 0.1 ether;

    // Emits event when a storeOwner is approved
    event ApprovedStoreOwner(address indexed _addr, uint256 _userId);
    // Notifies the client when a new admin is added
    event NewAdmin(address indexed _addr);
    // Emits notification when a new store is added
    event NewStoreFront(address indexed _msgsender, string _storeName, uint _storeNum);
    // Emits event when a st
    event UnregisteredStore(address indexed _storeOwnerAddress, uint256 _storeNumber);
    event DeletedStore(address indexed _msgsender, uint256 _storeNumber);
    event NewItem(address indexed _addr, string _itemName, bytes _itemRef);
    event PriceChange(bytes _referenceId, uint256 _newSetPrice);
    event Withdrawal(address indexed _from, address indexed _to, uint _amount);
    event RemovedItem(address indexed _msgsender, string _itemName, uint _id);
    event ReceivedEther(address, uint);
    
     // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
       // List of admins --> fixed
    address[] public admins;

    mapping(address => mapping(uint => bool)) public  isAdmin; //Admins approval
    mapping(address => bool) public adminApprovalToAdd; //Admin approval to add storeOwner
    mapping(address => mapping(uint => bool)) public isStoreOwnerApproved; // Approvals for storeOwner
    mapping(address => mapping(uint256 => bytes)) public storefrontRef; //List of storefront refrences/IDs
    // References to store with Items
    mapping(address => mapping(string => mapping(string => mapping(uint => bytes)))) public storefrontRefItemMap;
    mapping(string => mapping(uint => bool)) public storeExist; //Check for storefront existence
    mapping(uint => bytes) public itemsList; //List of items
    mapping(address => bool) public ownerShip; //Ownership of items
    mapping(string => mapping(uint => address)) public storeOwners;//List of stores with owners
    mapping(uint => bool) public availableItems; //List of items available for sale
    mapping(uint => uint) public itemBalance; //Item balance count
    mapping(address => uint256) public shoppers; //All recognised Users for bounty purpose
    
    // Initialized at deployment time.
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() TokenERC20(500000, "gmarttoken", "GMT") public {
        owner = msg.sender;
    }

    //Only sender with admin role is permiitted
    modifier onlyAdmin(uint _id) {
        require(isAdmin[msg.sender][_id] == true, "Not Authorized address");
        require(adminApprovalToAdd[msg.sender] == true, "Not Authorized");
        _;
    }
    //Only approved store owner is allowed
    modifier approvedStoreOwner(uint256 _id) {
        require(isStoreOwnerApproved[msg.sender][_id] == true, "Address not authorized");
        _;
    }
    modifier onlyAdminOrStoreOwner(uint _id) {
        require(
            (
                adminApprovalToAdd[msg.sender] == true && isAdmin[msg.sender][_id] == true) || isStoreOwnerApproved[msg.sender][_id] == true,
            "Not Authorized address"
            ); _;
    }

    //Check if an item exist in a particular storefront
    modifier checkItemExist(string memory _item, uint _itemNumber) {
        require(availableItems[_itemNumber] == true, "Item does not exist");
        _;
    }
    
    // Changes ownership of this contract
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    /**
     * @dev adds an adminList
     * function is called only by the authorized owner address
     */
    function addAdmin(address _addr) public onlyOwner returns(bool){
        require(admins.length <= 3, "Max admin reached --> [3]");
        require(_addr != address(0), "Invalid address");
        uint id = adminCount + 1;
        for (uint k = 0 ; k < admins.length; k++) {
            require(isAdmin[_addr][k] == false);
        }
        isAdmin[_addr][id] = true;
        adminApprovalToAdd[_addr] = false;
        admins.push(_addr);
        adminCount += 1;
        emit NewAdmin(_addr);
        return isAdmin[_addr][id];
    }

    // 
    function checkIsAdmin(address _addr, uint _id) public view returns(bool) {
        return (isAdmin[_addr][_id]);
    }

    function checkIfAdmincanAdd(address _addr) public view returns(bool) {
        return(adminApprovalToAdd[_addr]);
    }

    function checkStoreOwnerApproved(address _addr, uint256 _id) public view returns(bool) {
        return isStoreOwnerApproved[_addr][_id];
    }
    
    function approve_StoreOwner(address _addr, uint _id) public onlyAdmin(_id) returns(bool) {
        require(_addr != address(0), "Invalid address");
        uint256 id = storeOwnersCount + 1;
        require(isStoreOwnerApproved[_addr][id] == false, "Already approved");
        isStoreOwnerApproved[_addr][id] = true;
        storeOwnersCount += 1;
        emit ApprovedStoreOwner(_addr, id);
        return true;
    }
    
    function changeAdminApproval(address _addr, bool _approval, uint _id) public onlyOwner returns(bool) {
        require(isAdmin[_addr][_id] == true, "Not already added");
        if(_approval == true){
            require(adminApprovalToAdd[_addr] == false, "Already approved");
            return adminApprovalToAdd[_addr] = _approval;
        } else if(_approval == false){
            require(adminApprovalToAdd[_addr] == true, "Not yet approved");
            return adminApprovalToAdd[_addr] = false;
        }
    }
    
    function changeStoreOwnerApproval(
        address _addr,
        bool _approval,
        uint _adminId,
        uint256 _storeOwnerId
        ) public onlyAdmin(_adminId) returns(bool){
        require(isStoreOwnerApproved[_addr][_storeOwnerId] == true, "Not already added");
        if(_approval == true && isStoreOwnerApproved[_addr][_storeOwnerId] == true){
            return false;
        }else if(isStoreOwnerApproved[_addr][_storeOwnerId] == true && _approval == false){
            isStoreOwnerApproved[_addr][_storeOwnerId] = false;
            return true;
        }
        
    }

    /**
    * StoreOwners Registers a new storefront. 
    * currently a participant self-adding strorefront
    * param: _storeName: Name of the store.
    */
    function addStorefront(
         string memory _storeName,
         uint256 _userId
         ) public approvedStoreOwner(_userId) returns(string memory, uint) {
         uint256 _storeNumber = storeCount += 1;
         uint256 dateCreated = now;
         bool _active = true;
         bytes memory _storefrontRef = abi.encode(msg.sender, _storeName, _storeNumber, dateCreated, _active);
         require(storeExist[_storeName][_storeNumber] == false, "Store already exist" );
         storefrontRef[msg.sender][_storeNumber] = _storefrontRef;
         storeExist[_storeName][_storeNumber] = true;
         storeOwners[_storeName][_storeNumber] = msg.sender;
         emit NewStoreFront(msg.sender, _storeName, _storeNumber);
         return (_storeName, _storeNumber);
        
     }

    function ifStoreExist(string memory _name, uint _storeNumber) public view returns(bool) {
        if(storeExist[_name][_storeNumber]){
            return true;
        }else{
            return false;
        }
     }
     
    function getStoreOwner(string memory _name, uint _id) public view returns(address) {
        require(storeExist[_name][_id] == true, "Store does not exist" );
        return(storeOwners[_name][_id]);
     }
     
          /**
     * StoreOwners Registers a new item to shelve. 
     * param: _itemName: Name of an item.
     * param: _description: Detail of an item.
     * param: _price: unit price of an item.
     * param: _storeref: A unique  Id to the store.
     * param: _quantity: Unit of ireferencetem to add.
     */
     
    function addItemToStore(
        string memory _itemName,
        string memory _description,
        uint _price,
        string memory _storeName,
        uint _qnty,
        uint256 _userId
        )public 
        approvedStoreOwner(_userId)
        returns(bool)
        {
            require(_price > 0, "Price cannot be zero");
            uint256 itemNumber = itemcount + 1;
            address _seller = msg.sender;
            bytes memory _itemref = abi.encode(
                _itemName,
                _price,
                _qnty,
                itemNumber,
                _description,
                _seller
                );
                storefrontRefItemMap[msg.sender][_storeName][_itemName][itemNumber] = _itemref;
                ownerShip[msg.sender] = true;
                availableItems[itemNumber] = true;
                itemsList[itemNumber] = _itemref;
                itemBalance[itemNumber] = _qnty;
                itemcount += 1;
                emit NewItem(msg.sender, _itemName, _itemref);
                return true;
            
        }
     
    function removeAnItem(
        string memory _storeName,
        uint256 _userId,
        string memory _itemName,
        uint _itemNumber
        )
        public
        approvedStoreOwner(_userId)
        checkItemExist(_itemName, _itemNumber)
        returns(bool){
        delete storefrontRefItemMap[msg.sender][_storeName][_itemName][_itemNumber];
        delete itemBalance[_itemNumber];
        availableItems[_itemNumber] = false;
        itemcount -= 1;
        emit RemovedItem(msg.sender, _itemName, _itemNumber);
        return true;
     }

    /**
     * @dev UnRegisters a store from the Storefront 
     * currently only an admin is able to remove store
     */
    function removeAStore(
        string memory _storeName,
        uint256 _userId,
        uint256 _storeNumber
        ) public onlyAdminOrStoreOwner(_userId) returns(bool) {
        delete storefrontRef[msg.sender][_storeNumber];
        delete storeOwners[_storeName][_storeNumber];
        storeExist[_storeName][_storeNumber] = false;
        storeCount -= 1;
        emit DeletedStore(msg.sender, _storeNumber);
        return true;
      }

    // Shopper buys an item
    function buyItem(
        string calldata _name,
        uint _qnty,
        uint _itemNumber
        )external payable checkItemExist(_name, _itemNumber) returns(bool) 
        {
            bytes memory _itemToBuy = itemsList[_itemNumber];
            uint256 _offer = msg.value;
            (
                string memory name,
                uint price,
                uint quantity,
                uint itemNumber,
                bytes32 description,
                address sellerAddress) = abi.decode(_itemToBuy, (string, uint, uint, uint, bytes32, address));
                require(_qnty > 0, "Invalid quantity");
                uint amountToPay = _qnty * _offer;
                require(amountToPay / _qnty == _offer, "Overflow spotted");
                require(balanceOf[msg.sender] >= amountToPay, "Insufficeient balance");
                require(_qnty <= quantity, "Cannot exceed seller's preset amount.");
                require(_offer >= amountToPay, "Amount cannot be less than total price");
                balanceOf[msg.sender] -= amountToPay;
                balanceOf[sellerAddress] += amountToPay;
                ownerShip[sellerAddress] = false;
                ownerShip[msg.sender] = true;
                quantity -= _qnty;
                if(quantity == 0){
                    availableItems[_itemNumber] = false;
                    delete itemsList[_itemNumber];
                    delete itemBalance[_itemNumber];
                    itemcount -= 1;
                    return true;
                }else if(quantity > 0){
                    itemsList[_itemNumber] = abi.encode(sellerAddress, name, price, quantity, itemNumber, description);
                    itemBalance[itemNumber] = quantity;
                }
                shoppers[msg.sender] = shoppersCount += 1;
                return true;
     }
     
    // Approved storeOwners with balances can withdraw from the individual account
    function withdrawBalanceStoreOwner(address payable _addr, uint _amount, uint256 _userId) external payable approvedStoreOwner(_userId) returns(bool success) {
         require(balanceOf[msg.sender] >= _amount, "Insufficeient balance");
         balanceOf[msg.sender] -= _amount;
         balanceOf[_addr] += _amount;
         emit Withdrawal(msg.sender, _addr, _amount);
         return success;
     }

    // Owner can disable an admin 
    function disableAdmin(address _addr, uint8 _id) public onlyOwner returns(bool) {
        require(isAdmin[_addr][_id] == true, "Not an admin already");
        isAdmin[_addr][_id] = false;
        adminCount -= 1;
        return isAdmin[_addr][_id];
    }
    
    //@dev Withdraws ether balance.
    function withdraw(uint _amount) public onlyOwner payable{
        require(_amount <= address(this).balance);
        msg.sender.transfer(_amount);
    }
    // Executes a fallback i.e when a non-existent function is called.
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }

    // Donate ether
    function sendEther() public payable returns(bool) {
        require(msg.value >= minimumDonation, "Thanks for donating but 0.1 ether is the minimum");
        balanceOf[msg.sender] -= msg.value;
        balanceOf[address(this)] += msg.value;
        return true;
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }
    
}    