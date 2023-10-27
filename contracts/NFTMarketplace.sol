//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketPlace is ERC721URIStorage {
    address payable owner ;
    using Counters for Counters.Counter;
    Counters.Counter public token_ID;
    Counters.Counter public itemsSold_;
    uint256 listPrice = 0.01 ether;
    constructor() ERC721("NFTMarketPlace","NFTM"){
        owner = payable(msg.sender);
    }
   struct ListTokens{
       uint256 tokenId;
       address payable  owner;
       address payable seller;
       uint256 price;
       bool currentlyOpen;
   }
   mapping (uint256 => ListTokens) public IdNOTokens;

   function UpdateListPrice(uint256 _listPrice) public payable{
    require(owner ==msg.sender,"you are not the owner");
    listPrice = _listPrice;
   } 

   function getListPrice() public view returns(uint256){
    return listPrice;
   }

   function getLatesttoListedTokens() public view returns(ListTokens memory){
       uint256 currentTokenId = token_ID.current();
       return IdNOTokens[currentTokenId];
   }

   function getListedTokenForid(uint256 TOkId) public view  returns(ListTokens memory){
       return IdNOTokens[TOkId];
   }

   function getCurrentToken() public view returns(uint256){
     return token_ID.current();
   } 

function CreateToken(string memory tokenURI, uint256 price) public payable returns(uint){
    token_ID.increment();
    uint256 newTokenId = token_ID.current();
     _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId , tokenURI);
     createListedToken(newTokenId, price);
     return newTokenId;
}
   
   function createListedToken(uint256 tokenId , uint256 price) public{
        IdNOTokens[tokenId] = ListTokens(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );
        _transfer(msg.sender,address(this),tokenId);
   }

   function getAllNFTs() public view returns(ListTokens[] memory){
    uint nftcount = token_ID.current();
    ListTokens[] memory tokens = new ListTokens[](nftcount);
    uint currentIndex = 0;
    uint currentId;
    for(uint i=0;i<nftcount ; i++){
      currentId = i++;
      ListTokens storage currentItem = IdNOTokens[currentId];
      tokens[currentIndex] = currentItem;
      currentIndex+=1;
    }
    return tokens;
   }

   function getMyNFts() public view returns(ListTokens[] memory){
    uint totalItemCount = token_ID.current();
    uint itemCount = 0;
    uint currentIndex = 0;
    uint currentId;
for(uint i=0 ; i<totalItemCount; i++){
    if(IdNOTokens[i++].owner == msg.sender || IdNOTokens[i++].seller == msg.sender){
        itemCount += 1;
    }
}
ListTokens[] memory items = new ListTokens[](itemCount);
for(uint i=0 ; i<totalItemCount; i++){
    if(IdNOTokens[i++].owner == msg.sender || IdNOTokens[i++].seller == msg.sender){
        currentId = i+1;
                ListTokens storage currentItem = IdNOTokens[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
    }
}
return items; 
   }

   function executeSale(uint tokenid) public payable{
      uint price = IdNOTokens[tokenid].price;
     address seller = IdNOTokens[tokenid].seller; 
     require(msg.value ==price , "Please transfer the enough amount");
     IdNOTokens[tokenid].currentlyOpen = true;
     IdNOTokens[tokenid].seller = payable(msg.sender);
     itemsSold_.increment();
     _transfer(address(this), msg.sender, tokenid);
     approve(address(this), tokenid);
     payable(owner).transfer(listPrice);
     payable(seller).transfer(msg.value);
   }
}