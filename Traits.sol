// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PetsItems is ERC1155 {
    uint256 public constant GOLD_CHAIN = 0;
    uint256 public constant BASKETBALL = 1;
    uint256 public constant TIE = 2;
    uint256 public constant CYLINDER_HAT = 3;

    constructor() ERC1155("https://ipfs.io/ipfs/.../{id}.json") {
        _mint(msg.sender, GOLD_CHAIN, 10**2, "");
        _mint(msg.sender, BASKETBALL, 10**3, "");
        _mint(msg.sender, TIE, 10**3, "");
        _mint(msg.sender, CYLINDER_HAT, 10**4, "");
    }

    function uri(uint256 _tokenid) override public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/.../",
                Strings.toString(_tokenid),".json"
            )
        );
    }
}




