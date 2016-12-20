# Usage Examples

The following code samples should be run in the geth javascript environment:

```bash
$ geth attach # attach the geth console to a local, running geth instance.
```
In the Geth JavaScript console:

```javascript
> personal.unlockAccount(eth.accounts[0]) // unlock an ethereum wallet account
// enter the wallet password when prompted
> registry = eth.contract(/* paste didm-registry.abi.json here */).at(/* paste registry address here */)
```

## Create a new Consent DID

```javascript
// Send a transaction to the registry:
> create_txhash = registry.create("", { from: eth.accounts[0], gas: 300000 })
"0x9d38bc0cd277ba25ce54fef7ed941e9866d05f7f5f5638c409b1a6925e2931f5" // returns pending transaction hash
```

**...wait for the transaction to be mined...**

```javascript
// Get the consent did address:
> consent_did_address = "0x" + eth.getTransactionReceipt(create_txhash).logs[0].data.slice(26)
"0x3268f0391c1b0b3201fb01648834f22dc2dd3c6f" // returns new consent did
> did = eth.contract(/* paste cnsnt-did.abi.json here */).at(consent_did_address)
```

## Update a DDO

```javascript
> new_ddo_string = JSON.stringify({ "@key": "value" })
> update_txhash = did.forward(
    registry.address,
    0,
    registry.update.getData(new_ddo_string),
    {
      from: eth.accounts[0],
      gas: 300000
    }
  )
```

## Verify a Consent DID

```javascript
> registry.verify("0x3268f0391c1b0b3201fb01648834f22dc2dd3c6f")
"{\"@key\":\"value\"}" // Returns the ddo string
```

## Revoke a DDO

```javascript
> revoke_txhash = did.forward(
    registry.address,
    0,
    registry.revoke.getData(),
    {
      from: eth.accounts[0],
      gas: 300000
    }
  )
```
