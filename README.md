# OpenZeppelin POC
 This is a project which is a poc for developing secure smart contracts using solidity.

 **How to install**

```sh
$ git clone git@github.com:sachushaji/openzepplin-poc.git
$ cd openzepplin-poc
$ npm install
$ npm install truffle -g
```
The deployment to the ethereum test network ropsten is preconfigured to ropsten testnet and you can also use ganache in your local system to deploy the contract.

**How to deploy using ganache**

Install [ganache](https://truffleframework.com/ganache) compatible with your system. Run ganache which will start a local blockchain running into your local machine at port 8545. Then do the following steps in terminal.

```sh
$ truffle compile
$ truffle deploy
```
It will deploy the contract into your local ethereum blockchain. You can see the logs in ganache to get the contact address. You can use remix to interact with the contract by connecting metamask to your local ethereum node by providing the custom url *"http://localhost:8545"* and providing the contract address into the remix browser.


**How to deploy using infura to ropsten testnet**

You will need to signup for an infura account. From there you will get your custom appid to interact with your node. 
 Create an enviornment file **.env** file in your repo. And add the following content.
 ```
 export infuraId='paste your infura appid'
export mnemonic='paste in your seed phrase from metamask'
 ```
Make sure the account has some balance to deploy the contract. Now follow these steps

```sh
$ truffle compile
$ truffle deploy
```
It will deploy the contract into your ropsten testnet in a few seconds. You can see the contract being created by your account from [ropsten](https://ropsten.etherscan.io/). You can use remix to interact with the contract by connecting metamask to your ropsten and providing the contract address into the remix browser.
