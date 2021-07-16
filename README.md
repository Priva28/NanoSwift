# NanoSwift: A Swift Library for the Nano cryptocurrency!

Nano is an instant, feeless and eco-friendly cryptocurrency that is also super easy to use. This library lets you create wallets, accounts and blocks as well as manage Nano amounts, interact with a node and more.

The best explanations of the Nano protocol can be found at [docs.nano.org](docs.nano.org) but I will try to explain some basic concepts below.

## Current and Planned Features

- [x] Generate accounts from specified seed and index.
- [x] Manage multiple accounts of the same seed in a wallet.
- [x] Random seed generation.
- [x] Manage Nano amounts with custom type that can convert between raw and Nano.
- [x] Create state blocks for sending and receiving.
- [x] Interact with Nano node RPC with simple convenience methods.
- [x] Conversion between hex/decimal strings and `Bytes`(`[UInt8]`).
- [x] Using compact and efficient Monocypher library for crytography (https://monocypher.org)
- [x] XCTests
- [ ] Interact with Nano node websocket.
- [ ] Local work generation.
- [ ] Improved, automated testing.

Feel free to create an issue if you find any bugs or have a feature request!


## Wallets and Accounts

A Nano wallet is essentially just a **seed** which basically everything is derived from. This seed is simply just an array of 32 random bytes. Each seed can derive from 0 to 2³²-1 **private keys** which are integral for accounts. 

The private key is used to sign blocks so they can then be sent to a node and processed throughout the Nano network.

The **public key** derived from this private key can be used to create the **public address** that users can share to send funds to. A random public address would look something like this: `nano_1i5ht818pu4axcxj4me3fgfcjbbx1a58y3k385kbo6np8399uei4jkcejtkg`

In NanoSwift, creating a wallet isn't necessary, but it can be an easy way to store a seed and the accounts that belong to it.

Creating a wallet like this will automatically generate a random seed, and an account with index 0 in a single line of code.
```Swift
// First import NanoSwift then define a Nano() object somewhere accessible.
import NanoSwift
let nano = Nano()

// Create the wallet
var wallet = nano.wallets.newWallet()
```

You can access accounts with different indexes in a wallet by using a standard array like subscript. Unlike an array though, your app will not crash if you try to access an index that does not exist, but will return nil instead. Make sure to check if the account you are trying to access actually exists.
```Swift
let firstAccount = wallet.accounts[0]
```

If the account you want to access does not exist, you can add an account to your wallet just like this.
```Swift
try nano.accounts.newAccount(into: &wallet, index: 1)
```
This could possibly fail with a `NanoAccountManagerError.indexAlreadyExists` if an account with the specified index already exists in the wallet or an `NanoAccountManagerError.otherError` if there was an error creating the account (this usually indicates an error with deriving keys from the seed).

### Working with accounts without wallets

If you don't want to use wallets to manage accounts, you can easily do that too. For example, you might only need to access a single account or you might want to store your seed and accounts somewhere else and manage accounts yourself. To use the convenience methods of NanoSwift, you WILL have to use accounts though, regardless if you choose to use wallets or not.

Create an account like this.
```Swift
let seed = "8F08B41D9ABA8DA4B97257BC08FAA939FE4BD6C91C636107F4D9CEABDD1D2FAB".hexToBytes // Convert hex string into byte array.
let account = try nano.accounts.newAccount(from: seed, index: 0)
```
This can only fail with a `NanoAccountManagerError.otherError` if there is an issue deriving keys from the seed. Usually if the seed is invalid.



## Nano Units

> 1 Nano = 1×10³⁰ raw

Nano is displayed to the user in the Nano/NANO/Mnano unit but is generally processed in raw behind the scenes(for example for account balances or creating blocks).

To help with converting between Nano and raw as well as between NSDecimalNumber and String, **`NanoAmount`** exists. This can be treated just like any other value and can be created with a Nano or raw amount.

Example:
```Swift
NanoAmount(amount: 1.5) == NanoAmount(raw: "1500000000000000000000000000000") // True
NanoAmount(amount: 1) + NanoAmount(amount: 2) // NanoAmount(amount: 3)
NanoAmount(amount: 1) * 2 == NanoAmount(raw: "2000000000000000000000000000000") // True
NanoAmount(amount: 2).rawAmount // 2000000000000000000000000000000
NanoAmount(amount: 2).rawString // "2000000000000000000000000000000"
NanoAmount(amount: 2.5).nanoAmount // 2.5
NanoAmount(amount: 2.5).nanoString // "2.5" or "2,5" depending on locale.
```



## Blocks

To create a transaction in Nano, you will have to create a block. Blocks are then published and processed throughout the network. Blocks used for transactions are called state blocks as they change the state of an existing Nano account. Generally state blocks are used to `send` or `receive` but also have other uses.

A state block has certain properties that will allow the network to check if it is valid and in order and to change what happens when the block is verified by the blockchain.
- Previous(aka Frontier): The hash of the previous block from the account creating the block.
- Account: The address or public key of the account creating the block.
- Representative: The address or public key of the representative account of the account creating the block.
- Balance: The final balance of the account creating the block after the transaction is confirmed. (higher if receiving, lower if sending)
- Link: The receiving accounts public key if the account creating the block is sending or the hash of the pending block if a receive block is being created.

The block is then hashed into 32 bytes(with the Blake2B method) and then the hash is signed(ED25519+Blake2B) with the public and private key into a 64 byte signature.

Once you have a complete signed block, you can add a value to prove the completion of work and publish the block on the network. (see **Interacting with a Nano Node**) 

Create a block for a send transaction like this.
```Swift
let sendBlock = try nano.blocks.sendBlock(from: account, to: "nano_1i5ht818pu4axcxj4me3fgfcjbbx1a58y3k385kbo6np8399uei4jkcejtkg", amount: NanoAmount(amount: 0.8))
```
If successful, you will have an automatically hashed and signed state block meant for sending. 

Possible errors from `NanoBlockManagerError` include:
- `.noFrontier` or `.noRepresentative` if an account has not fetched account info 
- `.sendingAccountLowBalance` if the sending accounts balance is too low for the transaction to happen
- `.couldNotConvertRecievingAddress` if the given address is invalid
- `.otherError` if an error occured hashing the block.

Creating a receive block is just as easy after fetching pending transactions from a node.
```Swift
let receiveBlock = try nano.blocks.receiveBlock(for: account, with: pendingBlock)
```
Possible errors are the same as sending except for low balance and unable to convert receiving address as these don't happen when creating a receive block.

## Interacting with a Nano Node

Eventually, you will want to get information from the network about its current state or publish your own blocks to the network to transact with Nano. You do this by interacting with a **node**. NanoSwift is NOT an alternative for a node, but instead assumes you are able to connect to an already exiting node. NanoSwift gives you the tools to work with Nano in Swift but a running node is still a necessity to interact with the Nano network.

Start by connecting to a nodes RPC or a proxy for a nodes RPC.
```Swift
let node = nano.newNode(address: "http://localhost:7076")
```

There are a few main things you can do once connected to a node with convenience methods in NanoSwift that will handle everything, but you can also make your own custom requests and handle responses yourself.

#### Getting account info
##### Async/Await
```Swift
// Put account info into account
try await node.putAccountInfo(into: &account)

// Get account info
let accountInfo = try await node.getAccountInfo(for: account)
```
##### Completion handler
```Swift
node.getAccountInfo(for: account) { accountInfo, error in
    if error == nil {
        let result = accountInfo!
    }
}
```

#### Generating work
##### Async/Await
```Swift
let work = try await node.generateWork(for: account, type: .send)
```
##### Completion handler
```Swift
node.generateWork(for: account, type: .receive) { work, error in
    if error == nil {
        let result = work!
    }
}
```

#### Get pending blocks
##### Async/Await
```Swift
let pending = try await node.getPendingBlocks(for: account)
```
##### Completion handler
```Swift
node.getPendingBlocks(for: account) { pendingBlocks, error in
    if error == nil {
        let result = pendingBlocks!
    }
}
```

#### Publish block
##### Async/Await
```Swift
try await node.publish(block: sendBlock, type: .send)
```
##### Completion handler
```Swift
node.publish(block: receiveBlock, type: .receive) { error in
    if error == nil {
        // Success
    }
}
```

#### Custom command
```Swift
let body: [String: Any] = [
    "action": "version"
]
```
##### Async/Await
```Swift
let responseData = try await node.rpcRequest(body: body)
```
##### Completion handler
```Swift
node.rpcRequest(body: body) { data, error in
    if error != nil {
        // Handle error
    }
    // Do whatever you wish with the returned data.
}
```

## Real world examples

### Send 0.3 Nano from one account to another
```Swift
func sendTransaction() async throws {
    // First import the account that we want to use.
    var account = try nano.accounts.newAccount(from: seed, index: 1)

    // Connect to a node.
    let node = nano.newNode(address: address)

    // Update account with latest account info (including current balance).
    try await node.putAccountInfo(into: &account)

    // How much to send?
    let amount = NanoAmount(amount: 0.3)

    // Create an automatically signed send block.
    var sendBlock = try nano.blocks.sendBlock(from: account, to: "nano_34rmn94mh6hfqzs3qxo9f4ua139uzg34spk74dat3a6xr6nauu4yqdk8rmbd", amount: amount)

    // Generate work for block.
    sendBlock.work = try await node.generateWork(for: account, type: .send)

    // Publish block on the network!
    try await node.publish(block: sendBlock, type: .send)
}
```

### Receive all pending transactions
```Swift
func testPending() async throws {
    // First import the account that we want to use.
    var account = try nano.accounts.newAccount(from: seed, index: 1)

    // Connect to a node.
    let node = nano.newNode(address: address)

    // Update account with latest account info (including current balance).
    try await node.putAccountInfo(into: &account)

    // Get pending transactions from the network.
    let pending = try await node.getPendingBlocks(for: account)

    // Loop through pending transactions and create and send a state block to receive each pending transaction.
    for block in pending {
        var receiveBlock = try nano.blocks.receiveBlock(for: account, with: block)
        receiveBlock.work = try await node.generateWork(for: account, type: .receive)
        try await node.publish(block: receiveBlock, type: .receive)
    }
}
```


## Advanced operations

#### Generating a new random wallet seed
```Swift
let seed = nano.wallets.functions.generateWalletSeed()
```

#### Deriving a private key from a wallet seed and index
```Swift
let privateKey = nano.accounts.functions.derivePrivateKey(from: seed, index: 0)
```

#### Deriving a public key from a private key
```Swift
let publicKey = nano.accounts.functions.derivePublicKey(from: privateKey)
```

#### Encode a public key for a public address
```Swift
let encodedPublicKey = nano.accounts.functions.encodePublicKey(from: publicKey)
```

#### Decode an encoded public key (into binary)
```Swift
let decodedPublicKey = nano.accounts.functions.decodePublicKey(from: encodedPublicKey)
```

#### Create a checksum for a public key
```Swift
let checksum = nano.accounts.functions.createChecksum(from: publicKey)
```

#### Check the validity of a Nano public address
```Swift
let check = nano.accounts.functions.checkIfAddressIsValid(address: "nano_1i5ht818pu4axcxj4me3fgfcjbbx1a58y3k385kbo6np8399uei4jkcejtkg")
// Possible cases are valid, invalidLength, invalidEncoding, invalidChecksum, invalidPrefix or invalidOther
```

#### Split a Nano public address
```Swift
let splitAddress = nano.accounts.functions.splitAddress(address:  "nano_1i5ht818pu4axcxj4me3fgfcjbbx1a58y3k385kbo6np8399uei4jkcejtkg")
let prefix = splitAddress.0
let encodedPublicKey = splitAddress.1.0
let checksum = splitAddress.1.1
```

#### Hash a state block
```Swift
let hash = nano.blocks.functions.hashStateBlock(from: block!)
```

#### Sign a state block hash
```Swift
let signed = nano.blocks.functions.signStateBlockHash(hash: hash.forceUnwrap, privateKey: privateKey)
```

## Donations

NanoSwift is free to use wherever you like, so if it's useful to you, please consider donating! Even the smallest amounts are appreciated!

`nano_1rcnz81p7yhdi18cuj934wczo437xr8zjxt4596iderokbjtcfm18fdxt6ng`
