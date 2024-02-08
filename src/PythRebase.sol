// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPyth} from "pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "pyth-sdk-solidity/PythStructs.sol";
import "./PriceFeedIDs.sol" as PriceFeedIDs;
import {console2} from "forge-std/console2.sol";

address constant PYTH_GNOSIS_MAINNET = 0x2880aB155794e7179c9eE2e38200202908C17B43;

int192 constant INT192_MAX = 2 ** 191 - 1;

error InvalidPair();
error InvalidExpo();

contract PythRebase {
    IPyth immutable pyth;

    constructor(address _pyth) {
        pyth = IPyth(_pyth);
    }

    /// @notice Get the price of a pair of assets
    /// @param numerator The numerator feed id, e.g. ETH/USD
    /// @param denominator The denominator feed id, e.g. USDT/USD
    /// @param expo The exponent to return the price in
    /// @return The price of the pair of assets, e.g. ETH/USDT
    function getPrice(bytes32 numerator, bytes32 denominator, int32 expo) public view returns (int256) {
        if (numerator == denominator) revert InvalidPair();
        if (expo > 0) revert InvalidExpo();

        PythStructs.Price memory p0 = pyth.getPrice(numerator);
        PythStructs.Price memory p1 = pyth.getPrice(denominator);

        if (p0.expo > 0) revert InvalidExpo();
        if (p1.expo > 0) revert InvalidExpo();

        int192 expo0 = INT192_MAX / int192(uint192(10) ** uint192(uint32(-p0.expo)));
        int192 expo2 = INT192_MAX / int192(uint192(10) ** uint192(uint32(-expo - p1.expo)));

        int256 price = ((int256(p0.price) * expo0) / int256(p1.price)) / expo2;

        return price;
    }

    /// @notice Get the price of a pair of assets with a default exponent of -18
    /// @param numerator The numerator feed id, e.g. ETH/USD
    /// @param denominator The denominator feed id, e.g. USDT/USD
    /// @return The price of the pair of assets, e.g. ETH/USDT
    function getPrice(bytes32 numerator, bytes32 denominator) public view returns (int256) {
        return getPrice(numerator, denominator, -18);
    }

    /// @notice Get the price of a single asset in terms of USDT
    /// @param id The feed id of the asset, e.g. ETH/USD
    /// @return The price of the asset in terms of USDT and to 18 decimal places, e.g. ETH/USDT
    function getPrice(bytes32 id) public view returns (int256) {
        return getPrice(id, PriceFeedIDs.CRYPTO_USDT_USD);
    }
}
