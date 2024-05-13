// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import chainlink price aggr.import uniswap v2,v3 interfaces

//
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
    address public creator;

    uint256 public platformTax; // base 10000
    uint256 public lockinPeriod; // lockin
    uint256 public tokenPrice;

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
    uint256 public maxAllocation;
    uint256 public globalTaxRate;
    uint256 public whitelistTxRate;
    bytes32 public wlRoot;

    bool public isKYCEnabled;

    // include a token representing users shares

    // include a token users can use to participate in the ICO

    // important
    uint256 constant PCT_BASE = 10 ** 18;
    address public marketingWallet;

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
    function buyTokens(bytes32[] calldata proof) external payable {
        // buy tokens logic
        // Check if whitelisted
        // Check if enough ETH sent
        // Calculate token amount based on ETH price
        // Transfer ETH to contract
        // Transfer tokens to buyer
        // Emit event
    }
    function claimTokens() external {
        // Check if vesting period has passed
        // and claimed amount is less than purchased amount
        // Check if vesting period has passed
        // and claimed amount is less than purchased amount
    }
    function withdrawEth() external {
        // Check if vesting period is over
        // and withdraw amount is less than user's balance
        // and vesting period is over
        // Check if vesting period has passed
        // and withdraw amount is less than or equal to user's purchased amount
    }
    function withdrawTokens() external {
        // Check if vesting period is over
        // and claimed amount is less than purchased amount
        // or vesting period is over
        // and claimed amount is less than purchased amount
    }

    function updateEthPricePerToken(uint256 _ethPricePerToken) external onlyOperator {
        ethPricePerToken = _ethPricePerToken;
    }

    function increaseHardCap(uint256 _tokenHardCapIncrement) external {
        tokenHardCap += _tokenHardCapIncrement;
        emit TokenHardCapUpdated(address(0), tokenHardCap);
    }

    function transferOperatorOwnership(address newOperator) external onlyOperator {
        require(newOperator != address(0), "New operator");
        operator = newOperator;
        emit OperatorTransferred(msg.sender, newOperator);
    }

    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external onlyOperator {
        wlBlockNumber = _wlBlockNumber;
        wlMinBalance = _wlMinBalance;
        wlRoot = _wlRoot;
    }

    function setVestingDuration(uint256 _vestingDuration) external onlyOperator {
        vestingDuration = _vestingDuration;
    }

    function setName(string memory _name) external onlyOperator {
        name = _name;
    }

    function transferPurchasedOwnership(address _newOwner) external {
        require(msg.sender == operator, "Only operator");
        purchasedAmount[_newOwner] = purchasedAmount[msg.sender];
        purchasedAmount[_newOwner] += purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;
    }

    function ethToToken(uint256 ethAmount) public view returns (uint256 num) {
        // Calculate token amount based on ETH price
        // Transfer ETH to contract
        // Transfer tokens to buyer
        // Emit event
    }
    function getPurchasedAmount(address _address) external view {
        // Check if address exists in mapping
        // Return purchased amount
        // Check if address exists in mapping
        // Return purchased amount
        // Check if address exists in mapping
        // Return 0 if address is not in mapping
        // Else return purchased amount
    }
    function getClaimedAmount(address _address) external view {
        // Check if address exists in mapping
        // Return claimed amount
    }
    function getTotalPurchasedAmount() external view {
        // Return totalPurchasedAmount
    }

    function getProtocolFee() external view {
        // Return protocolFee
    }
    function getProtocolFeeAddress() external view {
        // Return protocolFeeAddress
    }
    function getOperator() external view {
        // Return operator
    }
    function getFactory() external view {
        // Return factory
    }
    function getStartDate() external view {
        // Return startDate
    }
    function getEndDate() external view {
        // Return endDate
    }
    function getMinTokenBuy() external view {
        // Return minTokenBuy
    }
    function getMaxTokenBuy() external view {
        // Return maxTokenBuy
    }
    function getReleaseDelay() external view {
        // Return releaseDelay
    }
    function getVestingDuration() external view {
        // Return vestingDuration
    }
    function getWLBlockNumber() external view {
        // Return wlBlockNumber
    }
    function getWLMinBalance() external view {
        // Return wlMinBalance
    }
    function getWLRoot() external view {
        // Return wlRoot
    }

    function claimableAmount(address _address) external view returns (uint256 num) {
        // Check if address exists in mapping
        // Check if vesting period has passed
        // Calculate claimable amount based on purchased, claimed and vest
    }

    function isStarted() external view returns (bool) {
        // Check if current block timestamp is greater than or equal to start date
    }
    function isEnded() external view returns (bool) {
        // Check if current block timestamp is greater than or equal to end date
    }
    function isClaimable() external view returns (bool) {
        // check if current block timestamp is greater than or equal to start date
        // and less than end date
        // and current block timestamp is greater than or equal to start of claim period
    }

    // user whitelist allocation

    // whitelist user (protoected)

    // set allocation and tax (protected)

    // set marketing wallet

    // deposit: ie invest token into token sale
    function deposit(uint256 amount) external {
        // check if kyc is enabled, if so check kyc of user

        // check if user is blacklisted

        // check if time is correct
    }

    // calculate max allocation

    // calculate max tax fre allocation

    // get user tax rate

    // claim usdc from private round

    // check if user can claim

    // send locked usd to admin wallet

    // lock usd for vesting period
    // calculate vested amount
    // send vested amount to user
}
