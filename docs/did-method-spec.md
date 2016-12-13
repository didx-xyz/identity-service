# Consent Decentralized Identifier Method Specification

As part of https://github.com/WebOfTrustInfo/rebooting-the-web-of-trust-fall2016/blob/master/draft-documents/DID-Spec-Implementers-Draft-01.pdf

This is the DID method specification for Consent's Ethereum smart contract based self-sovereign identity technology.

The Ethereum Identity Service smart contract stores registered DIDs and matching DDO entries. It also contains code that creates new instances of Consent DID smart contracts on behalf of users.

The Consent DID smart contract instance can act as a persistent and immutable relay, fully under control of the identity owner. These smart contracts can be controlled by simple keypairs, or more complex guardian keypairs or M-of-N controlled contracts.

## CONSENT DID SCHEME

The Consent DID scheme is defined as follows:

```
did-identifier: "cnsnt"

idstring:       "0x" + 40 hex (0-9a-f) characters
                (A 20 byte, hex encoded and prefixed ethereum address
                pointing to a Consent DID Smart Contract)

example:        "did:cnsnt:0x123456789abcdef0123456789abcdef012345678"
```

## CONSENT DID OPERATIONS

### Creation

1. Generate a keypair. ("_Controller Keypair_")
2. Create a signed ethereum transaction, calling the "create" function on the Consent Ethereum Identity Service smart contract ("_The DDO Registry_"). This will yield a unique identifier, in the form of an ethereum smart contract address.
3. Create a signed transaction that calls the registry's "update" function with the DDO that needs to be recorded (see: Modification method) — forwarding this call through the Consent DID smart contract that was created in step 2.

> Forwarding this call through the relay establishes proof of control.

### Verification

* Simply call the registry's "verify" function, passing the Consent DID as parameter. It will return a string containing the most recently written JSON-LD encoded DDO in the case of a valid DID, or an empty string in the case of a revoked or non-existant DID.

### Modification

1. Encode a valid ethereum contract call to the registry, with the new DDO as parameter.
2. Create a second transaction, passing the registry's address and the encoded calldata as parameters, and sign the resulting transaction with the controller/owner keypair authorized in the Consent DID smart contract at that time.

> The controller key (ethereum address) can be replaced, rotated, expired, etc. at any time. This functionality is abstracted away from the Consent DID relay and the Consent Ethereum Identity Service.

### Revocation

* A DDO entry can be revoked by doing modification/update call with an empty string as DDO.
