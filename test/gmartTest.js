const GMart = artifacts.require("./GMart.sol");

contract("GMart", accounts => {
  it("...should change an admin approval to add.", async () => {
    const gmartinstance = await GMart.deployed();

    // Set aapproval for an admin to true.
    await gmartinstance.changeAdminApproval(accounts[1], true, { from: accounts[0] });
    // Get stored value
    const storedData = await gmartinstance.get.call(adminApprovalToAdd(accounts[1]));

    assert.equal(storedData, true, "The approval was not changed.");
  });
});


// const IPFSInbox = artifacts.require("./IPFSInbox.sol");
// contract("IPFSInbox", accounts => {
//   it("...should emit an event when you send an IPFS address.", 
//     async () => {
//         // Wait for the contract to be deployed
//         const ipfsInbox = await IPFSInbox.deployed();
//         // Set a variable to false, and create an event listener
//         // to set it to true if the event fires.       
//         eventEmitted = false
//         var event = ipfsInbox.ipfsSent()
//         await event.watch((err, res) => {
//             eventEmitted = true
//         })
//         // Call the contract function which sends an IPFS address
//         await ipfsInbox.sendIPFS(accounts[1], 
//             "SampleAddress", { from: accounts[0] });
//         // Check if the variable is set to true by this time
//         assert.equal(eventEmitted, true, 
//             "Sending an IPFS request does not emit an event.");
//     });
// });