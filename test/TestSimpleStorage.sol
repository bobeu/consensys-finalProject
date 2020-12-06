pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GMart.sol";

contract TestGMart {
  // address owner;
  address admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
  
  // Assert assert = new Assert();
  // modifier onlyOwner() {
  //   require(msg.sender == owner, "Not an owner");
  //   _;
  // }
  // function checkOwnerIsCorrect() public {
  //   GMart gmartInstance = new GMart();
  //   // Assert(gmartInstance.owner(), this, "An owner is not the same with deployer");
  //   Assert.equal(gmartInstance.owner(), this, "An owner is not the same with deployer");
  // }

  // function testCheckIsAdminFail() public {
  //   GMart gmartInstance = new GMart();
  //   bool actual = gmartInstance.checkIsAdmin(admin, 1);
  //   bool expected = false;
  //   Assert.equal(actual, expected, "Should fail and return false");
  // }

  // function testAddAdmin() public {
  //   GMart gmartInstance = new GMart();
  //   bool actual = gmartInstance.addAdmin(admin);
  //   bool expected = true;
  //   Assert.equal(actual, expected, "Should return true when an admin is added");
  // }

  // function testCheckIsAdminPass() public {
  //   GMart gmartInstance = new GMart();
  //   bool actual = gmartInstance.checkIsAdmin(admin, 0);
  //   bool expected = true;
  //   Assert.equal(actual, expected, "Should return 'TRUE' if an admin is added.");
  // }

}
