# Ethereum Identity Service

The Ethereum Identity Service smart contract stores registered DIDs and matching DDO entries. It also contains code that creates new instances of Consent DID smart contracts on behalf of users.

The Consent DID smart contract instance can act as a persistent and immutable relay, fully under control of the identity owner. These smart contracts can be controlled by simple keypairs, or more complex guardian keypairs or M-of-N controlled contracts.
