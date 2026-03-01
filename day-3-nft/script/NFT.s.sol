// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TheCross} from "../src/NFT.sol";

contract NFTScript is Script {
    TheCross public nft;

    function setUp() public {}

    function run() public {
        string memory tokenURI = "https://pink-rational-asp-503.mypinata.cloud/ipfs/bafybeidsfq6jdn6t4h2b7tdcixl7g3yn37heqtydwcy6f52ehjoapv7aem";
        vm.startBroadcast();

        nft = new TheCross(msg.sender);
        nft.safeMint(msg.sender, tokenURI);

        vm.stopBroadcast();
    }
}