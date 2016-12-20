# Usage Examples

The following code samples should be run in the geth javascript environment:

```javascript
∆ geth attach # attach the geth console to a local, running geth instance.
> personal.unlockAccount(eth.accounts[0]) # unlock an ethereum wallet account.
> registry = eth.contract(/* paste didm-registry.abi.json here */).at(/* paste registry address here */)
```

## Create a new Consent DID

```javascript
// Send a transaction to the registry:
> transaction_hash = registry.create("", { from: eth.accounts[0], gas: 300000 })
"0x9d38bc0cd277ba25ce54fef7ed941e9866d05f7f5f5638c409b1a6925e2931f5" // returns hash of the did creation transaction
```

**wait for the transaction to be mined**

```javascript
// Get the consent did address:
> consent_did_address = "0x" + eth.getTransactionReceipt(transaction_hash).logs[0].data.slice(26)
"0x3268f0391c1b0b3201fb01648834f22dc2dd3c6f" // returns new consent did
```

## Update a DDO

```javascript

```

## Revoke a DDO

```javascript

```
