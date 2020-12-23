pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Dmarket.sol";

contract TestDmarket {
  Dmarket dmartInstance = Dmarket(DeployedAddresses.Dmarket());
  address admin = 0x8e3CfD89Dc44d88B5aB146F40E41b14557f4F341;

  function testcheckOwnerIsCorrect() public {
    // GMart gmartInstance = GMart(DeployedAddresses.GMart());
    Assert.equal(dmartInstance.owner(), msg.sender, "An owner is not the same with deployer");
  }

  function testCheckIsAdminFail() public {
    // GMart gmartInstance = GMart(DeployedAddresses.GMart());
    bool result = dmartInstance.isAdmin(admin, 1);
    Assert.equal(result, false, "Should fail and return false");
  }

}
