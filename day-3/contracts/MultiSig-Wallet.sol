// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract MultiSigWallet {
    /**address owner
     * address[] signers
     * uint256 quorum
     * uint256 
     */

    event Deposit (address indexed sender, uint indexed amount);
    event Submit (uint indexed txId);
    event Approve (address indexed owner, uint indexed txId);
    event Revoke (address indexed owner, uint indexed txId);
    event Execute (uint indexed txId);

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed; 
    }

    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (uint => mapping (address => bool)) public approved;
    uint public required;

    Transaction[] public transactions;

    modifier onlyOwner {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx does not  exists");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "approved tx");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "executed tx");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid no of owners");
        
    
        for (uint i; i < owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "address zero can't be owner");
            require(!isOwner[owner], "existing owner");

            isOwner[owner] = true;
            owners.push(owner);
            
        }
        _required = required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));

        emit Submit(transactions.length -1);
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] =true;
        emit Approve(msg.sender, _txId);
    }

    function getApprovalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            } 
        }
    }

    function execute(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(getApprovalCount(_txId) >= required, "need more no of approvals required");

        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit Execute(_txId);

    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approve");
        approved[_txId][msg.sender] = false;

        emit Revoke(msg.sender, _txId);
        
    }
}