// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {MultiSigWalletFactory} from "../src/MultiSigWalletFactory.sol";
import {MultiSigWallet} from "../src/MultiSig-Wallet.sol";

contract MultiSigWalletFactoryTest is Test {
    MultiSigWalletFactory public multisigwalletfactory;
    MultiSigWallet public multisigwallet;
    
    address[] public owners;
    address owner1 = vm.addr(1);
    address owner2 = vm.addr(2);
    address owner3 = vm.addr(3);
    address owner4 = vm.addr(4);
    address owner5 = vm.addr(5);

    address nonOwner = address(0x00000000000000000000000000000000);
    uint requiredApprovals = 3;

    event WalletCreated(address indexed walletAddress, address[] owners, uint required);

    function setUp() public {
        multisigwalletfactory = new MultiSigWalletFactory();
        
        owners.push(vm.addr(1));
        owners.push(vm.addr(2));
        owners.push(vm.addr(3));
        owners.push(vm.addr(4));
        owners.push(vm.addr(5));
    }

    function test_CreateWallet() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        
        assertTrue(walletAddress != address(0), "Wallet address should not be zero");
        assertTrue(multisigwalletfactory.isWallet(walletAddress), "Wallet not found");
        // assertEq(multisigwalletfactory.getWalletCount(), 1, "Wallet count should be 1");
    }

    // function test_CreateMultipleWallets() public {
    //     address wallet1 = multisigwalletfactory.createWallet(owners, 2);
    //     address wallet2 = multisigwalletfactory.createWallet(owners, 3);
        
    //     assertEq(multisigwalletfactory.getWalletCount(), 2, "Should have 2 wallets");
    //     assertTrue(multisigwalletfactory.isWallet(wallet1), "First wallet should be tracked");
    //     assertTrue(multisigwalletfactory.isWallet(wallet2), "Second wallet should be tracked");
    // }

    // function test_GetDeployedWallets() public {
    //     address wallet1 = multisigwalletfactory.createWallet(owners, 2);
    //     address wallet2 = multisigwalletfactory.createWallet(owners, 3);
        
    //     address[] memory deployedWallets = multisigwalletfactory.getDeployedWallets();
        
    //     assertEq(deployedWallets.length, 2, "Should have 2 deployed wallets");
    //     assertEq(deployedWallets[0], wallet1, "First wallet address mismatch");
    //     assertEq(deployedWallets[1], wallet2, "Second wallet address mismatch");
    // }

    // function test_NonDeployedWalletNotTracked() public {
    //     address fakeWallet = address(0xDEADBEEF);
    //     assertFalse(multisigwalletfactory.isWallet(fakeWallet), "Fake wallet should not be tracked");
    // }

    function test_WalletOwnersSet() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        assertEq(deployedWallet.required(), requiredApprovals, "Number of required approvals not reached");
        
        for (uint i = 0; i < owners.length; i++) {
            assertTrue(deployedWallet.isOwner(owners[i]), "You are not an Owner");
        }
    }

    function test_NonOwnerNotSet() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        assertFalse(deployedWallet.isOwner(nonOwner), "Can't be a owner");
    }

    function test_DepositToWallet() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        uint depositAmount = 10 ether;
        vm.deal(address(this), depositAmount);
        
        (bool success, ) = walletAddress.call{value: depositAmount}("");
        assertTrue(success, "Deposit should succeed");
        assertEq(walletAddress.balance, depositAmount, "Wallet balance mismatch");
    }

    function test_SubmitTransaction() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        address payable recipient = payable(address(0x5));
        uint transferAmount = 1 ether;
        
        vm.prank(owner1);
        deployedWallet.submit(recipient, transferAmount, "");
    }

    function test_ApproveTransaction() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        address payable recipient = payable(address(0x5));
        uint transferAmount = 1 ether;
        
        // Fund the wallet
        vm.deal(walletAddress, 10 ether);
        
        // Submit transaction
        vm.prank(owner1);
        deployedWallet.submit(recipient, transferAmount, "");
        
        // Approve from owner1
        vm.prank(owner1);
        deployedWallet.approve(0);
        
        // Approve from owner2
        vm.prank(owner2);
        deployedWallet.approve(0);

        // Approve from owner3
        vm.prank(owner3);
        deployedWallet.approve(0);
        
        // Execute transaction
        vm.prank(owner4);
        deployedWallet.execute(0);
        
        assertEq(recipient.balance, transferAmount, "Recipient should receive funds");
    }

    function test_ExecuteFailsWithInsufficientApprovals() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        address payable recipient = payable(address(0x5));
        uint transferAmount = 1 ether;
        
        vm.deal(walletAddress, 10 ether);
        
        vm.prank(owner1);
        deployedWallet.submit(recipient, transferAmount, "");
        
        // Only approve from one owner
        vm.prank(owner1);
        deployedWallet.approve(0);
        
        // Try to execute with only 1 approval (need 2)
        vm.prank(owner1);
        vm.expectRevert("need more no of approvals required");
        deployedWallet.execute(0);
    }

    function test_RevokeApproval() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        address payable recipient = payable(address(0x5));
        uint transferAmount = 1 ether;
        
        vm.deal(walletAddress, 10 ether);
        
        vm.prank(owner1);
        deployedWallet.submit(recipient, transferAmount, "");
        
        // Approve
        vm.prank(owner1);
        deployedWallet.approve(0);
        
        // Revoke approval
        vm.prank(owner1);
        deployedWallet.revoke(0);
        
        // Revoke should fail now (not approved)
        vm.prank(owner1);
        vm.expectRevert("tx not approve");
        deployedWallet.revoke(0);
    }

    function test_NonOwnerCannotApprove() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        vm.prank(owner1);
        deployedWallet.submit(address(0x5), 1 ether, "");
        
        // Non-owner tries to approve
        vm.prank(nonOwner);
        vm.expectRevert("not owner");
        deployedWallet.approve(0);
    }

    function test_CannotApproveNonExistentTransaction() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        // Try to approve non-existent transaction
        vm.prank(owner1);
        vm.expectRevert("tx does not  exists");
        deployedWallet.approve(99);
    }

    function test_CannotApproveAlreadyApprovedTransaction() public {
        address walletAddress = multisigwalletfactory.createWallet(owners, requiredApprovals);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        vm.prank(owner1);
        deployedWallet.submit(address(0x5), 1 ether, "");
        
        // First approval
        vm.prank(owner1);
        deployedWallet.approve(0);
        
        // Try to approve again
        vm.prank(owner1);
        vm.expectRevert("approved tx");
        deployedWallet.approve(0);
    }

    function test_CompleteMultiSigWorkflow() public {
        // Create wallet through multisigwalletfactory
        address walletAddress = multisigwalletfactory.createWallet(owners, 2);
        MultiSigWallet deployedWallet = MultiSigWallet(payable(walletAddress));
        
        // Fund wallet
        vm.deal(walletAddress, 5 ether);
        
        address payable recipient = payable(address(0xABCD));
        uint amount = 2 ether;
        
        // Submit transaction
        vm.prank(owner1);
        deployedWallet.submit(recipient, amount, "");
        
        // Get approvals from 2 owners
        vm.prank(owner1);
        deployedWallet.approve(0);
        
        vm.prank(owner2);
        deployedWallet.approve(0);
        
        // Execute
        vm.prank(owner3);
        deployedWallet.execute(0);
        
        // Verify
        assertEq(recipient.balance, amount, "Recipient balance incorrect");
        assertEq(walletAddress.balance, 3 ether, "Wallet balance incorrect");
    }
}
