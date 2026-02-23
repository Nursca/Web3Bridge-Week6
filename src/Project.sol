// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import{NurscaToken} from "./ERC20.sol";

contract PropertyManagement is NurscaToken {
    error NOT_OWNER();
    error NOT_FOR_SALE();
    error ALREADY_SOLD();
    error INSUFFICIENT_FUNDS();

    string propertyName;
    string propertyLocation;
    uint256 propertyId;
    uint256 propertyPrice;
    uint256 timeSold;
    bool forSale;
    bool isSold;
    address propertyOwner;

    Property[] public properties;
    uint256 property_id;

    event PropertyAdded (string )

    modifier onlyOwner() {
        if (onlyOwner != msg.sender) {
            revert NOT_OWNER;
        }
        _;
    }

    struct Property {
        string name;
        string location;
        uint256 id;
        uint256 price;
        uint256 timeSold;
        bool forSale;
        bool isSold;
        address propertyOwner;

    }

    constructor() NurscaToken (100000 * (10 ** uint8(decimals))) {
        propertyOwner = msg.sender;
        
    }

    function createProperty(string memory _name, string memory _location, uint256 _price) external onlyOwner returns(string memory, string memory, uint256) {
        uint256 id = property_id +1

        Property memory newProperty = Property({
            id: property_id, 
            name: _name;
            location: _location;
            price: _price;
            forSale: true,
            isSold: false
            address: msg.sender
        });
        properties.push(newProperty);
    }

    function removeProperty (uint8 property_id) external onlyOwner {
        for (uint8 i; i < properties.length; i++) {
            if (properties[i].id == _id) {
                properties[i] = properties [properties.length -1];
                properties.pop();
            }
        }
    }


}
