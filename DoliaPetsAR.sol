// contracts/DungeonsAndDragonsCharacter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DoliaPetsAR is ERC721, VRFConsumerBase, Ownable {
    using SafeMath for uint256;
    using Strings for string;

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public VRFCoordinator;
    address public LinkToken;
   

    //Character stats
    struct Character {
        uint256 cuteness;
        uint256 strength;
        uint256 luckiness;
        uint256 beauty;
        uint256 laziness;
        uint256 cleverness; 
        uint256 level;
        string name;
    }

    //list of characters
    Character[] public characters;

    mapping(bytes32 => string) requestToCharacterName;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Polygon (Matic) Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB 
     * Key Hash: 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
     */
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("DoliaPetsAR", "DPAR")
    {   
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    //random number request from VRF
    function requestNewRandomCharacter(
        string memory name
    ) public returns (bytes32) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToCharacterName[requestId] = name;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }

    //token URI
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        uint256 newId = characters.length;
        uint256 cuteness = (randomNumber % 100);
        uint256 strength = ((randomNumber % 10000) / 100 );
        uint256 luckiness = ((randomNumber % 1000000) / 10000 );
        uint256 beauty = ((randomNumber % 100000000) / 1000000 );
        uint256 laziness = ((randomNumber % 10000000000) / 100000000 );
        uint256 cleverness = ((randomNumber % 1000000000000) / 10000000000);
        uint256 level = 0;

        characters.push(
            Character(
                cuteness,
                strength,
                luckiness,
                beauty,
                laziness,
                cleverness,
                level,
                requestToCharacterName[requestId]
            )
        );
        _safeMint(requestToSender[requestId], newId);
    }

    function getLevel(uint256 tokenId) public view returns (uint256) {
        return sqrt(characters[tokenId].level);
    }

    function getNumberOfCharacters() public view returns (uint256) {
        return characters.length; 
    }

    function getCharacterOverView(uint256 tokenId)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[tokenId].name,
            characters[tokenId].cuteness + characters[tokenId].strength + characters[tokenId].luckiness + characters[tokenId].beauty + characters[tokenId].laziness + characters[tokenId].cleverness,
            getLevel(tokenId),
            characters[tokenId].level
        );
    }

    function getCharacterStats(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            characters[tokenId].cuteness,
            characters[tokenId].strength,
            characters[tokenId].luckiness,
            characters[tokenId].beauty,
            characters[tokenId].laziness,
            characters[tokenId].cleverness,
            characters[tokenId].level
        );
    }

    function sqrt(uint256 x) internal view returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
