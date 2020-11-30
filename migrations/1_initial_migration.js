var GMart = artifacts.require("./GMart.sol");
const owner = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
module.exports = function(deployer) {
  deployer.deploy(GMart, owner);
};
