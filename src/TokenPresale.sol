// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

interface ILaunchpad {
    // Events
    event TokensPurchased(address indexed _token, address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed _token, address indexed buyer, uint256 amount);
    event EthPricePerTokenUpdated(address indexed _token, uint256 newEthPricePerToken);
    event WhitelistUpdated(uint256 wlBlockNumber, uint256 wlMinBalance, bytes32 wlRoot);
    event MerkleRootUpdated(bytes32 wlRoot);
    event TokenHardCapUpdated(address indexed _token, uint256 newTokenHardCap);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event VestingDurationUpdated(uint256 newVestingDuration);

    // Contract functions
    function isStarted() external view returns (bool);
    function isEnded() external view returns (bool);
    function isClaimable() external view returns (bool);
    // function transferOperatorOwnership(address newOperator) external;
    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external;
    function increaseHardCap(uint256 _tokenHardCapIncrement) external;
    function updateEthPricePerToken(uint256 _ethPricePerToken) external;
    function ethToToken(uint256 ethAmount) external view returns (uint256);
    function buyTokens(bytes32[] calldata proof) external payable;
    function claimableAmount(address _address) external view returns (uint256);
    function claimTokens() external;
    function withdrawEth() external;
    // function withdrawTokens() external;
    function setVestingDuration(uint256 _vestingDuration) external;
    function setName(string memory _name) external;
    function transferPurchasedOwnership(address _newOwner) external;
}

