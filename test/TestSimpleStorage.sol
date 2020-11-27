pragma solidity >=0.4.21 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/GMart.sol";

contract TestGMart {

  function testAdminApprovalChanged() public {
    GMart gmartInstance = GMart(DeployedAddresses.GMart());

    bool actual = gmartInstance.addAdmin(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, true);
    bool expected = true;

    Assert.equal(actual, expected, "It should return true.");
  }

}
