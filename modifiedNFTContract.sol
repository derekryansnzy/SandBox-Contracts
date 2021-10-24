pragma solidity >=0.7.0 <0.9.0;

contract BadassQueensII is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 2;
  uint256 public nftPerAddressLimit = 2;
  bool public paused = true;
  bool public revealed = false;
  bool public onlyWhitelisted = true;
  address[] public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
    
  function mint(uint256 _mintAmount) public payable {
    require(!paused);
    uint256 supply = totalSupply();
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);
    require(!checkForIDConflicts(_mintAmount, supply), "_mintAmount goes over a token ID range with ID conflicts, change _mintAmount or try again later");

    if (msg.sender != owner()) {
      if (onlyWhitelisted == true) {
          require(isWhitelisted(msg.sender), "User is not whitelisted!");
          uint256 ownerMintedCount = addressMintedBalance[msg.sender];
          require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
      }    
      require(msg.value >= cost * _mintAmount);
    }
    

    // for (uint256 i = 1; i <= _mintAmount; i++) {

    //     if(!_exists(supply + i)) {_safeMint(msg.sender, supply + i);}
    // }


    for (uint256 i = 1; i <= _mintAmount; i++) {
        if(!_exists(supply + i)) {
        addressMintedBalance[msg.sender]++;    
        _safeMint(msg.sender, supply + i);
        }
    }
  }

    function checkForIDConflicts(uint256 _mintAmount, uint256 supply) internal view returns(bool) {
      bool idConflicts;

      for (uint i = 1; i < _mintAmount; i++) {
        if (_exists(supply + i)) {idConflicts = true;}
    }

    return idConflicts;
  }



  function isWhitelisted(address _user) public view returns (bool) {
      for(uint256 i = 0; i < whitelistedAddresses.length; i++) {
          if (whitelistedAddresses[i] == _user) {
              return true;
          }
      }
      return false;
      
  } 



  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner

  function mintSpecificID(uint256 ID) public payable onlyOwner {
      require(!paused);
      uint256 supply = totalSupply();
      
      require(supply + 1 <= maxSupply);
      _safeMint(msg.sender, ID);
  }

  function reveal() public onlyOwner() {
      revealed = true;
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner() {
    nftPerAddressLimit = _limit;
  }

  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }

  function whitelistUsers(address[] calldata _users) public onlyOwner {
      delete whitelistedAddresses;
      whitelistedAddresses = _users;
  }
  
function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}
