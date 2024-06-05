// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

interface ILaunchpad {
    event TokensPurchased(address indexed _token, address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed _token, address indexed buyer, uint256 amount);
    event EthPricePerTokenUpdated(address indexed _token, uint256 newEthPricePerToken);
    event WhitelistUpdated(uint256 wlBlockNumber, uint256 wlMinBalance, bytes32 wlRoot);
    event MerkleRootUpdated(bytes32 wlRoot);
    event TokenHardCapUpdated(address indexed _token, uint256 newTokenHardCap);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event VestingDurationUpdated(uint256 newVestingDuration);

    function isStarted() external view returns (bool);
    function isEnded() external view returns (bool);
    function isClaimable() external view returns (bool);
    function updateWhitelist(uint256 _wlBlockNumber, uint256 _wlMinBalance, bytes32 _wlRoot) external;
    function increaseHardCap(uint256 _tokenHardCapIncrement) external;
    function updateEthPricePerToken(uint256 _ethPricePerToken) external;
    function ethToToken(uint256 ethAmount) external view returns (uint256);
    function buyTokens(bytes32[] calldata proof, uint256 amount) external payable;
    function claimableAmount(address _address) external view returns (uint256);
    function claimTokens() external;
    function withdrawEth() external;
    function setVestingDuration(uint256 _vestingDuration) external;
    // function setName(string memory _name) external;
    function transferPurchasedOwnership(address _newOwner) external;

    struct Params {
        address tokenAddress;
        address router;
        uint256 totalSupply;
        uint256 maxAllocation;
        uint96 saleStart;
        uint96 saleEnd;
        uint64 liqudityPercentage; //with base 10000
        uint256 tokenLiquidity; //token amount to add to liquid
        uint256 baseLine; // with 18 decimal
        bool burnUnsold;
    }

    struct Config {
        uint256 LPLockin; //in seconds
        uint256 vestingPeriod; //in seconds for vesting starting time
        uint256 vestingDistribution; //in seconds for vesting distribution duration
        uint256 vestingDuration; //in seconds for vesting distribution duration
        uint256 NoOfVestingIntervals; //in seconds for vesting
        uint256 FirstVestPercentage; //with base 10000
        uint256 LiqGenerationTime;
    }

    struct State {
        uint256 totalSold;
        uint256 totalSupplyInValue;
    }
}

