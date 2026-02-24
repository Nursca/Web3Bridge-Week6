// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import{NurscaToken} from "./ERC20.sol";

contract PropertyManagement is NurscaToken {
    error NOT_OWNER();
    error NOT_FOR_SALE();
    error ALREADY_SOLD();
    error INSUFFICIENT_FUNDS();
    error INVALID_PROPERTY();

    // string propertyName;
    // string propertyLocation;
    // uint256 propertyId;
    // uint256 propertyPrice;
    // uint256 timeSold;
    // bool forSale;
    // bool isSold;
    address public owner;

    Property[] public properties;
    uint256 property_id;

    event PropertyAdded (uint256 indexed id, string  name, string  location, uint256 _price);
    event PropertyRemoved (uint256 indexed id);
    event PropertyPurchased(uint256 indexed id, address indexed buyer, uint256 price, uint256 time);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NOT_OWNER();
        }
        _;
    }

    struct Property {
        string name;
        string location;
        bool isSold;
        bool forSale;
        uint256 id;
        uint256 price;
        uint256 timeSold; 
        address propertyOwner;

    }

    constructor() NurscaToken (100000 * 10 ** uint8(decimals())) {
        owner = msg.sender;
        
    }

    function createProperty(string memory _name, string memory _location, uint256 _price) external onlyOwner returns(uint256, string memory, string memory, uint256) {
        property_id = property_id +1;

        Property memory newProperty = Property({
            name: _name,
            location: _location,
            forSale: true,
            isSold: false,
            id: property_id,
            price: _price,
            timeSold: 0,
            propertyOwner: owner
        });

        properties.push(newProperty);

        emit PropertyAdded(property_id, _name, _location, _price);
        return (property_id, _name, _location, _price);

        
    }

    function removeProperty (uint256) external onlyOwner {
        Property memory property = properties[property_id -1];
        if (property.isSold == true) {
            revert ALREADY_SOLD();
        }
        for (uint256 i; i < properties.length; i++) {
            if (properties[i].id == property_id) {
                if (properties[i].isSold) revert ALREADY_SOLD(); 
                properties[i] = properties [properties.length -1];
                properties.pop();
                emit PropertyRemoved(property_id);
                return;
            }  
        }

       
    }

    function purchaseProperty(uint256) external {
        for (uint256 i; i < properties.length; i++) {
            if (properties[i].id == property_id) {
                Property storage property = properties[property_id -1];

                if (!property.forSale) {
                    revert NOT_FOR_SALE();
                }

                if (property.isSold) {
                    revert ALREADY_SOLD();
                }

                if (balanceOf(msg.sender) < property.price) {
                    revert INSUFFICIENT_FUNDS();
                }

                bool success = transferFrom(msg.sender, property.propertyOwner, property.price);
                require(success, "Transfer failed");

                property.propertyOwner = msg.sender;
                property.isSold = true;
                property.forSale = false;
                property.timeSold = block.timestamp;

                emit PropertyPurchased(property_id, msg.sender, property.price, block.timestamp);

                return;
            }
        }
        
        revert INVALID_PROPERTY();
        
    }

    function getAllProperties() external view returns (Property[] memory) {
        return properties;
    }

}
