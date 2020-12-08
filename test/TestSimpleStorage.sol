pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GMart.sol";

contract TestGMart {
  GMart gmartInstance = GMart(DeployedAddresses.GMart());
  address public owner;
  address admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

  function testcheckOwnerIsCorrect() public {
    // GMart gmartInstance = GMart(DeployedAddresses.GMart());
    Assert.equal(gmartInstance.owner(), msg.sender, "An owner is not the same with deployer");
  }

  function testCheckIsAdminFail() public {
    // GMart gmartInstance = GMart(DeployedAddresses.GMart());
    bool result = gmartInstance.checkIsAdmin(admin, 1);
    Assert.equal(result, false, "Should fail and return false");
  }

  // function testAddAdmin() public {
  //   // GMart gmartInstance = GMart(DeployedAddresses.GMart());
  //   owner = gmartInstance.owner();
  //   bool result = gmartInstance.addAdmin(admin);
  //   Assert.equal(result, true, "Should return true when an admin is added");
  // }

  // function testCheckIsAdminPass() public {
  //   GMart gmartInstance = new GMart();
  //   bool actual = gmartInstance.checkIsAdmin(admin, 0);
  //   bool expected = true;
  //   Assert.equal(actual, expected, "Should return 'TRUE' if an admin is added.");
  // }

}
