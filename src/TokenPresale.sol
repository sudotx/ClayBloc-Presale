// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ILaunchpad {
    // Events
    event TokensPurchased(address indexed _token, address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed _token, address indexed buyer, uint256 amount);
    event EthPricePerTokenUpdated(address indexed _token, uint256 newEthPricePerToken);
    event WhitelistUpdated(uint256 wlBlockNumber, uint256 wlMinBalance, bytes32 wlRoot);
    event TokenHardCapUpdated(address indexed _token, uint256 newTokenHardCap);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event VestingDurationUpdated(uint256 newVestingDuration);

    // Contract functions
    function isStarted() external view returns (bool);
    function isEnded() external view returns (bool);
    function isClaimable() external view returns (bool);
    function transferOperatorOwnership(address newOperator) external;
    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external;
    function increaseHardCap(uint256 _tokenHardCapIncrement) external;
    function updateEthPricePerToken(uint256 _ethPricePerToken) external;
    function ethToToken(uint256 ethAmount) external view returns (uint256);
    function buyTokens(bytes32[] calldata proof) external payable;
    function claimableAmount(address _address) external view returns (uint256);
    function claimTokens() external;
    function withdrawEth() external;
    function withdrawTokens() external;
    function setVestingDuration(uint256 _vestingDuration) external;
    function setName(string memory _name) external;
    function transferPurchasedOwnership(address _newOwner) external;
}

contract TokenPresale is ILaunchpad {
    // Variables
    address public operator;
    string public name;
    uint256 public immutable tokenUnit;
    address public immutable factory;
    uint256 public ethPricePerToken;
    uint256 public tokenHardCap;
    uint256 public minTokenBuy;
    uint256 public maxTokenBuy;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public protocolFee;
    address public protocolFeeAddress;
    uint256 public releaseDelay;
    uint256 public vestingDuration;
    mapping(address => uint256) public purchasedAmount;
    mapping(address => uint256) public claimedAmount;
    uint256 public totalPurchasedAmount;
    uint256 public wlBlockNumber;
    uint256 public wlMinBalance;
    bytes32 public wlRoot;

    // Modifiers
    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator");
        _;
    }
    // Constructor

    constructor(
        // MainLaunchpadInfo memory _info,
        uint256 _protocolFee,
        address _protocolFeeAddress,
        address _operator,
        address _factory
    ) {
        operator = _operator;
        protocolFee = _protocolFee;
        protocolFeeAddress = _protocolFeeAddress;
        factory = _factory;
        tokenUnit = 10 ** 18;
        name = "Default Token Presale";
        ethPricePerToken = 0.1 ether;
        tokenHardCap = 1000 ether;
        startDate = block.timestamp;
        endDate = startDate + 30 days;
        minTokenBuy = 1 ether;
        maxTokenBuy = 10 ether;
        releaseDelay = 30 days;
        vestingDuration = 90 days;
        wlBlockNumber = block.number;
        wlMinBalance = 1 ether;
        wlRoot = 0x0;
    }

    // main functions
    function buyTokens(bytes32[] calldata proof) external payable {}
    function claimTokens() external {}
    function withdrawEth() external {}
    function withdrawTokens() external {}
    function updateEthPricePerToken(uint256 _ethPricePerToken) external onlyOperator {}
    function increaseHardCap(uint256 _tokenHardCapIncrement) external {}
    function transferOperatorOwnership(address newOperator) external onlyOperator {}

    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external onlyOperator {}
    function setVestingDuration(uint256 _vestingDuration) external onlyOperator {}

    function setName(string memory _name) external onlyOperator {}

    function transferPurchasedOwnership(address _newOwner) external {}
    function ethToToken(uint256 ethAmount) public view returns (uint256 num) {}
    function getPurchasedAmount(address _address) external view {}
    function getClaimedAmount(address _address) external view {}
    function getTotalPurchasedAmount() external view {}

    function getProtocolFee() external view {}
    function getProtocolFeeAddress() external view {}
    function getOperator() external view {}
    function getFactory() external view {}
    function getStartDate() external view {}
    function getEndDate() external view {}
    function getMinTokenBuy() external view {}
    function getMaxTokenBuy() external view {}
    function getReleaseDelay() external view {}
    function getVestingDuration() external view {}
    function getWLBlockNumber() external view {}
    function getWLMinBalance() external view {}
    function getWLRoot() external view {}

    function claimableAmount(address _address) external view returns (uint256 num) {}

    function isStarted() external view returns (bool) {}
    function isEnded() external view returns (bool) {}
    function isClaimable() external view returns (bool) {}
}
