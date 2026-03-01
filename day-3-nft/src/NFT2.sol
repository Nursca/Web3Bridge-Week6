// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract TrueTove is ERC721, ERC721URIStorage {
    using Strings for uint256;

    uint256 private _nextTokenId;
    mapping(uint256 => uint256) public tokenIdToLevels;

    constructor(address initialOwner)
        ERC721("TrueTove", "TLove")
    {}

    function mint() external {
        _nextTokenId++;
        uint256 newItemId = _nextTokenId;
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


function generateCharacter(uint256 tokenId) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">True Love NFT</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">Level: ', Strings.toString(tokenIdToLevels[tokenId]), '</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,", 
                Base64.encode(svg)
            )
        );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "True Love NFT #', tokenId.toString(), '",',
                '"description": "This is my on-chain NFT",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,", 
                Base64.encode(dataURI)
            )
        );
    }

}
