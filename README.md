Dmarkey is an Online marketplace that operates on the blockchain.
It consists of a list of stores where shoppers can purchase goods posted by the store owners. 
It is managed by a group of administrators who are permitted to add store owners to add stores to the marketplace. 
The Store owners are able to add items to their stores, manage store’s inventory and funds while the Shoppers can visit 
     the stores and purchase goods that are in stock using a native cryptocurrency of the platform.
     
Front-end implementation is in progress. Before then, you can interact with this contract following these steps:

You may use remix or truffle or any compatible IDE.
  Using Remix:
    - Visit remix.org
    - Create a file with .sol extension and paste the code.
    - Using Javascript VM, deploy the contract.
      Note: You may need to slightly increase the gas limit. 4000000 Gas Limit would work fine.
    - Now, it should be successfully deployed and you can interact with the deployed contract in remix.
    
    
Using Truffle:
  - Ensure you have npm, truffle and ganache installed on your machine.
  - Launch the git bash or the CLI.
  - Make a new project directory.
  Run:
    * $ git clone https://github.com/bobeu/consensys-finalProject.git
    * $ cd consensys-finalProject
    * $ truffle compile
    * Launch a new instance of the command prompt or git bash.
    * Get ganache running. run:
                              $ ganache-cli --gasPrice 21000000000 -l 8000000 --callGasLimit 0x3d0900 --allowUnlimitedContractSize
                              This launches ganache with gas price of 21Gwei, 8000000 gas limit, call gas limit of 4000000 per transaction
                              and overrides the default contract size allowed in the ganache's configuration setting.
    * $ truffle migrate
          If all things rightly done, contract GMart.sol should be successfully deployed.
          
    * $ <truffle test> runs all test files in in the test directory.
    
Open truffle console to interact with the deployed contract. Run:
                                                                truffle console

