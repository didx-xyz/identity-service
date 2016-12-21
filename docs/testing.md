# Testing the Consent Identity Service

We make use of the [Dapple VM test harness](https://github.com/nexusdev/dapple) to run basic unit tests on the [registry](../src/sol/didm-registry.sol) and [did contracts](../src/sol/cnsnt-did.sol).

## Installation

```bash
$ npm install -g dapple solc
```

## Running

```bash
$ npm test
```

> Please note that these tests take 2-3 minutes to finish — it might seem like the tests hang on the compilation step. The order in which the tests run aren't guaranteed.

It should return the following text:

```bash
> consent-ethereum-identity-service@0.2.0 test
> npm run --silent test:contracts

Testing...
No local solc found. Switching over to JS compiler...

**CDIDChangeOwnerTest**
  test fail on replaced owner
  Passed!

  test fail on unauthorized owner
  Passed!

  test pass on serially changing owner
  Passed!

  test pass on changing owner
  Passed!

**CDIDForwardTest**
  test forward with zero wei and calldata
  | Chirp
  | Chirp
  Passed!

  test forward with zero wei
  | ZeroWei
  | ZeroWei
  Passed!

  test forward with zero wei and invalid calldata
  | ZeroWei
  | ZeroWei
  Passed!

**CDIDFundedForwardTest**
  test pass forward ten wei
  | TenWei
  | TenWei
  Passed!

  test assert balance
  | consent did pre transfer: 100
  | test canary pre transfer: 0
  | TenWei
  | consent did post transfer: 90
  | test canary post transfer: 10
  Passed!

  test did balance
  | log_uint
  |   val: 100
  Passed!

**DIDMCreateTest**
  test created did event
  | created
  |   did: 0x8896b173b0dbd92c7536b0906b4b228848e3043b
  | created
  |   did: 0x8896b173b0dbd92c7536b0906b4b228848e3043b
  Passed!

  test created valid did instance
  | created
  |   did: 0xc5a4e3d06cb8adbd25ff6e8449de9bda88430142
  Passed!

  test create did address
  | created
  |   did: 0x56c162d66200144ef5d9b980385ff252b1f8738f
  | log_address
  |   val: 0x56c162d66200144ef5d9b980385ff252b1f8738f
  Passed!

**DIDMRevokeTest**
  test throw unregistered revoke
  Passed!

  test revoke call effect
  | LogDDO
  |   _ddo:
  | LogDDO
  |   _ddo:
  Passed!

  test revoke call
  Passed!

**DIDMUpdateTest**
  test throw unregistered update
  Passed!

  test fail expecting wrong ddo
  | LogDDO
  |   _ddo: test_ddo
  | LogDDO
  |   _ddo: wrong_test_ddo
  Passed!

  test change ddo
  | LogDDO
  |   _ddo: updated_test_ddo
  | LogDDO
  |   _ddo: updated_test_ddo
  Passed!

  test ddo exists
  | LogDDO
  |   _ddo: test_ddo
  | LogDDO
  |   _ddo: test_ddo
  Passed!

**Summary**
  Passed all 20 tests!

```
