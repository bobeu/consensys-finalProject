// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
    
}

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public itemcount = 0;
    
    // An array with all balances 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
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
    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
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
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
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
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
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
contract GMart is TokenERC20{
    
    address public owner;
    uint totalItem = 0;
    // uint8 defaultId = 10;
    uint8 defaultId_storeOwner = 0;
    uint shoppers_count = 0;
    uint public adminCount = 0;
    uint256 public storeOwnersCount = 0;
    uint256 public storeCount = 0;

    event ApprovedStoreOwner(address indexed _addr, uint256 _userId);
    event NewAdmin(address indexed _addr);
    event NewStoreFront(address indexed _msgsender, bytes _storeRef);
    event UnregisteredStore(address indexed _storeOwnerAddress, uint256 _storeNumber);
    event DeletedStore(address indexed _msgsender, uint256 _storeNumber);
    event NewItem(address indexed _addr, string _itemName, bytes _itemRef);
    event PriceChange(bytes _referenceId, uint256 _newSetPrice);
    event Withdrawal(address indexed _from, address indexed _to, uint _amount);
    event RemovedItem(address indexed _msgsender, bytes _refId);
    event ReceivedEther(address, uint);
    event FrozenFunds(address target, bool frozen);
     // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
    // An array with all balances 
    mapping(address => mapping(uint => bool)) public  isAdmin;
    mapping(address => bool) public adminApprovalToAdd;
    mapping(address => mapping(uint => bool)) public isStoreOwnerApproved;
    mapping(address => bool) public storeOwnerApprovalToAddItem;//marked
    mapping(address => mapping(uint256 => bytes)) public storefrontRef;
    mapping(bytes => mapping(uint => bytes)) public storefrontRefItemMap;
    mapping(bytes => bool) public storeExist;
    mapping(uint => bytes) public itemsList;
    mapping(address => bool) public ownerShip;
    mapping(bytes => bool) public availableItems;
    mapping(address => uint256) public balanceof;
    mapping(address => uint256) public shoppers;
    mapping (address => bool) public frozenAccounts;
    
    // Initialized at deployment time.
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        // uint256 initialSupply,
        // string memory tokenName,
        // string memory tokenSymbol
    ) TokenERC20(500000, "gmarttoken", "GMT") public {
        owner = msg.sender;
    }

    //Only sender with owner Authorization is permiitted
    modifier onlyOwner() {
        require(msg.sender == owner, "Request failed; Not an owner");
        _;
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
        require(storeOwnerApprovalToAddItem[msg.sender] == true, "Unauthorized to add Item to store");
        _;
    }
    //Check if an item exist in a particular storefront
    modifier checkItemExist(bytes memory _itemRef) {
        require(availableItems[_itemRef] == true, "Item does not exist");
        _;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
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

    /*
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     * @param _from Address of sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferToken(address _to, uint _value) internal {
        require(!frozenAccounts[_to]);                       // Check if recipient is frozen
        _transfer(msg.sender, _to, _value);
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
    function transferTokenFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccounts[_from]);        // Check if sender is frozen
        require(!frozenAccounts[_to]);          // Check if recipient is frozen
        transferFrom(_from, _to, _value);
        return true;
    }
    
    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approveSpender(address _spender, uint256 _value) public {
        approve(_spender, _value);
        emit Approval(msg.sender, _spender, _value);
    }
    
    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveandCall(address _spender, uint256 _value, bytes memory _extraData) public {
        approveAndCall(_spender, _value, _extraData);
    }
    
    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burnToken(uint256 _value) public {
        burn(_value);
    }
    
       /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnTokenFrom(address _from, uint256 _value) public {
        burnFrom(_from, _value);
        
    }
    
    /**
     * @dev adds an adminList
     * function is called only by the authorized owner address
     */
    function addAdmin(address _addr) public onlyOwner returns(bool){
        require(adminCount <= 3, "Max admin reached --> [3]");
        require(_addr != address(0), "Invalid address");
        uint id = adminCount += 1;
        isAdmin[_addr][id] = true;
        emit NewAdmin(_addr);
        return true;
    }

    function checkIsAdmin(address _addr, uint _id) public view returns(bool) {
        return (isAdmin[_addr][_id]);
    }

    function checkIfAdmincanAdd(address _addr) public view returns(bool) {
        return(adminApprovalToAdd[_addr]);
    }

    function checkStoreOwnerApproved(address _addr, uint256 _id) public view returns(bool, bool) {
        return (isStoreOwnerApproved[_addr][_id], storeOwnerApprovalToAddItem[_addr]);
    }
    
    function approve_StoreOwner(address _addr, uint _id) public onlyAdmin(_id) returns(bool successful) {
        require(_addr != address(0), "Invalid address");
        // StoreOwners memory _ownerStruct = storeOwnerMap[_addr];
        uint256 id = storeOwnersCount += 1;
        isStoreOwnerApproved[_addr][_id] = true;
        emit ApprovedStoreOwner(_addr, id);
        return successful;
    }
    
    function changeAdminApproval(address _addr, bool _approval, uint _id) public onlyOwner returns(bool) {
        require(isAdmin[_addr][_id] == true, "Not already added");
        adminApprovalToAdd[_addr] = _approval;
        return _approval;
    }
    
    function changeStoreOwnerApproval(
        address _addr,
        bool _approval,
        uint _adminId,
        uint256 _storeOwnerId
        ) public onlyAdmin(_adminId) returns(bool){
        require(isStoreOwnerApproved[_addr][_storeOwnerId] == true, "Not already added");
        storeOwnerApprovalToAddItem[_addr] = _approval;
        return _approval;
    }

    /**
    * StoreOwners Registers a new storefront. 
    * currently a participant self-adding strorefront
    * param: _storeName: Name of the store.
    */
    function addStorefront(
         string memory _storeName,
         uint256 _userId
         ) public approvedStoreOwner(_userId) returns(bool) {
         uint256 _storeNumber = storeCount += 1;
         uint256 dateCreated = now;
         bool _active = true;
         bytes memory _storefrontRef = abi.encode(msg.sender, _storeName, _storeNumber, dateCreated, _active);
         require(storeExist[_storefrontRef] == false, "Store already exist" );
         storefrontRef[msg.sender][_storeNumber] = _storefrontRef;
         storeExist[_storefrontRef] == true;
         emit NewStoreFront(msg.sender, _storefrontRef);
         return true;
        
     }
     
     function getStoreDetail(
         bytes calldata _storeRef,
         uint256 _userId
         ) external view approvedStoreOwner(_userId) returns(
             address,
             string memory,
             uint,
             uint,
             bool
             ) {
                 require(storeExist[_storeRef] == true, "Store does not exist" );
                 return(abi.decode(_storeRef, (address, string, uint, uint, bool)));
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
        bytes memory _storeRef,
        uint _qnty,
        uint256 _userId
        )public 
        approvedStoreOwner(_userId)
        returns(bool)
        {
            require(_price > 0, "Price cannot be zero");
            // Item memory _newItem;
            string memory name = _itemName;
            uint256 price = _price;
            uint256 quantity = _qnty;
            uint256 itemNumber = itemcount += 1;
            string memory description = _description;
            bytes memory _itemref = abi.encode(
                msg.sender,
                name,
                price,
                quantity,
                itemNumber,
                description
                );
                storefrontRefItemMap[_storeRef][itemNumber] = _itemref;
                ownerShip[msg.sender] = true;
                availableItems[_itemref] = true;
                itemsList[itemNumber] = _itemref;
                emit NewItem(msg.sender, _itemName, _itemref);
                return true;
            
        }
     
     function removeAnItem(bytes memory _itemRef, uint256 _userId, bytes memory _storeRef, uint _itemNumber) public approvedStoreOwner(_userId) checkItemExist(_itemRef) {
        //  require(availableItems[_itemRef] == true, "Item does not exist");
         delete storefrontRefItemMap[_storeRef][_itemNumber];
         emit RemovedItem(msg.sender, _itemRef);
     }
      function removeAStore(uint256 _userId, uint256 _storeNumber) public approvedStoreOwner(_userId) {
          delete storefrontRef[msg.sender][_storeNumber];
          emit DeletedStore(msg.sender, _storeNumber);
      }

    function buyItem(
        bytes calldata ref,
        uint _qnty,
        uint _itemNumber,
        uint _offer
        )external payable checkItemExist(ref) returns(bool) 
        {
            bytes memory _itemToBuy = itemsList[_itemNumber];
            (
                address sellerAddress,
                string memory name,
                uint price,
                uint quantity,
                uint itemNumber,
                bytes32 description) = abi.decode(_itemToBuy, (address, string, uint, uint, uint, bytes32));
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
                    delete itemsList[_itemNumber];
                    return true;
                }else if(quantity > 0){
                    itemsList[_itemNumber] = abi.encode(sellerAddress, name, price, quantity, itemNumber, description);
                }
                shoppers[msg.sender] = shoppers_count += 1;
                return true;
     }
     
    function withdrawBalanceStoreOwner(address payable _addr, uint _amount, uint256 _userId) external payable approvedStoreOwner(_userId) returns(bool success) {
         require(balanceOf[msg.sender] >= _amount, "Insufficeient balance");
         balanceOf[msg.sender] -= _amount;
         balanceOf[_addr] += _amount;
         emit Withdrawal(msg.sender, _addr, _amount);
         return success;
     }
    
    function disableAdmin(address _addr, uint8 _id) public onlyOwner returns(bool success) {
        require(isAdmin[_addr][_id] == true, "Not an admin already");
        isAdmin[_addr][_id] = false;
        if(isAdmin[_addr][_id] == false) return true;
    }
    
    /**
     * @dev UnRegisters a store from the Storefront 
     * currently only an admin is able to remove store
     */
    function unregisterStore(address _addr, uint _id, uint256 _userId, uint256 _storeNumber) public onlyAdmin(_id) returns(bool) {
        require(isStoreOwnerApproved[_addr][_userId] == true, "Address not authorized");
        storefrontRef[_addr][_storeNumber] = abi.encode(0, 0, 0, 0, 0);
        storeOwnerApprovalToAddItem[_addr] == false;
        emit UnregisteredStore(_addr, _storeNumber);
        return true;
    }
    
    //@dev Withdraw funds
    function withdraw(uint _amount) onlyOwner public payable{
        msg.sender.transfer(_amount);
    }
    
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
    
}    