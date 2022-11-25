// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FortyFourMiami is ERC721A, Pausable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 immutable MAX_SUPPLY = 8888;
    string private baseURI;
    address public OzuraPayManager;

    modifier onlyOzuraPay {
            require(msg.sender == OzuraPayManager);
            _;
    }

    constructor() ERC721A("Forty Four Miami", "FFM") {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address recipient, uint256 quantity) external payable onlyOzuraPay nonReentrant {
        require(totalSupply().add(quantity) <= MAX_SUPPLY, "FFM: Mint would exceed Max Supply");
        _safeMint(recipient, quantity);
    }

    function ownerMint(uint256 quantity) external onlyOwner nonReentrant {
        require(totalSupply().add(quantity) <= MAX_SUPPLY, "FFM: Mint would exceed Max Supply");
        _safeMint(msg.sender, quantity);
    }
    
    function setOzuraPayManager(address _OzuraPayManager) external onlyOwner {
        OzuraPayManager = _OzuraPayManager;
    }

    function burn(uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "FFM: You are not Owner");
        _burn(tokenId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual whenNotPaused override {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    /**
     * @dev Returns the starting token ID.
     */
    function _startTokenId() internal view virtual override(ERC721A) returns (uint256) {
        return 1;
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
