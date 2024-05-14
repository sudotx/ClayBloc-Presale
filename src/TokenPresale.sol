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
    uint256 constant tokenUnit = 10 ** 18;
    uint256 immutable minTokenBuy;
    uint256 immutable maxTokenBuy;
    uint256 immutable startDate;
    uint256 immutable endDate;
    address immutable protocolFeeAddress;
    uint256 public lockinPeriod;
    uint256 public tokenPrice; // presale price

    address public operator; // admin
    string public name;
    address public factory; // can be changed by the operator, can be represented as a mapping -> structs, to represent associated fees, and addresses of external platform
    uint256 public ethPricePerToken; // presale token price
    uint256 public tokenHardCap = 1000 ether;
    uint256 public protocolFee;
    uint256 public releaseDelay;
    uint256 public vestingDuration;
    mapping(address => uint256) public purchasedAmount;
    mapping(address => uint256) public claimedAmount;
    uint256 public totalPurchasedAmount;
    uint256 public wlBlockNumber = block.number;
    uint256 public wlMinBalance = 1 ether;
    bytes32 public wlRoot;

    // Modifiers
    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator");
        _;
    }
    // Constructor

    constructor(uint256 _protocolFee, address _protocolFeeAddress, address _operator, address _factory) {
        operator = _operator;
        protocolFee = _protocolFee;
        protocolFeeAddress = _protocolFeeAddress;
        factory = _factory;
        name = "Token Presale";
        ethPricePerToken = 0.1 ether;
        startDate = block.timestamp;
        endDate = startDate + 30 days;
        minTokenBuy = 1 ether;
        maxTokenBuy = 10 ether;
        releaseDelay = 30 days;
        vestingDuration = 90 days;
        wlBlockNumber = block.number;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // USER FACING FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    /// Allows users to purchase tokens during the token presale.
    /// This function checks if the user is whitelisted, verifies they have sent enough ETH,
    /// calculates the token amount based on the ETH price, transfers the ETH to the contract,
    /// transfers the tokens to the buyer, and emits an event.
    /// @param proof The Merkle proof to verify the user is whitelisted.
    function buyTokens(bytes32[] calldata proof) external payable {
        // Check if enough ETH sent
        // require the deposited amount is greater than zero

        // check if presale has started and ended

        // cache the msg.sender for gas savings, and referencing later on

        // check if user is blacklisted

        // process the deposit in an internal function (buy token logic)
        // Calculate token amount based on ETH price
        // Transfer ETH to contract
        // Transfer tokens to buyer
    }

    /// Allows users to claim their purchased tokens after the vesting period has passed.
    /// This function checks if the vesting period has passed and the claimed amount is less than the purchased amount.
    /// It then transfers the tokens to the user.

    // security considerations around the function revovles around users claiming multiple times or before vesting period ends

    // here the check effects pattern will be used to ensure an expected state transition

    function claimTokens() external {
        // cache the msg.sender
        // retrive the vest information of claimer

        // Check if vesting period has passed and claimed amount is less than purchased amount
        // get the users claim amount
        // check if user has deposited tokens and has not already claimed
        // check users balance is up to the claimed amount
        // send tokens to user
    }

    /// Allows users to withdraw their deposited ETH from the contract.
    /// This function allows user to withdraw their deposited ETH after vesting period, it is external functoins so it can be called by any user.

    // main security consideraions for this function revovles around
    // 1. possible reentrancy associated with withdrawing eth
    // 2. withdrawing more eth than the user deposited
    // 3. withdrawing before vesting period ends

    // the way that will be countered is through
    // 1. use of check effeects pattern
    // 2. require that withdraw amount is less than or equal to user's saved balance
    // 3. ensure user can only withdraw after vesting period ends
    function withdrawEth() external {
        // require the vesting period has passed
        // cache the msg sender
        // withdraw amount is less than user's balance
        // process withdrawal
    }

    /// Allows users to withdraw their purchased tokens after the vesting period has passed.
    /// This function checks if the vesting period has passed and the claimed amount is less than the purchased amount.
    /// It then transfers the tokens to the user.

    // main security considerations for this function revolves around
    // 1. possible reentrancy associated with withdrawing tokens
    // 2. withdrawing more tokens than the user purchased
    // 3. withdrawing before vesting period ends

    // the way that will be countered is through
    // 1. use of check effects pattern
    // 2. require that withdraw amount is less than or equal to user's saved balance
    // 3. ensure user can only withdraw after vesting period ends
    function withdrawTokens() external {
        // Check if vesting period is over
        // check the current msg.sender balance of purchased tokens
        // send purchased tokens to msg.sender
    }

    /// Allows the operator to transfer the purchased token amount from one address to another.
    /// This function checks that the caller is the operator, and then transfers the purchased token amount from the caller's address to the specified new owner address. The total purchased amount for the new owner is updated to include the transferred amount.
    /// @param _newOwner The address to transfer the purchased tokens to.
    // this allows any user can delegate thier allocation to others

    function transferPurchasedOwnership(address _newOwner) external {
        // check the address is not address(0), to prevent accidental or malicious burning of tokens
        // set purchasedAmount for _newOwner to the current purchasedAmount value for msg.sender
        // add the purchasedAmount value for msg.sender to the purchasedAmount for _newOwner
        // set purchasedAmount for msg.sender to 0
    }

    /// Converts the provided Ether amount to the corresponding token amount.
    /// This function calculates the token amount based on the current Ether price
    /// @param ethAmount The amount of Ether to convert to tokens.
    /// @return price The calculated token amount.

    // since this is where the contract effectively derives the eth to token price
    // it is set by the operator

    // security cobsiderations:
    // 1. this is a very sensitive function as price is being derived onchain leading to possible occurences of price manipulation attacks
    // 2. integrators that might use this might fall victim as well as the contract itself
    function ethToToken(uint256 ethAmount) public view returns (uint256 price) {
        // calculate token amount to ETH
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // OPERATOR FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    /// updates the ETH price per token.
    /// This function allows the operator to update the ETH price per token. This price is used to calculate the token amount a user receives when purchasing tokens during the token presale.
    /// @param _ethPricePerToken The new ETH price per token.

    // main security considerations for this function revolves around
    // 1. centralization concerns with possible manipulation of token presale price by single operator
    function updateEthPricePerToken(uint256 _ethPricePerToken) public onlyOperator {
        // require the price to be greater than 0
        // update the ethPricePerToken
        // emit an event for the price update
    }

    /// Increases the token hard cap by the specified increment.
    /// This function allows the operator to increase the token hard cap, which is the maximum number of tokens that can be sold during the token presale. The new hard cap is calculated by adding the increment to the current hard cap.
    /// @param _tokenHardCapIncrement The amount to increase the token hard cap by.
    function increaseHardCap(uint256 _tokenHardCapIncrement) public onlyOperator {
        // Require increment to be greater than 0
        // Add increment to current hard cap
        // Update hard cap
    }

    /// Allows the current operator to transfer operator ownership to a new address.
    /// This function checks that the new operator address is not the zero address, and updates the operator address. It emits an OperatorTransferred event to notify listeners of the change.
    /// @param newOperator The new address to assign as the operator.
    function transferOperatorOwnership(address newOperator) public onlyOperator {
        // reqiure new operator address not to be address(0)
        // transfer ownership to new operator
    }

    /// Updates the whitelist parameters.
    /// This function allows the operator to update the whitelist block number, minimum balance, and root hash. These parameters are used to verify if a user is on the whitelist and eligible to participate in the token presale.
    /// @param _wlBlockNumber The new whitelist block number.
    /// @param _wlMinBalance The new minimum balance required for the whitelist.
    /// @param _wlRoot The new whitelist root hash.
    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) public onlyOperator {
        // ensure the numbers are correct, ie not set to zero
        // sets the wlBlockNumber
        // sets the wlMinBalance
        // sets the wlRoot
    }

    /// Sets the vesting duration for token withdrawals.
    /// This function allows the operator to set the vesting duration, which is the period of time after the token presale ends during which users can withdraw their purchased tokens.
    /// @param _vestingDuration The new vesting duration

    // this introduces centralization risk to the system as the operator gets to set the vesting duration at any time
    // but it is assumed the operator will be a trusted party
    function setVestingDuration(uint256 _vestingDuration) public onlyOperator {
        // reqiure vesting duration to be greater than 0
        // set the vesting duration
    }

    /// Sets the name of the token presale.
    /// This function allows the operator to set the name of the token presale. The name is used to identify the presale.
    /// @param _name The new name for the token presale.
    function setName(string memory _name) public onlyOperator {
        // sets the name
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // GETTER FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    /// Returns the amount of tokens purchased by the specified address.
    /// This function checks if specified address exists in the purchasedAmount mapping, and if so, returns the amount of tokens purchased by that address. If the address is not in the mapping, it returns 0.
    /// @param _address The address to check the purchased token amount for.
    function getPurchasedAmount(address _address) public view returns (uint256 amountPurchased) {
        // require address to not be address(0), and exist in list of participants
        // if exists, return purchased amount
    }

    /// Returns the amount of tokens claimed by the specified address.
    /// This function checks if the specified address exists in the claimedAmount mapping, and if so, returns the amount of tokens claimed by that address. If the address is not in the mapping, it returns 0.
    /// @param _address The address to check the claimed token amount for.
    function getClaimedAmount(address _address) private view returns (uint256 amountClaimed) {
        // calculate the claim of an address accounting for the vesting period
        // effectively how much can be claimed currently
    }

    /// Returns the total amount of tokens purchased across all addresses.
    /// This function returns the total amount of tokens that have been purchased across all addresses participating in the token presale.
    function getTotalPurchasedAmount() public view returns (uint256 totalPurchasedAmount) {}

    /// Returns the protocol fee.
    /// This function returns the current protocol fee that is charged for the token presale.
    function getProtocolFee() public view returns (uint256 protocolFee) {
        // Return protocolFee
    }
    /// Returns the protocol fee address.
    /// This function returns the current protocol fee address that is used for the token presale.
    function getProtocolFeeAddress() public view returns (address protocolFeeAddress) {
        // Return protocolFeeAddress
    }
    /// Returns the current operator address.
    /// This function returns the address of the current operator for the token presale contract.
    function getOperator() public view returns (address operator) {
        // Return operator
    }
    /// Returns the factory address.
    /// This function returns the address of the factory contract associated with this token presale contract.
    function getFactory() public view returns (address factory) {
        // Return factory
    }
    /// Returns the start date of the token presale.
    /// This function returns the start date of the token presale.
    function getStartDate() public view returns (uint256 startDate) {
        // Return startDate
    }
    /// Returns the end date of the token presale.
    /// This function returns the end date of the token presale.
    function getEndDate() public view returns (uint256 endDate) {
        // Return endDate
    }
    /// Returns the minimum token buy amount.
    /// This function returns the current minimum token buy amount for the token presale.
    function getMinTokenBuy() public view returns (uint256 minTokenBuyAmount) {
        // Return minTokenBuy
    }
    function getMaxTokenBuy() public view returns (uint256 maxTokenBuyAmount) {
        // Return maxTokenBuy
    }
    /// Returns the release delay.
    /// This function returns the current release delay for the token presale.

    // this will be the amount of time users that have purchased tokens will have thier tokens vested for
    function getReleaseDelay() public view returns (uint256 releaseDelay) {
        // Return releaseDelay
    }
    /// Returns the vesting duration.
    /// This function returns the current vesting duration for the token presale.
    function getVestingDuration() public view {
        // Return vestingDuration
    }
    /// Returns the whitelist block number.
    /// This function returns the current whitelist block number for the token presale.
    function getWLBlockNumber() public view {
        // Return wlBlockNumber
    }

    /// Returns the minimum whitelist balance.
    /// This function returns the current minimum whitelist balance required for the token presale.
    function getWLMinBalance() public view {
        // Return wlMinBalance
    }

    /// Returns the whitelist root.
    /// This function returns the current whitelist root for the token presale.
    function getWLRoot() public view {
        // Returns the wlRoot
    }

    function claimableAmount(address _address) public view returns (uint256 claimableAmount) {
        // this is to calculate the amount of tokens that can be claimed by an address
    }

    // this allows an external actor to check the current state of the contract
    function isStarted() public view returns (bool) {}

    function isEnded() public view returns (bool) {}

    function isClaimable() public view returns (bool) {
        // check if current block timestamp is greater than or equal to start date and less than end date
    }
}
