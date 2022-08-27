// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
import {Base64} from "./libraries/Base64.sol";


contract Domains is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

   address payable public owner;
    mapping(uint256 => string) public names;
    mapping(string => string) public records;
    mapping(string => address) public domains;
    
    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

  string public tld;
  // We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.63 42.949a4.382 4.382 0 0 0-4.394 0l-10.081 6.032-6.85 3.934-10.081 6.032a4.382 4.382 0 0 1-4.394 0l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616 4.54 4.54 0 0 1-.608-2.187v-9.31a4.27 4.27 0 0 1 .572-2.208 4.25 4.25 0 0 1 1.625-1.595l7.884-4.59a4.382 4.382 0 0 1 4.394 0l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616 4.54 4.54 0 0 1 .608 2.187v6.032l6.85-4.065v-6.032a4.27 4.27 0 0 0-.572-2.208 4.25 4.25 0 0 0-1.625-1.595L41.456 24.59a4.382 4.382 0 0 0-4.394 0l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595 4.273 4.273 0 0 0-.572 2.208v17.441a4.27 4.27 0 0 0 .572 2.208 4.25 4.25 0 0 0 1.625 1.595l14.864 8.655a4.382 4.382 0 0 0 4.394 0l10.081-5.901 6.85-4.065 10.081-5.901a4.382 4.382 0 0 1 4.394 0l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616 4.54 4.54 0 0 1 .608 2.187v9.311a4.27 4.27 0 0 1-.572 2.208 4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721a4.382 4.382 0 0 1-4.394 0l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616 4.53 4.53 0 0 1-.608-2.187v-6.032l-6.85 4.065v6.032a4.27 4.27 0 0 0 .572 2.208 4.25 4.25 0 0 0 1.625 1.595l14.864 8.655a4.382 4.382 0 0 0 4.394 0l14.864-8.655a4.545 4.545 0 0 0 2.198-3.803V55.538a4.27 4.27 0 0 0-.572-2.208 4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="a" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><svg version="1.0" xmlns="http://www.w3.org/2000/svg" viewBox="0 300 307"><g fill="#000"><path d="M212.9 3.9c-8.3 2.7-15.7 7.3-22.1 13.8C179.9 28.9 175 40.1 175 53.9c0 13.7 5 25.7 15.1 36.6l5.7 6-12.7.1c-12.7.1-22.6 1.9-33.4 6.1-5.6 2.2-19 10.5-24.8 15.4-2.6 2.1-5.2 3.9-5.8 3.9-.7 0-1.1-2.4-1.1-6.3 0-8-3.1-20.3-7.1-28.5-4.5-9.3-14.4-19.4-23.3-23.7-16.3-8-27.9-8.2-43.1-.6-18.8 9.4-31.6 25.5-34.5 43.4-2.4 15 3.8 31.8 15.9 43.7 16.6 16.2 40.8 20.6 60.5 10.9 3.3-1.6 6.1-2.7 6.4-2.5.2.3-.3 2.6-1.2 5.3-6.5 20-3.7 55.5 5.7 72.6 1.9 3.4 3.7 8 4.1 10.3 2.6 17.3 16.4 32.8 36.6 41.2 8.5 3.4 25.3 7.2 32.6 7.2 3.7 0 5.8.7 9.8 3.4 8 5.3 14 6.9 24.3 6.4 14.8-.7 18.3-3.2 45.4-33.4 20.7-23 27.6-32 34.7-46 8.9-17.4 8.4-35.8-1.3-47.1-1.9-2.3-3.5-4.9-3.5-6-.1-8.9-13.3-33.7-24.2-45.4-5.4-5.7-13.6-12.2-17.7-13.8-4.3-1.8-3.9-2.7 1.4-3.4 14.9-2.1 30.3-14.1 37.5-29.3 12.1-25.3 1.4-59.6-22.5-72.1C242.3 2 224.7.1 212.9 3.9zm28.5 3.7C263.5 13.3 278 32.9 278 57c0 14.3-4.5 25.4-14.2 35.3-6 6-16.7 12-23.8 13.2-4.4.7-8.4 4.4-7.4 6.8.3.9 4.1 4.1 8.3 7.1 4.3 3 9.7 7.6 12.1 10.3 9.8 11 21.2 31.5 22.2 39.8.2 2.5 0 3-1.7 2.7-9.9-1.5-12.5-1.3-21.2 1.3-2.1.7-2.3.4-2.3-3.3 0-6.9-2.9-21.1-6.1-29.2-7.6-19.9-25.1-38.3-39.9-42.1-2.8-.7-5-1.8-5-2.4s-2.5-4-5.5-7.5c-3.1-3.6-7.5-10.3-9.8-14.9l-4.2-8.5V54.1c0-11.4.1-11.7 3.9-19.6 6.5-13.2 19.8-24.2 33.2-27.4 6.3-1.5 18.1-1.2 24.8.5zM80.3 64.7c19.7 7.4 30.8 23.5 33.7 49.2.6 5.9 1.3 7.9 3.3 9.9l2.5 2.5-3.3 6.7c-5.5 10.6-6.8 18.1-6.2 35 .5 16.7 2.6 25.6 8.8 38.9 2.1 4.6 3.8 8.5 3.7 8.6-.2.1-2.3.9-4.8 1.8-6.2 2.3-11.4 6.8-14 12.3-1.9 3.9-2.5 4.4-3.6 3.2-2.2-2.1-5.2-11.8-7-22-2-11.2-1.4-33.7 1.1-43.7 1.7-7.1 1.4-9.6-1.6-11.2-1.6-.8-3.6-.4-9.7 2.2-18.1 7.5-38.6 3.8-53.2-9.7-11.1-10.3-16-21.3-16.1-35.8 0-8.4 1-12.6 5.4-21.3 6.9-13.4 25.4-27 40.7-29.7 4.7-.8 13.5.5 20.3 3.1zm94.5 41.1c-2.3 2.7-5.1 7.2-6.2 10-1 2.9-2 5.2-2.3 5.2-.2 0-2.5-1.6-5-3.5s-6.4-4-8.7-4.6c-10-2.7-9.6-2.3-4.7-4.8 5.6-2.9 21.3-7 26.9-7.1h4.4l-4.4 4.8zm34.5-.5c16.6 8.2 31.4 30.2 35.3 52.8 1.6 9.1 1.5 21.7-.1 26.4-.4 1.2.6.6 2.6-1.7 8.5-9.5 22.9-10.4 32-2.1 14.1 12.7 11.1 34.2-8.6 61.7-6.1 8.6-27.4 33.4-28.7 33.5-.4.1 0-1.5.8-3.4 1.6-3.9 1.8-5.5.6-5.5-.4 0-1.5 2.1-2.5 4.6-2.4 6.5-10.1 17.7-14.9 21.9-7.5 6.3-13.1 8.5-22.4 8.5-7.5 0-8.8-.3-16.1-4-4.3-2.1-9.8-5.7-12.2-8-4.4-4-7-4.8-3.6-1 1 1.1 1.5 2.3 1.1 2.7-.3.4-5.1.1-10.5-.5-28.3-3.3-49.9-19.8-55.7-42.3-2-7.7-1.3-13.6 2.1-19.5 3.3-5.6 10.7-9.4 18.2-9.4h5.3l-3.4-4.8c-7.7-10.8-12.7-25-14.5-41.7-1.9-16.9 1.1-32.5 8.4-43.1 8.8-12.7 21.8-17.8 32.1-12.6 3.8 2 12.4 10.3 15.5 15.2 1.6 2.4 1.6 2.1 1.1-5.1-.4-6.7-.1-8.4 2.1-13.1 2.4-5.4 6.7-9.6 11.7-11.7 1.4-.6 6.1-1 10.5-.8 6.5.2 9.1.7 13.8 3z"/><path d="M158.8 161c-3.2 1.9-5 9.2-4.7 18.3.2 4.7.7 8.9 1.1 9.3s5.1.9 10.3 1.2c5.3.3 9.3.8 8.8 1.2-.4.5-4.3 2.3-8.5 4-4.3 1.8-7.8 3.7-7.8 4.2 0 2.6 6.4 16.8 8.9 19.8l2.9 3.5-3.7 3.1c-5 4.4-3.5 5 2.3.9 5.9-4.2 17.2-9 26.3-11.1 6.9-1.6 24.7-1.5 30.2.2 4.9 1.5 1.1-1.4-4.2-3.2-8.3-2.9-25.6-2.4-33.7 1-1.3.5-1.5-.9-1.6-9.6-.1-11.5-1.9-18.3-8.1-30-5.8-11.1-12.9-16-18.5-12.8zm10.1 7.5c7.7 8.8 12.4 22.5 12.5 36.8l.1 9.8-4.8 2.1c-4.7 2-4.8 2-6.2.2-2.5-3.3-6.5-12.4-6.5-14.8 0-1.7 1.1-2.8 5.1-4.7 11.2-5.2 9.5-11.9-3-11.9-7.4 0-8.4-1.2-8-10.2.3-4.3 1-8.2 1.8-9.2 2.2-2.6 5.6-1.9 9 1.9z"/><path d="M211.6 166.9c-6.3 4.2-14 16.9-16.7 27.4-1.8 7.4-.4 6.6 2.7-1.5 5.6-14.3 14.9-25.8 20.9-25.8 1.7 0 1.7-.2.5-1-2.2-1.4-4.2-1.2-7.4.9zm10.1 16.5c-4.9 1.8-9.8 5.5-17.4 13.4-7 7.1-8.5 10.5-2.2 4.8 9.1-8.3 20.3-13.9 26.8-13.4 2.8.2 3.6-.1 3.9-1.6.5-2.3-2.2-4.6-5.2-4.6-1.2.1-3.8.7-5.9 1.4zm-1.4 18.3c-5.3 5.4-5.4 6.4-.3 3.8 2.8-1.4 6.5-6.8 5.8-8.3-.2-.4-2.6 1.7-5.5 4.5zm34.7-.8c-3.9 1.2-8.5 3.8-10 5.6-1.2 1.5-1 1.5 2.6.1 2.1-.9 5.9-2 8.3-2.5l4.4-.9-.6 6.3c-1.8 19.3-13 37.2-30.4 48.5-26.8 17.6-66 17.1-86.6-1-4.6-4.1-9.4-10.7-8.4-11.6.3-.3 3.3-.7 6.6-.7 6.8-.2 6.7-1.7-.2-2.4-6-.7-10.7 1-15.1 5.4-4.8 4.9-4.6 6 .6 2.3 2.2-1.6 4.4-3 4.7-3 .4 0 1.5 1.4 2.5 3.2 5.4 9 15.7 16.8 27.4 20.5 6.7 2.1 8.4 3.2 16.6 10.9 15 14 23.7 16.9 36.3 12.2 11-4.1 18.5-13.7 26.3-33.8 2.2-5.4 4.9-10.2 7.5-13.2 8.3-9.3 14.5-25.6 14.5-38.2v-5.9l5.3.6 5.2.6-4-1.9c-4.1-2-9.1-2.4-13.5-1.1zm-21.2 63.8c-1.2 2.5-1.9 2.8-6.8 3.1-6.3.4-6.1-.2 2-4.6 5.9-3.3 6.9-2.9 4.8 1.5zm-23.4 8.8c-2.1 1.6-5.6 2-6.8.8-.7-.8 7.5-3.3 8.3-2.6.3.2-.4 1-1.5 1.8zm21.1-1.4c1.7 2.6-9.7 14.8-16.9 18-9.2 4-15.9 3.7-24.4-1.2-4.7-2.6-5.2-3.2-4-4.6 2.2-2.7 11.1-6.3 15.6-6.3 4.1 0 4.2.1 3.7 2.7l-.6 2.8 2.1-2.7c2.4-3.1 7.7-6.6 12.9-8.4 4.4-1.6 10.7-1.8 11.6-.3zm-37.5 3.3c0 .3-1.2 1.1-2.7 1.8-1.6.8-3.8 2.1-5.1 2.9-2.5 1.6-4.6.7-7-2.9l-1.4-2.2h8.1c4.4 0 8.1.2 8.1.4z"/><path d="M191.4 219.8c-9.2 3.8-15.4 10.5-15.4 16.5 0 3.3 4.2 8.2 9.4 10.9 5.8 3.1 17.2 3.1 24 0 9.6-4.3 15.6-10.7 15.6-16.4 0-3.9-5.2-9.3-10.7-11.2-6.1-2.1-17.6-2-22.9.2zm22.3 4.1c2.3 1.1 4.9 3.1 5.8 4.4 1.5 2.3 1.5 2.8.1 5.6-2.8 5.3-10.7 10-19.4 11.5-8.4 1.4-19.4-4-19.4-9.6 0-5.1 4.1-9 13.3-12.7 4.2-1.7 15-1.2 19.6.8z"/></g></svg><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  modifier onlyOwner() {
        require(isOwner());
        _;
  }

  constructor(string memory _tld) payable ERC721("Ninja Name Service", "NNS") {
        owner = payable(msg.sender);
        tld = _tld;
        console.log("%s name service deployed", _tld);
  }

  function isOwner() public view returns (bool) {
        return msg.sender == owner;
  }

