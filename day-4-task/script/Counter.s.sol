// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSig-Wallet.sol";

contract MultiSigWalletScript is Script {
    MultiSigWallet public wallet;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wallet = new MultiSigWallet(new address[](0), 3);

        vm.stopBroadcast();
    }
}
