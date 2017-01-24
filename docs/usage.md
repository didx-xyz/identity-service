# Usage Examples

The following code samples should be run in the [Geth JavaScript console](https://github.com/ethereum/go-ethereum/wiki/JavaScript-Console).

```bash
# attach the geth console to a local, running geth instance:
$ geth attach
Welcome to the Geth JavaScript console!
> _
```
```javascript
// Unlock any (funded) geth wallet account:
> personal.unlockAccount(eth.accounts[0]);
// ...enter the wallet passphrase when prompted

// Create a JavaScript instance of the registry contract:
> registry = eth.contract(/* didm-registry.abi.json */).at(/* registry address */);
```
* [didm-registry.abi.json](../src/sol/didm-registry.abi.json)




## Create a new Consent DID

```javascript
// Send a `create` call directly to the registry contract:
> did_creation_tx_hash = registry.create(
  "",                      // <- Optionally set DDO (or empty string),
  0, {                     //    0 sets the transaction signer as "controller"
    from: eth.accounts[0], // <- Use the first geth account to pay for this tx
    gas: 300000            // <- Set a gas ammount, unused gas will be returned
  });

// returns pending transaction hash:
"0x9d38bc0cd277ba25ce54fef7ed941e9866d05f7f5f5638c409b1a6925e2931f5"

/******************************************************************************

  Wait for the transaction to be mined!

  This should take between 30 and 120 seconds. Continue only after the
  transaction has been confirmed the required number of times. (12 recommended)

******************************************************************************/

// Find the Consent DID address in the transaction log:
> consent_did_address = "0x"+eth.getTransactionReceipt(did_creation_tx_hash).logs[0].data.slice(26);

// returns new consent did address:
"0x3268f0391c1b0b3201fb01648834f22dc2dd3c6f"

// Create a JavaScript instance of the specific Consent DID contract:
> did = eth.contract(/* cnsnt-did.abi.json */).at(consent_did_address);
```
* [cnsnt-did.abi.json](../src/sol/cnsnt-did.abi.json)




## Update a DDO

```javascript
// Stringify the DDO first, as the registry only stores strings:
> new_ddo_string = JSON.stringify({ "@key": "value" });

// Forward a `update` registry call via the new Consent DID contract:
> ddo_update_tx_hash = did.forward(
    registry.address,                        // <- _to
    0,                                       // <- _wei
    registry.update.getData(new_ddo_string), // <- _calldata (using web3's #getData method)
    {
      from: eth.accounts[0],
      gas: 300000
    }
  );

// returns pending transaction hash:
"0xe19654a9b57761138357b6f947d46c66dce117ca8d941c1534ac808bde59d5a7"
```





## Verify a Consent DID

```javascript
// Call the registry's `verify` method (creating a transaction is not required):
> registry.verify("0x3268f0391c1b0b3201fb01648834f22dc2dd3c6f");

// returns the latest DDO string:
"{\"@key\":\"value\"}"

```





## Revoke a DDO

```javascript
// Forward a `revoke` call via the Consent DID contract:
> revoke_txhash = did.forward(
    registry.address,          // <- _to
    0,                         // <- _wei
    registry.revoke.getData(), // <- _calldata (using web3's #getData method)
    {
      from: eth.accounts[0],
      gas: 300000
    }
  );

// returns a pending transaction hash:
"0x433fb6c9476248e2068bbaf4cbc01d9e73600bd35cd8333511e7e6505f3b58c9"
```