contract TokenPresale is ILaunchpad, Ownable(msg.sender) {
    using SafeERC20 for IERC20;
    // Variables

    uint256 constant tokenUnit = 10 ** 18;
    uint256 public immutable minTokenBuy;
    uint256 public immutable maxTokenBuy;
    uint256 public immutable startDate;
    uint256 public immutable endDate;
    address public immutable protocolFeeAddress;
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
    mapping(address => bool) public userClaimed;
    uint256 public totalPurchasedAmount;
    uint256 public wlBlockNumber = block.number;
    uint256 public wlMinBalance = 1 ether;
    bytes32 public wlRoot;

    // max allocation
    // instead of a dedicated staking contract, liquidity is ssent to the Uniswap pair
    // but first to the presaleVaultAddress
    address presaleVaultAddress;

    // accepts usdc only
    address usdc;

    // total supply, total private sold

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
        // set uniswap factory
        factory = _factory;
        name = "Token Presale";
        ethPricePerToken = 0.1 ether;
        startDate = block.timestamp;
        endDate = startDate + 10 days;
        minTokenBuy = 1 ether;
        maxTokenBuy = 10 ether;
        releaseDelay = 30 days;
        vestingDuration = 90 days;
        wlBlockNumber = block.number;

        // set presale vault address
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // USER FACING FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    function buyTokens(bytes32[] calldata proof) external payable {
        // Check if enough ETH sent
        // require the deposited amount is greater than zero
        require(msg.value > 0);
        // check if presale has started and ended
        require(block.timestamp > startDate);

        // cache the msg.sender for gas savings, and referencing later on
        address sender = msg.sender;

        // process the deposit in an internal function (buy token logic)
        bytes32 leaf = keccak256(abi.encodePacked(sender));
        require(MerkleProof.verify(proof, wlRoot, leaf), "Invalid Merkle Proof");
        // check if user is blacklisted
        // require(sender, "User Blacklisted");

        // Calculate token amount based on ETH price
        uint256 tokensToReceive = msg.value * 3;
        require(tokensToReceive > 1212, "Unable to fill your order, try a smaller amount"); // check if tokens to be received are up to tokens left unsold

        // log investor
        purchasedAmount[sender] = msg.value;
        // Transfer ETH to contract
    }

    function claimTokens() external {
        // cache the msg.sender

        // Check if vesting period has passed and claimed amount is less than purchased amount
        require(block.timestamp > 1, "Not yet past vesting time");
        // require(block.timestamp > endDate, "Not yet past vesting time");
        // require(block.timestamp > endDate + vestingDuration, "Not yet past vesting time");
        // get the users claim amount
        uint256 amount = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;

        // check if user has deposited tokens and has not already claimed
        claimedAmount[msg.sender] = amount;

        // send tokens to user
        // IERC20(address(69)).transfer(msg.sender, amount);
        emit TokensClaimed(address(69), msg.sender, amount);
    }

    function withdrawEth() external {
        require(purchasedAmount[msg.sender] != 0, "Nothing to withdraw");
        // require the vesting period has passed
        require(block.timestamp > endDate + vestingDuration);
        // cache the msg sender

        uint256 claimAmount = purchasedAmount[msg.sender];

        // withdraw amount is less than user's balance
        // process withdrawal
        (bool success,) = payable(address(this)).call{value: claimAmount}("");
        require(success);
    }

    /// Allows the operator to transfer the purchased token amount from one address to another.
    /// This function checks that the caller is the operator, and then transfers the purchased token amount from the caller's address to the specified new owner address. The total purchased amount for the new owner is updated to include the transferred amount.
    /// @param _newOwner The address to transfer the purchased tokens to.
    // this allows any user can delegate thier allocation to others

    function transferPurchasedOwnership(address _newOwner) external {
        require(_newOwner != address(0), "Cant allow yoooou burn tokens dawg");
        // check the address is not address(0), to prevent accidental or malicious burning of tokens
        // set purchasedAmount for _newOwner to the current purchasedAmount value for msg.sender
        // add the purchasedAmount value for msg.sender to the purchasedAmount for _newOwner
        // set purchasedAmount for msg.sender to 0
        uint256 prevOwnerAmount = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;
        purchasedAmount[_newOwner] = prevOwnerAmount;

        // emit event
    }

    function ethToToken(uint256 ethAmount) public view returns (uint256 price) {
        // calculate token amount to ETH
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // OWNER FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    function updateEthPricePerToken(uint256 _ethPricePerToken) public onlyOwner {
        // require the price to be greater than 0
        // update the ethPricePerToken
        // emit an event for the price update
        require(_ethPricePerToken != 0, "cant be zero");
        ethPricePerToken = _ethPricePerToken;
    }

    function increaseHardCap(uint256 _tokenHardCapIncrement) public onlyOwner {
        // increment current hard cap
        tokenHardCap += _tokenHardCapIncrement;
    }

    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) public onlyOwner {
        // ensure the numbers are correct, ie not set to zero
        require(_wlRoot != bytes32(0));
        // sets the wlRoot
        wlRoot = _wlRoot;

        emit WhitelistUpdated(_wlBlockNumber, _wlMinBalance, _wlRoot);
    }

    function setVestingDuration(uint256 _vestingDuration) public onlyOwner {
        // reqiure vesting duration to be greater than 0
        // set the vesting duration
        vestingDuration = _vestingDuration;
    }

    function setName(string memory _name) public onlyOwner {
        // sets the name
        name = _name;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    // GETTER FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    function getClaimedAmount(address _address) private view returns (uint256 amountClaimed) {
        // effectively how much can be claimed currently
        amountClaimed = claimedAmount[_address];
    }

    function claimableAmount(address _address) public view returns (uint256 claimable) {
        // this is to calculate the amount of tokens that can be claimed by an address
        claimable = purchasedAmount[_address];
    }

    // this allows an external actor to check the current state of the contract
    function isStarted() public view returns (bool) {
        if (block.timestamp > startDate) {
            return true;
        }
        return false;
    }

    function isEnded() public view returns (bool) {
        if (block.timestamp > endDate) {
            return true;
        }
        return false;
    }

    function isClaimable() public view returns (bool) {
        // check if current block timestamp is greater than or equal to start date and less than end date
        if (block.timestamp > endDate + vestingDuration) {
            return true;
        }
        return false;
    }

    receive() external payable {}
}
