// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MultiSigWallet} from "./MultiSig-Wallet.sol";

contract MultiSigWalletFactory {
    event WalletCreated(address indexed walletAddress, address[] owners, uint required);

    address[] public deployedWallets;
    mapping(address => bool) public isWallet;

    function createWallet(
        address[] memory _owners,
        uint _required
    ) external returns (address) {
        MultiSigWallet wallet = new MultiSigWallet(_owners, _required);
        
        deployedWallets.push(address(wallet));
        isWallet[address(wallet)] = true;

        emit WalletCreated(address(wallet), _owners, _required);
        return address(wallet);
    }

    function getDeployedWallets() external view returns (address[] memory) {
        return deployedWallets;
    }

    function getWalletCount() external view returns (uint) {
        return deployedWallets.length;
    }

    function isDeployedWallet(address _wallet) external view returns (bool) {
        return isWallet[_wallet];
    }
}
