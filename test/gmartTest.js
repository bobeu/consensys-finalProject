
/*
Testing for GMart contract - "./contract/GMart.sol"
*/
let GMart = artifacts.require("GMart");
let catchRevert = require("./exceptionsHelpers.js").catchRevert;

contract('GMart', accounts => {

    const [firstAccount] = accounts;

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
        await instance.addAdmin(accounts[1]);
        const expected = await instance.checkIfAdmincanAdd(accounts[1]);
        assert.equal(expected, false, 'Should return true ');
    });

    it("...should change an admin approval to add.", async () => {
        const instance = await GMart.new();
        await instance.addAdmin(accounts[2]);
        await instance.changeAdminApproval(accounts[2], true, 1);
        const expected = await instance.checkIfAdmincanAdd(accounts[2]);
        assert.equal(expected, true, "The approval should change to true.");
    });


});