// This function will give us the price of a domain based on length
  function price(string calldata name) public pure returns(uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**17; // 1 MATIC = 1 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic
    } else if (len == 4) {
      return 6 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.6
    } else {
      return 7 * 10**17;
    }
  }
  
  function register(string calldata name) public payable {
    if (domains[name] != address(0)) revert AlreadyRegistered();
    if (!valid(name)) revert InvalidName(name);
    
    uint256 _price = price(name);
    require(msg.value >= _price, "Not enough Matic paid");
    
    string memory _name = string(abi.encodePacked(name, ".", tld));
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newRecordId = _tokenIds.current();
    uint256 length = StringUtils.strlen(name);
    string memory strLen = Strings.toString(length);

    console.log("Registering %s on the contract with tokenID %d", name, newRecordId);

    string memory json = Base64.encode(
      abi.encodePacked(
          '{"name": "',
          _name,
          '", "description": "A domain on the Disney name service", "image": "data:image/svg+xml;base64,',
          Base64.encode(bytes(finalSvg)),
          '","length":"',
          strLen,
          '"}'
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));
      
    console.log("\n--------------------------------------------------------");
    console.log("Final tokenURI", finalTokenUri);
    console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;

    names[newRecordId] = name;

    _tokenIds.increment();
  }

  function getAllNames() public view returns (string[] memory) {
    console.log("Getting all names from contract");
    string[] memory allNames = new string[](_tokenIds.current());
    for (uint i = 0; i < _tokenIds.current(); i++) {
      allNames[i] = names[i];
      console.log("Name for token %d is %s", i, allNames[i]);
    }
  
    return allNames;
  }

  function valid(string calldata name) public pure returns(bool) {
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
  }

  // We still need the price, getAddress, setRecord and getRecord functions, they just don't change
  function getAddress(string calldata name) public view returns (address) {
      // Check that the owner is the transaction sender
      return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
  if (msg.sender != domains[name]) revert Unauthorized();
  records[name] = record;
  }

  function getRecord(string calldata name) public view returns(string memory) {
      return records[name];
  }
  
  function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }

 
}