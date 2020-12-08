
/*
Testing for GMart contract - "./contract/GMart.sol"
*/
let GMart = artifacts.require("GMart");
let catchRevert = require("./exceptionsHelpers.js").catchRevert;

contract('GMart', accounts => {

    const [firstAccount, secondAccount] = accounts;
    // const FINNEY = 10**15;
    // const ether = 10 * wei;
    // const instance = async () => {await GMart.new();}
    
    /*
    Trying to test globally
    */
    // async () => {await instance.addAdmin(accounts[1]);}
    // async () => {await instance.changeAdminApproval(secondAccount, true, 1);}

    it("...sets an owner", async () => {
        const instance = await GMart.new();
        assert.equal(await instance.owner.call(), firstAccount, "Should set an owner.");
    });

    it("...should add an admin to the admin List.", async () => {
        const instance = await GMart.new();
        const _owner = instance.owner;
        await instance.addAdmin(accounts[1]);
        const expected = await instance.checkIsAdmin(accounts[1], 1);
        assert.equal(expected, true, "Should return true when address is added");
    });

    it("...should return false if admin is added.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        const expected = await instance.checkIfAdmincanAdd(secondAccount);
        assert.equal(expected, false, 'Should return true ');
    });

    it("...should change an admin approval to add.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        const expected = await instance.checkIfAdmincanAdd(secondAccount);
        assert.equal(expected, true, "The approval should change to true.");
    });

    it("...should approve a storeOwner.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        let result = await instance.checkStoreOwnerApproved(accounts[3], 1, {from: accounts[3]});
        assert.equal(result, true, "Should return true when storeOwner is approved");
    });

    it("...should change storeOwner Approval.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.changeStoreOwnerApproval(accounts[3], false, 1, 1, {from: secondAccount});
        let result = await instance.checkStoreOwnerApproved(accounts[3], 1, {from: accounts[3]});
        assert.equal(result, false, "Should return false when storeOwner approved is false");
    });

    it("...should add a storefront.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(secondAccount);
        await instance.changeAdminApproval(secondAccount, true, 1);
        await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
        await instance.addStorefront("Store 1", 1, {from: accounts[3]});
        assert.equal(await instance.ifStoreExist.call("Store 1", 1, {from: firstAccount}), true, "Should return true when storefront is added");
    });

    it("...should add a storefront.", async () => {
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
        assert.equal(await instance.availableItems.call("GamePad", 1, {from: firstAccount}), true, "Should return true when an item is added");
    });

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

    // it("...should fail", async () => {
    //     const instance = await GMart.new();
    //     await instance.addAdmin(secondAccount);
    //     await instance.changeAdminApproval(secondAccount, true, 1);
    //     await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
    //     await instance.approve_StoreOwner(accounts[4], 1, {from: secondAccount});
    //     await instance.addStorefront("Store 1", 1, {from: accounts[3]});
    //     await instance.addStorefront("Store 2", 2, {from: accounts[4]});
    //     const result = await instance.getStoreOwner("Store 1", 1, {from: firstAccount});
    //     assert.equal(result, accounts[4], "Should fail");
    // });

    // it("...should get a storeOwner.", async () => {
    //     const instance = await GMart.new();
    //     await instance.addAdmin(secondAccount);
    //     await instance.changeAdminApproval(secondAccount, true, 1);
    //     await instance.approve_StoreOwner(accounts[3], 1, {from: secondAccount});
    //     await instance.approve_StoreOwner(accounts[4], 2, {from: secondAccount});
    //     await instance.addStorefront("Store 1", 1, {from: accounts[3]});
    //     assert.equal(await instance.storeOwner.call("Store 1", 1, {from: firstAccount}), true, "Should return true when storefront is added");
    // });





});

