pragma solidity >=0.4.21 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GMart.sol";

contract TestGMart {
  address owner;
  address admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
  GMart gmartInstance = GMart(DeployedAddresses.GMart());

  constructor () public {
    owner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not an owner");
    _;
  }

  function testCheckIsAdminFail() public {
    (bool actual_1, bool actual_2) = gmartInstance.checkIsAdmin(admin);
    bool expected = false;
    Assert.equal(actual_2, expected, "Should fail and return false");
    Assert.equal(actual_1, expected, "This test should fail by returning false.");
  }

  function testAddAmdin() public onlyOwner {
    bool actual = gmartInstance.addAdmin(admin, true);
    bool expected = true;
    Assert.equal(actual, expected, "Should return true when an admin is added");
  }

  function testCheckIsAdminPass() public {
    (bool actual_1, bool actual_2) = gmartInstance.checkIsAdmin(admin);
    bool expected = true;
    Assert.equal(actual_2, expected, "Should return 'TRUE' if an admin is added.");
    Assert.equal(actual_1, expected, "Should return 'TRUE' if an admin is added.");
  }

}
