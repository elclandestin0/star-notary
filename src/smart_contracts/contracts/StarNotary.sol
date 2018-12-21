pragma solidity ^0.4.23;

import './ERC721Token.sol';

contract StarNotary is ERC721Token { 

    struct Star { 
        string name; 
        string starStory; 
        string ra; 
        string dec;
        string mag;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => Star) public starIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    function createStar(string _name, string _starStory, string _ra, string _dec, string _mag, uint256 _tokenId) public {
        // create new star 
        Star memory newStar = Star(_name, _starStory, _ra, _dec, _mag);

        // verify star uniqueness
        uint256 _starId = keccak256(_ra, _dec, _mag);

        require(starIdToStarInfo[_starId] != newStar, "starId not unique");

        // map new star by starId
        starIdToStarInfo[_starId] = newStar;

        // map new star by tokenId
        tokenIdToStarInfo[_tokenId] = newStar;

        // mint new star
        this.mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);

        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }
}