contract TokenPresale is ILaunchpad, Ownable {
    using SafeERC20 for IERC20;

    uint256 constant tokenUnit = 10 ** 18;

    uint256 public immutable minTokenBuy;
    uint256 public immutable maxTokenBuy;
    uint256 public immutable startDate;
    uint256 public immutable endDate;

    uint256 public lockinPeriod;
    uint256 public tokenPrice; // presale price
    uint256 public ethPricePerToken;
    uint256 public tokenHardCap = 1000 ether;
    uint256 public protocolFee;
    uint256 public protocolTask;
    uint256 public releaseDelay;
    uint256 public vestingDuration;
    uint256 public lockInDuration;
    uint256 public maxAllocation;
    uint256 public totalSupply;
    uint256 public totalPurchasedAmount;
    uint256 public wlBlockNumber = block.number;
    uint256 public wlMinBalance = 1 ether;

    address public immutable protocolFeeAddress;

    address public factory;
    address public router;
    address public presaleVaultAddress;
    address public marketingWallet;
    address public WETH;

    bytes32 public wlRoot;
    mapping(address => uint256) public purchasedAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => bool) public hasClaimed;

    Config public config;

    constructor(uint256 _protocolFee, address _protocolFeeAddress, address _factory, address _router, address _weth)
        Ownable(msg.sender)
    {
        protocolFee = _protocolFee;
        protocolFeeAddress = _protocolFeeAddress;
        // set uniswap router
        factory = _factory;
        router = _router;
        ethPricePerToken = 0.1 ether;
        startDate = block.timestamp;
        endDate = startDate + 10 days;
        minTokenBuy = 1 ether;
        maxTokenBuy = 10 ether;
        releaseDelay = 30 days;
        vestingDuration = 90 days;
        wlBlockNumber = block.number;
        WETH = _weth;
        tokenPrice = (maxAllocation * tokenUnit) / totalSupply;

        // set presale vault address
        presaleVaultAddress = msg.sender;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    //                     USER FACING FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    function buyTokens(bytes32[] calldata proof, uint256 amount) external payable {
        // invest ETH in token sale
        // require sender is not blacklisted
        // check if user is blacklisted
        // require(sender, "User Blacklisted");
        require(amount > amount * ethPricePerToken); // require sender send enough value
        // check if presale has started and ended
        require(block.timestamp > startDate);

        // cache the msg.sender for gas savings, and referencing later on
        address sender = msg.sender;

        bytes32 leaf = keccak256(abi.encodePacked(sender));
        bool verificationStatus = MerkleProof.verify(proof, wlRoot, leaf);
        require(verificationStatus, "Not Whitelisted");

        // Calculate token amount based on ETH price
        uint256 tokensToReceive = amount * ethPricePerToken; // total amount to send to user based on price;
        require(tokensToReceive > tokenHardCap, "Unable to fill your order, try a smaller amount"); // check if tokens to be received are up to tokens left unsold, wherer 1212 stands as total available supply

        purchasedAmount[sender] = amount;
        // globally tracking how much tokens have been purchased.
        totalPurchasedAmount += amount;

        bytes memory data = abi.encodeWithSignature("transfer(address, uint256)", address(this), amount);
        (bool success,) = address(WETH).call(data);
        require(success);
    }

    function claimTokens() external {
        // check user has something to claim
        require(!hasClaimed[msg.sender], "already claimed");

        // cache the msg.sender

        // Check if vesting period has passed and claimed amount is less than purchased amount
        // require(block.timestamp > 1, "Not yet past vesting time");
        require(block.timestamp > endDate, "Not yet past vesting time");
        // require(block.timestamp > endDate + vestingDuration, "Not yet past vesting time");
        // get the users claim amount
        uint256 amount = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;

        // check if user has deposited tokens and has not already claimed
        claimedAmount[msg.sender] = amount;

        // send tokens to user
        bytes memory data = abi.encodeWithSignature("transfer(address, uint256)", msg.sender, amount);
        (bool success,) = address(WETH).call(data);
        require(success);
        emit TokensClaimed(address(69), msg.sender, amount);
    }

    function withdrawEth() external {
        require(purchasedAmount[msg.sender] != 0, "Nothing to withdraw");
        // require the vesting period has passed
        require(block.timestamp > endDate + vestingDuration);
        // cache the msg sender

        uint256 claimAmount = purchasedAmount[msg.sender];

        bytes memory data = abi.encodeWithSignature("transfer(address, uint256)", msg.sender, claimAmount);
        (bool success,) = address(WETH).call(data);
        require(success);

        // withdraw amount is less than user's balance
        // process withdrawal
        // (bool success,) = payable(address(this)).call{value: claimAmount}("");
        // require(success);
    }

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
    //                      OWNER FUNCTIONS
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

    function setConfig(Config memory _config) public onlyOwner {
        // implement roles, only admin with operator role should be able to change this
        require(config.NoOfVestingIntervals == 0);
        config = _config;
    }

    function addLiq() internal onlyOwner {
        // require(isRaiseClaimed, "takeUSDBRaised not called");
        // require(block.timestamp >= lockinPeriod + config.LiqGenerationTime, "Lockin period is not over yet");
        // require(liqAdded, "liqAdded");
        // uint256 USDBAmount = state.totalSold > state.totalSupplyInValue ? state.totalSupplyInValue : state.totalSold;
        // USDBAmount = (USDBAmount * (params.liqudityPercentage)) / POINT_BASE;

        // uint256 tokenAmount = state.totalSold > state.totalSupplyInValue
        //     ? params.tokenLiquidity
        //     : params.tokenLiquidity * state.totalSold / state.totalSupplyInValue;

        // IERC20D(params.tokenAddress).approve(address(router), tokenAmount);
        // router.addLiquidityETH{value: USDBAmount}(
        //     params.tokenAddress, tokenAmount, 0, 0, address(this), block.timestamp + 10 minutes
        // );
        // liqAdded = false;
    }

    function claimLP() internal onlyOwner {
        // require(isRaiseClaimed && !liqAdded, "takeUSDBRaised || addliq not called");
        // require(block.timestamp >= lockinPeriod + config.LPLockin, "Lockin period is not over yet");
        // address pair = factory.getPair(router.WETH(), params.tokenAddress);
        // uint256 liquidity = IERC20D(pair).balanceOf(address(this));
        // if (liquidity > 0) IERC20D(pair).transfer(creator, liquidity);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    //                      GETTER FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    function getClaimedAmount(address _address) public view returns (uint256 amountClaimed) {
        // effectively how much can be claimed currently
        amountClaimed = claimedAmount[_address];
    }

    function claimableAmount(address _address) public view returns (uint256 claimable) {
        // this is to calculate the amount of tokens that can be claimed by an address
        claimable = purchasedAmount[_address];
    }

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
