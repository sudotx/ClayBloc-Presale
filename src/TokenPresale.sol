// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import chainlink price aggr.import uniswap v2,v3 interfaces

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
    address immutable creator;

    uint256 public platformTax;
    uint256 public lockinPeriod;
    uint256 public tokenPrice;

    address public operator;
    string public name;
    uint256 constant tokenUnit = 10 ** 18;
    address public immutable factory;
    uint256 public ethPricePerToken;
    uint256 public tokenHardCap = 1000 ether;
    uint256 immutable minTokenBuy;
    uint256 immutable maxTokenBuy;
    uint256 immutable startDate;
    uint256 immutable endDate;
    uint256 public protocolFee;
    address immutable protocolFeeAddress;
    uint256 public releaseDelay;
    uint256 public vestingDuration;
    mapping(address => uint256) public purchasedAmount;
    mapping(address => uint256) public claimedAmount;
    uint256 public totalPurchasedAmount;
    uint256 public wlBlockNumber = block.number;
    uint256 public wlMinBalance = 1 ether;
    uint256 public maxAllocation;
    uint256 public globalTaxRate;
    uint256 public whitelistTxRate;
    bytes32 public wlRoot;

    bool public isKYCEnabled;

    // include a token users can use to participate in the ICO

    // Modifiers
    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator");
        _;
    }
    // Constructor

    constructor(uint256 _protocolFee, address _protocolFeeAddress, address _operator, address _factory) {
        operator = _operator;
        creator = msg.sender;
        protocolFee = _protocolFee;
        protocolFeeAddress = _protocolFeeAddress;
        factory = _factory;
        name = "Default Token Presale";
        ethPricePerToken = 0.1 ether;
        startDate = block.timestamp;
        endDate = startDate + 30 days;
        minTokenBuy = 1 ether;
        maxTokenBuy = 10 ether;
        releaseDelay = 30 days;
        vestingDuration = 90 days;
        wlBlockNumber = block.number;
    }

    /// Allows users to purchase tokens during the token presale.
    /// This function checks if the user is whitelisted, verifies they have sent enough ETH,
    /// calculates the token amount based on the ETH price, transfers the ETH to the contract,
    /// transfers the tokens to the buyer, and emits an event.
    /// @param proof The Merkle proof to verify the user is whitelisted.

    function buyTokens(bytes32[] calldata proof) external payable {
        // check if kyc is enabled, if so check kyc of user

        // check if user is blacklisted

        // check if time is correct
        // buy tokens logic
        // Check if whitelisted
        // Check if enough ETH sent
        // Calculate token amount based on ETH price
        // Transfer ETH to contract
        // Transfer tokens to buyer
        // Emit event
    }
    /// Allows users to claim their purchased tokens after the vesting period has passed.
    /// This function checks if the vesting period has passed and the claimed amount is less than the purchased amount.
    /// It then transfers the tokens to the user.
    function claimTokens() external {
        // Check if vesting period has passed
        // and claimed amount is less than purchased amount
        // Check if vesting period has passed
        // and claimed amount is less than purchased amount
    }
    /// Allows users to withdraw their purchased Ethereum (ETH) from the contract.
    /// This function checks if the vesting period has passed and the withdraw amount is less than or equal to the user's purchased amount. It then transfers the ETH to the user.
    function withdrawEth() external {
        // Check if vesting period is over
        // and withdraw amount is less than user's balance
        // and vesting period is over
        // Check if vesting period has passed
        // and withdraw amount is less than or equal to user's purchased amount
    }
    /// Allows users to withdraw their purchased tokens after the vesting period has passed.
    /// This function checks if the vesting period has passed and the claimed amount is less than the purchased amount.
    /// It then transfers the tokens to the user.
    function withdrawTokens() external {
        // Check if vesting period is over
        // and claimed amount is less than purchased amount
        // or vesting period is over
        // and claimed amount is less than purchased amount
    }

    /// Updates the Ethereum (ETH) price per token.
    /// This function allows the operator to update the ETH price per token. This price is used to calculate the token amount a user receives when purchasing tokens during the token presale.
    /// @param _ethPricePerToken The new ETH price per token.
    function updateEthPricePerToken(uint256 _ethPricePerToken) external onlyOperator {
        ethPricePerToken = _ethPricePerToken;
    }

    /// Increases the token hard cap by the specified increment.
    /// This function allows the operator to increase the token hard cap, which is the maximum number of tokens that can be sold during the token presale. The new hard cap is calculated by adding the increment to the current hard cap.
    /// @param _tokenHardCapIncrement The amount to increase the token hard cap by.
    function increaseHardCap(uint256 _tokenHardCapIncrement) external {
        tokenHardCap += _tokenHardCapIncrement;
        emit TokenHardCapUpdated(address(0), tokenHardCap);
    }

    /// Allows the current operator to transfer operator ownership to a new address.
    /// This function checks that the new operator address is not the zero address, and updates the operator address. It emits an OperatorTransferred event to notify listeners of the change.
    /// @param newOperator The new address to assign as the operator.
    function transferOperatorOwnership(address newOperator) external onlyOperator {
        require(newOperator != address(0), "New operator");
        operator = newOperator;
        emit OperatorTransferred(msg.sender, newOperator);
    }

    /// Updates the whitelist parameters.
    /// This function allows the operator to update the whitelist block number, minimum balance, and root hash. These parameters are used to verify if a user is on the whitelist and eligible to participate in the token presale.
    /// @param _wlBlockNumber The new whitelist block number.
    /// @param _wlMinBalance The new minimum balance required for the whitelist.
    /// @param _wlRoot The new whitelist root hash.
    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external onlyOperator {
        wlBlockNumber = _wlBlockNumber;
        wlMinBalance = _wlMinBalance;
        wlRoot = _wlRoot;
    }

    /// Sets the vesting duration for token withdrawals.
    /// This function allows the operator to set the vesting duration, which is the period of time after the token presale ends during which users can withdraw their purchased tokens. The vesting duration is specified in number of blocks.
    /// @param _vestingDuration The new vesting duration in blocks.
    function setVestingDuration(uint256 _vestingDuration) external onlyOperator {
        vestingDuration = _vestingDuration;
    }

    /// Sets the name of the token presale.
    /// This function allows the operator to set the name of the token presale. The name is used to identify the presale.
    /// @param _name The new name for the token presale.
    function setName(string memory _name) external onlyOperator {
        name = _name;
    }

    /// Allows the operator to transfer the purchased token amount from one address to another.
    /// This function checks that the caller is the operator, and then transfers the purchased token amount from the caller's address to the specified new owner address. The total purchased amount for the new owner is updated to include the transferred amount.
    /// @param _newOwner The address to transfer the purchased tokens to.
    function transferPurchasedOwnership(address _newOwner) external {
        // Require that msg.sender is equal to operator, otherwise revert with error "Only operator"

        // Set purchasedAmount for _newOwner to the current purchasedAmount value for msg.sender

        // Add the purchasedAmount value for msg.sender to the purchasedAmount for _newOwner

        // Set purchasedAmount for msg.sender to 0
    }

    /// Converts the provided Ether amount to the corresponding token amount.
    /// This function calculates the token amount based on the current Ether price, transfers the Ether to the contract, transfers the tokens to the buyer, and emits an event.
    /// @param ethAmount The amount of Ether to convert to tokens.
    /// @return num The calculated token amount.
    function ethToToken(uint256 ethAmount) public view returns (uint256 num) {
        // Calculate token amount based on ETH price
        // Transfer ETH to contract
        // Transfer tokens to buyer
        // Emit event
    }
    /// Returns the amount of tokens purchased by the specified address.
    /// This function checks if specified address exists in the purchasedAmount mapping, and if so, returns the amount of tokens purchased by that address. If the address is not in the mapping, it returns 0.
    /// @param _address The address to check the purchased token amount for.
    function getPurchasedAmount(address _address) external view {
        // Check if address exists in mapping
        // Return purchased amount
        // Return purchased amount
        // Check if address exists in mapping
        // Return 0 if address is not in mapping
        // Else return purchased amount
    }
    /// Returns the amount of tokens claimed by the specified address.
    /// This function checks if the specified address exists in the claimedAmount mapping, and if so, returns the amount of tokens claimed by that address. If the address is not in the mapping, it returns 0.
    /// @param _address The address to check the claimed token amount for.
    function getClaimedAmount(address _address) external view {
        // Check if address exists in mapping
        // Return claimed amount
    }
    /// Returns the total amount of tokens purchased across all addresses.
    /// This function returns the total amount of tokens that have been purchased across all addresses participating in the token presale.
    function getTotalPurchasedAmount() external view {
        // Return totalPurchasedAmount
    }

    /// Returns the protocol fee.
    /// This function returns the current protocol fee that is charged for the token presale.
    function getProtocolFee() external view {
        // Return protocolFee
    }
    /// Returns the protocol fee address.
    /// This function returns the current protocol fee address that is used for the token presale.
    function getProtocolFeeAddress() external view {
        // Return protocolFeeAddress
    }
    /// Returns the current operator address.
    /// This function returns the address of the current operator for the token presale contract.
    function getOperator() external view {
        // Return operator
    }
    /// Returns the factory address.
    /// This function returns the address of the factory contract associated with this token presale contract.
    function getFactory() external view {
        // Return factory
    }
    /// Returns the start date of the token presale.
    /// This function returns the start date of the token presale.
    function getStartDate() external view {
        // Return startDate
    }
    /// Returns the end date of the token presale.
    /// This function returns the end date of the token presale.
    function getEndDate() external view {
        // Return endDate
    }
    /// Returns the minimum token buy amount.
    /// This function returns the current minimum token buy amount for the token presale.
    function getMinTokenBuy() external view {
        // Return minTokenBuy
    }
    function getMaxTokenBuy() external view {
        // Return maxTokenBuy
    }
    /// Returns the release delay.
    /// This function returns the current release delay for the token presale.
    function getReleaseDelay() external view {
        // Return releaseDelay
    }
    /// Returns the vesting duration.
    /// This function returns the current vesting duration for the token presale.
    function getVestingDuration() external view {
        // Return vestingDuration
    }
    /// Returns the whitelist block number.
    /// This function returns the current whitelist block number for the token presale.
    function getWLBlockNumber() external view {
        // Return wlBlockNumber
    }
    /// Returns the minimum whitelist balance.
    /// This function returns the current minimum whitelist balance required for the token presale.
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
        return true;
    }

    function isEnded() external view returns (bool) {
        // Check if current block timestamp is greater than or equal to end date
        return true;
    }

    function isClaimable() external view returns (bool) {
        // check if current block timestamp is greater than or equal to start date
        // and less than end date
        // and current block timestamp is greater than or equal to start of claim period
        return true;
    }

    /// Allows a user to deposit a specified amount into the token presale.
    /// This function checks if KYC is enabled and the user has passed KYC, if the user is not blacklisted, and if the deposit is being made during the correct time period.
    /// @param amount The amount the user wants to deposit.
    function deposit(uint256 amount) external {
        // check if kyc is enabled, if so check kyc of user

        // check if user is blacklisted

        // check if time is correct
    }
}
