# pokemonD


DApp Structure
======

```Bash
  app/
    |___ contracts/ #solidity or serpent contracts
    |___ html/
    |___ css/
    |___ js/
  config/
    |___ blockchain.json #rpc and blockchain configuration
    |___ contracts.json  #ethereum contracts configuration
    |___ storage.json  #ipfs configuration
    |___ communication.json  #whisper/orbit configuration
    |___ webserver.json  #dev webserver configuration
  test/
    |___ #contracts tests
```
* Client Side: [Web3.js](https://github.com/ethereum/wiki/wiki/JavaScript-API) and [EmbarkJS](#embarkjs)

Using Contracts
======
Embark will automatically take care of deployment for you and set all needed JS bindings. For example, the contract below:

```Javascript
# app/contracts/simple_storage.sol
pragma solidity ^0.4.17;
contract SimpleStorage {
  uint public storedData;

  function SimpleStorage(uint initialValue) public {
    storedData = initialValue;
  }

  function set(uint x) public {
    storedData = x;
  }
  function get() view returns (uint retVal) {
    return storedData;
  }
}
```
Will automatically be available in Javascript as:

```Javascript
# app/js/index.js
SimpleStorage.methods.set(100).send({from: web3.eth.defaultAccount});
SimpleStorage.methods.get().call().then(function(value) { console.log(value.toNumber()) });
SimpleStorage.methods.storedData().then(function(value) { console.log(value.toNumber()) });
```

You can specify for each contract and environment its gas costs and arguments:

```Json
# config/contracts.json
{
  "development": {
    "gas": "auto",
    "contracts": {
      "SimpleStorage": {
        "args": [
          100
        ],
        "gas": 800000
      }
    }
  }
}
```

If you are using multiple contracts, you can pass a reference to another contract as ```$ContractName```, Embark will automatically replace this with the correct address for the contract. You can also specify interfaces and choose to not deploy contracts (for e.g in case they are interfaces)


```Json
# config/contracts.json
{
  ...
  "development": {
    "contracts": {
      "SimpleStorage": {
        "args": [
          100,
          "$MyStorage"
        ]
      },
      "MyStorage": {
        "args": [
          "initial string"
        ]
      },
      "MyMainContract": {
        "args": [
          "$SimpleStorage"
        ]
      },
      "MyContractInterface": {
        "deploy": false
      }
    }
  }
  ...
}
```

You can now deploy many instances of the same contract. e.g


```Json
# config/contracts.json
{
  "development": {
    "contracts": {
      "Currency": {
        "deploy": false,
        "args": [
          100
        ]
      },
      "Usd": {
        "instanceOf": "Currency",
        "args": [
          200
        ]
      },
      "MyCoin": {
        "instanceOf": "Currency",
        "args": [
          200
        ]
      }
    }
  }
}
  ...
```

Contracts addresses can be defined. If an address is defined, Embark uses the defined address instead of deploying the contract.


```Json
# config/contracts.json
{
  ...
  "development": {
    "contracts": {
      "UserStorage": {
        "address": "0x123456"
      },
      "UserManagement": {
        "args": [
          "$UserStorage"
        ]
      }
    }
  }
  ...
}
```

You can Also specify which versions of solc and web3.js to use:

```Json
# config/contracts.json
{
  ...
  "development": {
    "versions": {
      "web3.js": "1.0.0-beta",
      "solc": "0.4.17"
    }
  }
  ...
}
```

You specify which node the contracts should be deploy to and the order of nodes
the dapp should connect to. $WEB3 means the dapp will try to use an existing
web3 object first if available.

```Json
# config/contracts.json
{
  ...
  "development": {
    "deployment": {
      "host": "localhost",
      "port": 8545,
      "type": "rpc"
    },
    "dappConnection": [
      "$WEB3",
      "http://localhost:8545"
    ]
  }
  ...
}
```

EmbarkJS
======

EmbarkJS is a javascript library meant to abstract and facilitate the development of DApps.

**promises**

```Javascript
  var myContract = new EmbarkJS.Contract({abi: abiObject, address: "0x123"});
  myContract.methods.get().call().then(function(value) { console.log("value is " + value.toNumber) });
```

events:

```Javascript
  myContract.events.eventName({from: web3.eth.accounts}, 'latest').then(function(event) { console.log(event) });
```

**deployment**

Client side deployment will be automatically available in Embark for existing contracts:

```Javascript
  SimpleStorage.deploy([args], {options}).then(function(anotherSimpleStorage) {});
```

or it can be manually definied as

```Javascript
  var myContract = new EmbarkJS.Contract({abi: abiObject, code: code});
  myContract.deploy([args], {options}).then(function(anotherMyContractObject) {});
```

so you can define your gas as

```Javascript
  myContract.deploy([100, "seconde argument"], {gas: 800000}).then(function(anotherMyContractObject) {});
```

EmbarkJS - Storage
======

**initialization**

The current available storage is IPFS. It can be initialized as

```Javascript
  EmbarkJS.Storage.setProvider('ipfs',{server: 'localhost', port: '5001'})
```

**Saving Text**

```Javascript
  EmbarkJS.Storage.saveText("hello world").then(function(hash) {});
```

**Retrieving Data/Text**

```Javascript
  EmbarkJS.Storage.get(hash).then(function(content) {});
```

**Uploading a file**

```HTML
  <input type="file">
```

```Javascript
  var input = $("input[type=file"]);
  EmbarkJS.Storage.uploadFile(input).then(function(hash) {});
```

**Generate URL to file**

```Javascript
  EmbarkJS.Storage.getUrl(hash);
```

note: if not using localhost, the cors needs to be set as ```ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["your-host-name-port"]```

EmbarkJS - Communication
======

**initialization**

For Whisper (note: currently requires geth 1.6.0 or higher):

```Javascript
    EmbarkJS.Messages.setProvider('whisper')
```

For Orbit:

You'll need to use IPFS from master and run it as: ```ipfs daemon --enable-pubsub-experiment```

then set the provider:

```Javascript
  EmbarkJS.Messages.setProvider('orbit', {server: 'localhost', port: 5001})
```

**listening to messages**

```Javascript
  EmbarkJS.Messages.listenTo({topic: ["topic1", "topic2"]}).then(function(message) { console.log("received: " + message); })
```

**sending messages**

you can send plain text

```Javascript
  EmbarkJS.Messages.sendMessage({topic: "sometopic", data: 'hello world'})
```

or an object

```Javascript
  EmbarkJS.Messages.sendMessage({topic: "sometopic", data: {msg: 'hello world'}})
```

note: array of topics are considered an AND. In Whisper you can use another array for OR combinations of several topics e.g ```["topic1", ["topic2", "topic3"]]``` => ```topic1 AND (topic2 OR topic 3)```

Tests
======

You can run specs with ```embark test```, it will run any test files under ```test/```.

Embark includes a testing lib to rapidly run & test your contracts in a EVM.

```Javascript
# test/simple_storage_spec.js
describe("SimpleStorage", function() {
  before(function(done) {
    this.timeout(0);
    var contractsConfig = {
      "SimpleStorage": {
        args: [100]
      }
    };
    EmbarkSpec.deployAll(contractsConfig, done);
  });

  it("should set constructor value", function(done) {
    SimpleStorage.storedData(function(err, result) {
      assert.equal(result.toNumber(), 100);
      done();
    });
  });

  it("set storage value", function(done) {
    SimpleStorage.set(150, function() {
      SimpleStorage.get(function(err, result) {
        assert.equal(result.toNumber(), 150);
        done();
      });
    });
  });

});

```

Embark uses [Mocha](http://mochajs.org/) by default, but you can use any testing framework you want.

Working with different chains
======
You can specify which environment to deploy to:


```$ embark blockchain livenet```

```$ embark run livenet```

The environment is a specific blockchain configuration that can be managed at config/blockchain.json

```Json
# config/blockchain.json
  ...
   "livenet": {
    "networkType": "livenet",
    "rpcHost": "localhost",
    "rpcPort": 8545,
    "rpcCorsDomain": "http://localhost:8000",
    "account": {
      "password": "config/livenet/password"
    }
  },
  ...
```

Structuring Application
======

Embark is quite flexible and you can configure your own directory structure using ```embark.json```

```Json
# embark.json
{
  "contracts": ["app/contracts/**"],
  "app": {
    "css/app.css": ["app/css/**"],
    "images/": ["app/images/**"],
    "js/app.js": ["embark.js", "app/js/**"],
    "index.html": "app/index.html"
  },
  "buildDir": "dist/",
  "config": "config/",
  "plugins": {}
}
```

Deploying to IPFS and Swarm
======

To deploy a dapp to IPFS, all you need to do is run a local IPFS node and then run ```embark upload ipfs```.
If you want to deploy to the livenet then after configuring you account on ```config/blockchain.json``` on the ```livenet``` environment then you can deploy to that chain by specifying the environment ```embark ipfs livenet```.

To deploy a dapp to SWARM, all you need to do is run a local SWARM node and then run ```embark upload swarm```.

Plugins
======

It's possible to extend Embark's functionality with plugins. For example, the following is possible:

* plugin to add support for es6, jsx, coffescript, etc (``embark.registerPipeline``)
* plugin to add standard contracts or a contract framework (``embark.registerContractConfiguration`` and ``embark.addContractFile``)
* plugin to make some contracts available in all environments for use by other contracts or the dapp itself e.g a Token, a DAO, ENS, etc.. (``embark.registerContractConfiguration`` and ``embark.addContractFile``)
* plugin to add a libraries such as react or bootstrap (``embark.addFileToPipeline``)
* plugin to specify a particular web3 initialization for special provider uses (``embark.registerClientWeb3Provider``)
* plugin to create a different contract wrapper (``embark.registerContractsGeneration``)
* plugin to add new console commands (``embark.registerConsoleCommand``)
* plugin to add support for another contract language such as viper, LLL, etc (``embark.registerCompiler``)


# built with embark
## https://github.com/embark-framework/embark/blob/develop/README.md



# how to run the game in local devenv


## STACK WE USED :
 ### embark
 ### geth
 ### ipfs(CORS)
 ### ganache-cli
 # run ganache-cli
 
## CLONE THE REPO 
### cd to the clone repo
### embark blockchain
### in other console,cd to repo and run 
### embark run














