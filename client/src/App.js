import React, { Component } from "react";

import Web3 from 'web3';
import Navbar from './Navbar';
// import Main from './Main';
import addAdmin from './addAdmin';
import changeAdminApproval from './changeadminApproval';

import "./App.css";

class App extends Component {

  render() {
    // if (!this.state.web3) {
    //   return <div>Loading Web3, accounts, and contract...</div>;
    return (
      <Navbar account={this.state.account} />,
      <div>
        <input placeholder="Enter to-do" value={this.state.currentTodo} onChange={this.onInputChange}/>
        <button onClick={this.onClickChange}>Add</button>
        {/* using ternary operator */}
        <br />
        { this.state.todo.length === 0 ? "No to-do yet" :  <ul>{}</ul>}
      </div>
    );
      /* <main role="main" className="col-lg-12 d-flex">
        {this.state.loading ? 
        <div id="loader" className="text-center">
          <p className="text-center">Loading..</p>
          </div>
          : <Main addadmin={this.addAdmin} />
        }
      </main> */
      // <div className="App">
      //   <h1>Example contract!</h1>
      //   <p>
      //     Adding an admin to the storefront...
      //   </p>
      //   <div>The status of account address: {this.state.address} is set to: {this.state.storageValue}</div>
      // </div>
  }
}

export default App;
