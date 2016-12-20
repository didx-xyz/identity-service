# Ethereum Identity Service

The Ethereum Identity Service smart contract stores registered DIDs and matching DDO entries. It creates new instances of Consent DID smart contracts on behalf of users.

The Consent DID smart contract instance acts as a persistent and immutable identifier, fully under control of the identity owner. These smart contracts can be controlled by simple keypairs, or more complex guardian keypairs or M-of-N controlled contracts.

[Read the current Consent DID Method Specification here.](/docs/did-method-spec.md)

## Documentation

* [Running Unit Tests](/docs/testing.md)
* [Developer notes](/docs/usage.md)
