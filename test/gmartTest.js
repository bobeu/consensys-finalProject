
/*
Testing for GMart contract - "./contract/GMart.sol"
*/
let GMart = artifacts.require("GMart");
let catchRevert = require("./exceptionsHelpers.js").catchRevert;
// const { getBalance } = require(“./getBalance”);

contract('GMart', accounts => {

    const [firstAccount, secondAccount] = accounts;
    const ETHER = 10**18;    
    /*
    Trying to test using global objects.
    */
    // async () => {await instance.addAdmin(accounts[1]);}
    // async () => {await instance.changeAdminApproval(secondAccount, true, 1);}

    // Set an Owner
    it("...sets an owner", async () => {
        const instance = await GMart.new();
        assert.equal(await instance.owner.call(), firstAccount, "Should set an owner.");
    });

    // Add an admin to the list
    it("...should add an admin to the admin List.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(accounts[1]);
        const result_1 = await instance.checkIsAdmin(accounts[1], 1);
        const result_2 = await instance.isAdmin.call(accounts[1], 1);
        assert.equal(result_1, true, "Should return true when an admin is added");
        assert.equal(result_2, true, "Should return true when an admin is added");
        assert.equal(await instance.adminCount.call(), 1, "Admin count should equal 1...");
    });

    // Remove/disable an admin from the list
    it("...should disable an admin.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(accounts[1]);
        await instance.addAdmin(accounts[3]);
        await instance.disableAdmin(accounts[1], 1);
        assert.equal(await instance.adminCount.call(), 1, "Admin count should equal 1...");
    });
    
    // Should fail if try to add the fourth admin
    it("...should not add more than 3 admins.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(accounts[1]);
        await instance.addAdmin(accounts[2]);
        await instance.addAdmin(accounts[3]);
        await instance.addAdmin(accounts[4]);
        const admincount = await instance.adminCount.call();
        assert.equal(admincount, 4, "Admin count cannot be greater than 3...");
    });

    // If an admin is added initially, should not be able to add storeOwner
    // It should return false if the checkIdAdmincanAdd() is called
    it("...should return false if admin is added.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        const expected = await instance.checkIfAdmincanAdd(secondAccount);
        assert.equal(expected, false, 'Should return true ');
    });

    // Admin should change admin approval to add storeOwner to true
    it("...should change an admin approval to add.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        const expected = await instance.checkIfAdmincanAdd(secondAccount);
        assert.equal(expected, true, "The approval should change to true.");
    });

    // Admin should be able to add add storeOwners
    it("...should approve a storeOwner.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        let result = await instance.checkStoreOwnerApproved(accounts[3], 1, {from: accounts[3]});
        assert.equal(result, true, "Should return true when storeOwner is approved");
        assert.equal(await instance.storeOwnersCount.call(), 1, "StoreOwners count should equal 1...");
    });

    // Should deactivate StoreOwner from adding a store or an item.
    it("...should change storeOwner Approval.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.changeStoreOwnerApproval(accounts[3], false, 1, 1, {from: secondAccount});
        let result = await instance.checkStoreOwnerApproved(accounts[3], 1, {from: accounts[3]});
        assert.equal(result, false, "Should return false when storeOwner approved is false");
    });

    // StoreOwner should be able to add to a store.
    it("...should add a storefront.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        assert.equal(await instance.ifStoreExist.call("Store 1", 1, {from: firstAccount}), true, "Should return true when storefront is added");
    });

    // StoreOWner should be able to add items to added store(s)
    it("...should add item to a storefront.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.addItemToStore(
            "GamePad",
            "Best gamePad",
            1,
            "Store 1",
            2,
            1,
            {from: accounts[3]}
            );
        assert.equal(await instance.availableItems.call(1, {from: firstAccount}), true, "Should return true when an item is added");
    });

    // Return address of owner of a particular store if exist.
    it("...should return address of storeOwner if exists", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.approve_StoreOwner(accounts[4], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.addStorefront("Store 2", 2, {from: accounts[4]});
        assert.equal(await instance.storeOwners.call("Store 2", 2, {from: accounts[5]}), accounts[4], "Different address from the actual.");
    });

    // Delete an item from the list.
    // Only an approved storeOwner should have access
    it("...should remove an item from the list.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.addItemToStore(
            "GamePad",
            "Best gamePad",
            1,
            "Store 1",
            2,
            1,
            {from: accounts[3]}
            );

        await instance.addItemToStore(
            "Game Console",
            "Blue-cased",
            1,
            "Store 1",
            3,
            1,
            {from: accounts[3]}
            );
        await instance.removeAnItem("Store 1", 1, "GamePad", 1, {from: accounts[3]});
        assert.equal(await instance.availableItems.call(1, {from: firstAccount}), false, "Item was not removed");
        assert.equal(await instance.itemBalance.call(1, {from: firstAccount}), 0, "Item was not removed");
        assert.equal(await instance.itemcount.call({from: firstAccount}), 1, "Item was not removed");
    });

    // A storeOwner adds a store and should be able to remove as well.
    it("...should remove a storefront.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[2], 1, {from: secondAccount});
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[2]});
        await instance.addStorefront("Store 2", 2, {from: accounts[3]});
        await instance.removeAStore("Store 1", 1, 1, {from: accounts[2]});
        assert.equal(await instance.storeExist.call("Store 1", 1, {from: firstAccount}), false, "Storefront was not removed");
        assert.equal(await instance.storeCount.call({from: firstAccount}), 1, "StoreCount should equal 1");
    });

    // Change ownership
    it("...should change ownership to a different address other than Owner.", async () => {
        const instance = await GMart.new();
        await instance.transferOwnership(accounts[3]);
        assert.equal(await instance.owner.call(), accounts[3], "Admin count should equal 1...");
    });

    // Increase the balance of the target account
    it("...should increase balance of target account by minted amount.", async () => {
        const instance = await GMart.new();
        await instance.mintToken(accounts[2], 20000);
        assert.equal(await instance.balanceOf.call(accounts[2], {from: accounts[3]}), 20000, "Not correctly minted...");
    });

    // Increase the balance of a receiving account
    it("...should increase balance of target account by transfer amount.", async () => {
        const instance = await GMart.new();
        const tsupply = await instance.totalSupply.call();
        await instance.transfer(accounts[2], 2000);
        assert.equal(await instance.balanceOf.call(accounts[2], {from: accounts[3]}), 2000, "Not correctly minted...");
        assert.equal(await instance.balanceOf.call(firstAccount), tsupply - 20000, "Not correctly minted...");
    });

    // Check if token Name is correct
    it("...should confirm token name.", async () => {
        const instance = await GMart.new();
        assert.equal(await instance.name.call(), "gmarttoken", "..name unequal.");
    });

    // Compares ticker.
    it("...should confirm ticker.", async () => {
        const instance = await GMart.new();
        assert.equal(await instance.symbol.call(), "GMT", "..symbol unequal.");
    });

    // Check if an account is restricted from transfering custom token
    it("...should freeze an account.", async () => {
        const instance = await GMart.new();
        await instance.mintToken(accounts[3], 2000);
        await instance.freezeAccount(accounts[3], true);
        assert.equal(await instance.frozenAccounts.call(accounts[3]), true, "..account not frozen.");
    });

    // Check if an account possess approval to spend from another
    it("...should approve an account to spend certain amount.", async () => {
        const instance = await GMart.new();
        await instance.transfer(accounts[2], 20000);
        await instance.approve(accounts[3], 10000, {from: accounts[2]});
        assert.equal(await instance.allowance.call(accounts[2], accounts[3]), 10000, "Admin count should equal 1...");
    });

    // Check if transfering from an account is successful after approval granted
    it("...should reduce the balance in the allowed account", async () => {
        const instance = await GMart.new();
        await instance.transfer(accounts[2], 20000);
        await instance.approve(accounts[3], 10000, {from: accounts[2]});
        await instance.transferFrom(accounts[2], accounts[4], 5000, {from: accounts[3]});
        assert.equal(await instance.allowance.call(accounts[2], accounts[3]), 5000, "Transfer was unsuccessful");
    });
    
    // Burn token
    it("...should reduce the total supply by the burnt amount.", async () => {
        const instance = await GMart.new();
        const tsupply = await instance.totalSupply.call();
        await instance.burn(20000);
        assert.equal(await instance.totalSupply.call(), tsupply - 20000, "total supply was not reduced...");
    });

     // Burn token from other account (s)
    it("...should reduce the allowed amount and total supply by the burnt amount.", async () => {
        const instance = await GMart.new();
        await instance.transfer(accounts[2], 30000);
        await instance.approve(accounts[3], 20000, {from: accounts[2]});
        await instance.burnFrom(accounts[2], 5000, {from: accounts[3]});
        const tsupply = await instance.totalSupply.call();
        assert.equal(await instance.totalSupply.call(), tsupply - 10000, "total supply was not reduced...");
        assert.equal(await instance.allowance.call(accounts[2], accounts[3]), 15000, "no token was burnt...");
    });
    

    // User(s) should be able to buy items from the store(s).
    // Should return 0 item balance if all is bought.
    it("...should purchase an item from the store : return 0 item balance if all is bought..", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.transfer(accounts[4], 30000);
        await instance.addItemToStore(
            "GamePad",
            "Best gamePad",
            500,
            "Store 1",
            1,
            1,
            {from: accounts[3]}
            );
        await instance.buyItem("GamePad", 1, 1, {from: accounts[4], value: 500});
        assert.equal(await instance.itemBalance.call(1, {from: firstAccount}), 0, "Should return true when an item is added");
        assert.equal(await instance.availableItems.call(1, {from: firstAccount}), false, "Should return true when an item is added");
    });

    // User(s) should be able to buy items from the store(s).
    // Should return an item balance if part is bought.
    it("...should purchase an item from the store : return an item balance if part is bought.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.transfer(accounts[4], 30000);
        await instance.addItemToStore(
            "GamePad",
            "Best gamePad",
            1,
            "Store 1",
            3,
            1,
            {from: accounts[3]}
            );
        await instance.buyItem("GamePad", 1, 1, {from: accounts[4], value:500});
        assert.equal(await instance.itemBalance.call(1, {from: firstAccount}), 2, "Should return true when an item is added");
        assert.equal(await instance.availableItems.call(1, {from: firstAccount}), true, "Should return true when an item is added");
    });

    // StoreOwner adds item.
    // Item is sold, StoreOWner's balance is increased
    // StoreOwner withdraws balance.
    it("...should reduce account balance of storeOwner", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        await instance.transfer(accounts[4], 30000);
        await instance.addItemToStore(
            "GamePad",
            "Best gamePad",
            1,
            "Store 1",
            3,
            1,
            {from: accounts[3]}
            );
        await instance.buyItem("GamePad", 1, 1, {from: accounts[4], value:500});
        await instance.withdrawBalanceStoreOwner(accounts[5], 300, 1, {from: accounts[3]});
        assert.equal(await instance.balanceOf.call(accounts[3]), 200, "withdrawal Unsuccessful");
        assert.equal(await instance.balanceOf.call(accounts[5]), 300, "Nothing was deducted");
    });

    // Owner withdraws ether balance from contract.
    // it("... should reduce ether balance from the contract", async () => {
    //     const instance = await GMart.new();
    //     await instance.sendEther({from: accounts[5], value: 30 * ETHER});
    //     await instance.withdraw({value: 20 * ETHER});
    //     assert.equal(await instance.balanceOf(firstAccount), 20 * ETHER, "Error encountered.");
    //     assert.equal(await instance.balanceOf(this), 1 * ETHER, "Could not withdraw funds.");
    // });


});

