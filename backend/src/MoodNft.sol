// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    mapping(uint256 => Mood) private s_tokenIdToMood;

    enum Mood {
        HAPPY,
        SAD
    }

    /*
     * This is the constructor which will set the following variables
     */
    constructor(string memory sadSvg, string memory happySvg) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvg;
        s_happySvgImageUri = happySvg;
    }

    /*
     * This function mint the NFT and set the mood to HAPPY
     * set the token counter +1
     */
    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }


    /**
     * this function flips the mood of the nft
     * @param tokenId the id of the token
     */
    function flipMood(uint256 tokenId) public {
        // only the owner of the token can flip the mood
        // fetch the owner of the token
        address owner = ownerOf(tokenId);
        
        // check if the caller is the owner of the token
        _checkAuthorized(owner, msg.sender, tokenId);

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns(string memory){
        return "data:application/json;base64,";
    }

    /**
     * this function returns the token uri
     */
    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = s_happySvgImageUri;
        } else {
            imageUri = s_sadSvgImageUri;
        }

        return 
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        abi.encodePacked(
                            '{"name": "', 
                                name(),
                                '", "description": "An NFT that reflects the owners mood.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": "', 
                                imageUri, 
                            '"}'
                        )
                    )
                )
            );
    }
}