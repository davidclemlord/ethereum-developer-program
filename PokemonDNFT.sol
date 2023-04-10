// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.2/utils/Counters.sol";

// AutomationCompatible.sol imports the functions from both ./AutomationBase.sol and
// ./interfaces/AutomationCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract PokemonDNFT is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    enum Status{
        First,
        Second,
        Third
    }
    uint public immutable interval;
    uint public lastTimeStamp;
    mapping(uint256 => Status) nftStatus;
    string[] IpfsUri= [
        "https://gateway.pinata.cloud/ipfs/QmVqd8cTRVKDehky6rz4fyNB5FWm8Dwbqk78yv96UXjfFk/state_0.json",
        "https://gateway.pinata.cloud/ipfs/QmVqd8cTRVKDehky6rz4fyNB5FWm8Dwbqk78yv96UXjfFk/state_1.json",
        "https://gateway.pinata.cloud/ipfs/QmVqd8cTRVKDehky6rz4fyNB5FWm8Dwbqk78yv96UXjfFk/state_2.json"
    ];
    constructor(uint _interval) ERC721("PokemonDNFT", "PDNFT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }
    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if((block.timestamp -lastTimeStamp) > interval){
            updateAllNFTs();
        }
    }
    function updateAllNFTs() public{
        uint counter = _tokenIdCounter.current();
        for(uint i = 0; i < counter; ++i){
            updateStatus(i);
        }
    }
    function safeMint(address to) public{
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        nftStatus[tokenId] = Status.First;
        //_setTokenURI(tokenId, uri);
    }
    function updateStatus(uint256 _tokenId) public{
        //obtener el estado del nft
        uint256 currentStatus = getStatus(_tokenId);
        if(currentStatus == 0){
            nftStatus[_tokenId] = Status.Second;
        }
        else if(currentStatus == 1){
            nftStatus[_tokenId] = Status.Third;
        }
        else nftStatus[_tokenId] = Status.First;
    }
    function getStatus(uint256 _tokenId) public view returns(uint256){
        Status statusIndex = nftStatus[_tokenId];
        return uint(statusIndex);
    }
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function getUriByLevel(uint256 _tokenId) public view returns(string memory){
        Status statusIndex = nftStatus[_tokenId];
        return IpfsUri[uint256(statusIndex)];
    }
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return getUriByLevel(tokenId);
    }
}
