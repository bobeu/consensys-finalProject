import React, { Component } from "react";
import Dmarket from "./contracts/Dmarket.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = {address: null, response: null, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();
      const contractsDetail = new web3.eth.Contract(jsonInterface[, address][, options]);

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = Dmarket.networks[networkId];
      const instance = new web3.eth.Contract(
        Dmarket.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;
    const admin = "0x7624269a420c12395B743aCF327A61f91bd23b84";
    // const contract_Address = getWeb3.Contract(contract);
    console.log(admin, accounts);

    // const deposit = web3.utils.toBN("29a2241af62c0000");
    // const withdrawAmount = web3.utils.toBN("1bc16d674ec80000");

    // Stores a given value, 5 by default.
    await contract.methods.addAdmin(admin).send({ from: accounts[0]});

    // Get the value from the contract to prove it worked.
    const adminStatus = await contract.methods.isAdmin.call(admin, 1);
    // Update state with the result.
    if(adminStatus) {
      this.setState({address: admin, response: adminStatus });
    }
    this.setState({res: "The transaction failed"});    
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Example contract!</h1>
        <p>
          Adding an admin to the storefront...
        </p>
        <div>The status of account address: {this.state.address} is set to: {this.state.storageValue}</div>
      </div>
    );
  }
}

export default App;
