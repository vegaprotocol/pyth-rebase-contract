// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {PythRebase, PYTH_GNOSIS_MAINNET} from "../src/PythRebase.sol";
import "../src/PriceFeedIDs.sol" as PriceFeedIDs;

import {MockPyth} from "pyth-sdk-solidity/MockPyth.sol";

contract PythRebaseTest is Test {
    PythRebase public pythRebase;

    function setUp() public {
        uint256 forkId = vm.createFork("gnosis_mainnet");
        vm.selectFork(forkId);
        pythRebase = new PythRebase(PYTH_GNOSIS_MAINNET);
    }

    function testGetPrice() public {
        int256 price0 = pythRebase.getPrice(PriceFeedIDs.CRYPTO_ETH_USD, PriceFeedIDs.CRYPTO_USDT_USD, -18);
        int256 price1 = pythRebase.getPrice(PriceFeedIDs.CRYPTO_ETH_USD, PriceFeedIDs.CRYPTO_USDT_USD);
        int256 price2 = pythRebase.getPrice(PriceFeedIDs.CRYPTO_ETH_USD);

        assertTrue(price0 > 0, "Price should be greater than 0");
        assertEq(price0, price1, "Price0 should be equal to price1");
        assertEq(price0, price2, "Price0 should be equal to price2");
    }
}

contract PythRebaseMockTest is Test {
    PythRebase public pythRebase;
    MockPyth public pyth;

    function setUp() public {
        pyth = new MockPyth(100, 100);
        pythRebase = new PythRebase(address(pyth));
    }

    function testUnequalExpo() public {
        bytes[] memory updateData = new bytes[](2);

        bytes32 id1 = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 id2 = 0x0000000000000000000000000000000000000000000000000000000000000002;

        updateData[0] = pyth.createPriceFeedUpdateData(id1, 100, 0, -2, 100, 0, uint64(block.timestamp));

        updateData[1] = pyth.createPriceFeedUpdateData(id2, 10000, 0, -4, 100, 0, uint64(block.timestamp));

        pyth.updatePriceFeeds{value: 200}(updateData);

        int256 price = pythRebase.getPrice(id1, id2, -4);
        assertEq(price, 10000, "Price should be 10000");

        int256 price2 = pythRebase.getPrice(id2, id1, -4);
        assertEq(price2, 10000, "Price2 should be 10000");

        int256 price3 = pythRebase.getPrice(id1, id2, -2);
        assertEq(price3, 100, "Price3 should be 100");

        int256 price4 = pythRebase.getPrice(id2, id1, -2);
        assertEq(price4, 100, "Price4 should be 100");

        int256 price5 = pythRebase.getPrice(id1, id2);
        assertEq(price5, 1e18, "Price5 should be 100");

        int256 price6 = pythRebase.getPrice(id2, id1);
        assertEq(price6, 1e18, "Price6 should be 100");

        int256 price7 = pythRebase.getPrice(id1, id2, 0);
        assertEq(price7, 1, "Price7 should be 1");

        int256 price8 = pythRebase.getPrice(id2, id1, -10);
        assertEq(price8, 1e10, "Price8 should be 1e10");
    }

    function testEqualExpo() public {
        bytes[] memory updateData = new bytes[](2);

        bytes32 id1 = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 id2 = 0x0000000000000000000000000000000000000000000000000000000000000002;

        updateData[0] = pyth.createPriceFeedUpdateData(id1, 200000000, 0, -8, 100, 0, uint64(block.timestamp));

        updateData[1] = pyth.createPriceFeedUpdateData(id2, 400000000, 0, -8, 100, 0, uint64(block.timestamp));

        pyth.updatePriceFeeds{value: 200}(updateData);

        int256 price = pythRebase.getPrice(id1, id2, -8);
        assertEq(price, 50000000, "Price should be 50000000");

        int256 price2 = pythRebase.getPrice(id2, id1, -8);
        assertEq(price2, 200000000, "Price2 should be 200000000");

        int256 price3 = pythRebase.getPrice(id1, id2);
        assertEq(price3, 5e17, "Price3 should be 5e17");

        int256 price4 = pythRebase.getPrice(id2, id1);
        assertEq(price4, 2e18, "Price4 should be 2e18");

        int256 price5 = pythRebase.getPrice(id1, id2, -1);
        assertEq(price5, 5, "Price5 should be 5");

        int256 price6 = pythRebase.getPrice(id2, id1, 0);
        assertEq(price6, 2, "Price6 should be 2");
    }
}
