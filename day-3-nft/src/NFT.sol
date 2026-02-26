// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TheCross is ERC721, Ownable {
    uint256 private tokenId;
    mapping (uint256 => string) private s_tokenURI;

    constructor(address initialOwner)ERC721("The Cross", "TCS")Ownable(initialOwner){
        tokenId = 0;

    }

    function safeMint(address to, string memory tokenURI) public onlyOwner {
        s_tokenURI[tokenId] = tokenURI;
        _safeMint(to, tokenId);
        tokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenURI[tokenId];
        
    }
}
