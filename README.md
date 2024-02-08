# `PythRebase`

> Denominate one Pyth feed in terms of another, eg. ETH/USD and USDT/USD to get ETH/USDT

## Documentation

The contract provides the `getPrice` method with three overloads.

```sol
interface IPythRebase {
    // Defaults to 18 decimals (expo = -18) and in terms of USDT. The `id` feed must be
    // denominated in USD for the conversion to be valid.
    function getPrice(bytes32 id) returns (int256);
    // This just applies the defualt of 18 decimals, but allows you to do e.g. ETH/USD and AVAX/USD
    // to get ETH/AVAX conversion rate, or USDT/USD and ETH/USD to get USDT/ETH
    function getPrice(bytes32 numerator, bytes32 denominator) returns (int256);
    // This gives you full control. Note that expo must be <= 0
    function getPrice(bytes32 numerator, bytes32 denominator, int32 expo) returns (int256);
}
```

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
$ forge script script/PythRebase.s.sol:PythRebaseScript --rpc-url mainnet --private-key <your_private_key>
```

## License

[MIT](LICENSE)
