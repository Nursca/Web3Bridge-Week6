// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "../contracts/UseSwap.sol";

contract UseSwapTest is Test {
    IUniswapV2Pair uni;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address lisk = 0x6033F7f88332B8db6ad452B7C6D5bB643990aE3f;
    address usdcHolder = 0x28C6c06298d514Db089934071355E5743bf21d60;

    function setUp() public {
        uni= IUniswapV2Pair(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        useSwap = new UseSwap();
    }

    function testSwapExactTokensForTokens() public {
        createSelectFork('https://eth-mainnet.g.alchemy.com/v2/jpKgJxDjxr_MljPwerRicmTkrGNWBWPz');
        
        address[] memory  i = new address[](2);
        i[0] = usdc;
        i[1] = lisk;
        
        prank(usdcHolder);
        ui.swapExactTokensForTokens(
            1000e6,
            0,
            [usdc, lisk],
            address(0xbeef),
            block.timestamp + 1000
        );
    }
}