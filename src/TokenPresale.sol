// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {Pausable} from "openzeppelin/utils/Pausable.sol";

interface ILaunchpad {
    event TokensPurchased(address indexed _token, address indexed buyer, uint256 amount, uint256 price);
    event TokensClaimed(address indexed _token, address indexed buyer, uint256 amount);
    event EthPricePerTokenUpdated(address indexed _token, uint256 newEthPricePerToken);
    event WhitelistUpdated(uint256 wlBlockNumber, uint256 wlMinBalance, bytes32 wlRoot);
    event MerkleRootUpdated(bytes32 wlRoot);
    event TokenHardCapUpdated(address indexed _token, uint256 newTokenHardCap);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event VestingDurationUpdated(uint256 newVestingDuration);
    event EthWithdrawn(address indexed _user, uint256 _userAmount, uint256 _feeAmount);
    event VestingScheduleUpdated(uint256[] durations, uint256[] percentages);

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

    // Define a struct for tiered pricing
    struct Tier {
        uint256 threshold;
        uint256 price;
    }

    struct VestingSchedule {
        uint256 releaseTime;
        uint256 percentage;
    }
}

contract TokenPresale is ILaunchpad, Ownable, Pausable {
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
    Tier[] public tiers;
    VestingSchedule[] public vestingSchedules;

    mapping(address => uint256) public purchasedAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => bool) public hasClaimed;

    bool public saleFinalized;

    uint256 minTokenPrice = 0.025 ether;
    uint256 maxTokenPrice = 0.5 ether;

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
    function buyTokens(bytes32[] calldata proof, uint256 amount) external payable whenNotPaused {
        require(block.timestamp > startDate, "Sale has not started");
        require(block.timestamp <= endDate, "Sale has ended");

        address sender = msg.sender;

        require(amount > amount * ethPricePerToken); // require sender send enough value
        // check if presale has started and ended
        require(block.timestamp > startDate);

        // cache the msg.sender for gas savings, and referencing later on

        bytes32 leaf = keccak256(abi.encodePacked(sender));
        bool verificationStatus = MerkleProof.verify(proof, wlRoot, leaf);
        require(verificationStatus, "Not Whitelisted");

        uint256 price = getCurrentPrice();
        uint256 tokensToReceive = amount * price;
        require(tokensToReceive <= tokenHardCap - totalPurchasedAmount, "Exceeds hard cap");

        purchasedAmount[sender] += amount;
        totalPurchasedAmount += amount;

        bytes memory data = abi.encodeWithSignature("transfer(address, uint256)", address(this), amount);
        (bool success,) = address(WETH).call{value: msg.value}(data);
        require(success, "Transfer failed");
        emit TokensPurchased(address(0), sender, amount, getCurrentPrice());
    }

    //@dev This implementation allows for multiple vesting periods with different release percentages.
    // The owner can set the vesting schedule using the setVestingSchedule function.
    // The claimTokens function now calculates the claimable amount based on the current time and the vesting schedule.
    function claimTokens() external whenNotPaused {
        // check user has something to claim
        require(!hasClaimed[msg.sender], "already claimed");
        require(block.timestamp > endDate, "Vesting period not started");

        uint256 totalClaimable;

        uint256 purchasedTokens = purchasedAmount[msg.sender];

        for (uint256 i = 0; i < vestingSchedules.length; i++) {
            if (block.timestamp >= endDate + vestingSchedules[i].releaseTime) {
                uint256 claimAmount = (purchasedTokens * vestingSchedules[i].percentage) / 100;
                totalClaimable += claimAmount;
            }
        }

        totalClaimable -= claimedAmount[msg.sender];
        require(totalClaimable > 0, "No tokens available to claim");

        claimedAmount[msg.sender] += totalClaimable;

        bytes memory data = abi.encodeWithSignature("transfer(address, uint256)", msg.sender, totalClaimable);
        (bool success,) = address(WETH).call(data);
        require(success, "Token transfer failed");

        emit TokensClaimed(address(WETH), msg.sender, totalClaimable);

        if (claimedAmount[msg.sender] == purchasedTokens) {
            hasClaimed[msg.sender] = true;
        }
    }

    function withdrawEth() external whenNotPaused {
        require(purchasedAmount[msg.sender] != 0, "Nothing to withdraw");
        require(block.timestamp > endDate || saleFinalized, "Sale not ended or finalized");

        uint256 claimAmount = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;

        uint256 feeAmount = (claimAmount * protocolFee) / 10000; // Assuming protocolFee is in basis points
        uint256 userAmount = claimAmount - feeAmount;

        (bool successUser,) = msg.sender.call{value: userAmount}("");
        require(successUser, "User transfer failed");

        (bool successFee,) = protocolFeeAddress.call{value: feeAmount}("");
        require(successFee, "Fee transfer failed");

        emit EthWithdrawn(msg.sender, userAmount, feeAmount);
    }

    function refund() external whenNotPaused {
        // Implement refund mechanism if sale doesn't reach minimum goal
    }

    function transferPurchasedOwnership(address _newOwner) external {
        require(_newOwner != address(0), "Cant allow yoooou burn tokens dawg");
        require(purchasedAmount[msg.sender] != 0, "you need to own some tokens first");
        // check the address is not address(0), to prevent accidental or malicious burning of tokens
        // set purchasedAmount for _newOwner to the current purchasedAmount value for msg.sender
        // add the purchasedAmount value for msg.sender to the purchasedAmount for _newOwner
        // set purchasedAmount for msg.sender to 0
        uint256 prevOwnerAmount = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;
        purchasedAmount[_newOwner] = prevOwnerAmount;
        // emit event
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    //                      OWNER FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    function finalizeSale() external onlyOwner {
        // Allow early finalization if hard cap is reached
    }

    function setTiers(uint256[] memory thresholds, uint256[] memory prices) external onlyOwner {
        require(thresholds.length == prices.length, "Mismatched input lengths");
        delete tiers;
        for (uint256 i = 0; i < thresholds.length; i++) {
            tiers.push(Tier(thresholds[i], prices[i]));
        }
    }

    function setTieredPricing(uint256[] memory _tiers, uint256[] memory _prices) external onlyOwner {
        // Set tiered pricing structure
    }

    function updateEthPricePerToken(uint256 _ethPricePerToken) public onlyOwner {
        require(_ethPricePerToken != 0, "Price cannot be zero");
        require(_ethPricePerToken >= minTokenPrice, "Price too low");
        require(_ethPricePerToken <= maxTokenPrice, "Price too high");

        ethPricePerToken = _ethPricePerToken;
        emit EthPricePerTokenUpdated(address(WETH), _ethPricePerToken);
    }

    function increaseHardCap(uint256 _tokenHardCapIncrement) public onlyOwner {
        // This implementation adjusts the hard cap dynamically based on the elapsed time of the sale.
        // It allows for a maximum increase of 20% of the initial hard cap, with the allowed increase growing linearly over time.
        // The function ensures that the actual increase doesn't exceed the allowed increase based on the current time.
        uint256 elapsedTime = block.timestamp - startDate;
        uint256 totalDuration = endDate - startDate;
        uint256 maxIncrease = (tokenHardCap * 20) / 100; // 20% max increase

        uint256 allowedIncrease = (maxIncrease * elapsedTime) / totalDuration;
        uint256 actualIncrease = _tokenHardCapIncrement > allowedIncrease ? allowedIncrease : _tokenHardCapIncrement;

        tokenHardCap += actualIncrease;
        emit TokenHardCapUpdated(address(WETH), tokenHardCap);
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

    function setVestingSchedule(uint256[] memory durations, uint256[] memory percentages) external onlyOwner {
        // This implementation allows the owner to set multiple vesting periods, each with its own duration and release percentage.
        //  It ensures that the total percentage equals 100% and that all durations and percentages are greater than zero.
        //  The function also emits an event to log the updated vesting schedule.
        require(durations.length == percentages.length, "Mismatched input lengths");
        require(durations.length > 0, "At least one vesting period required");

        delete vestingSchedules;
        uint256 totalPercentage = 0;

        for (uint256 i = 0; i < durations.length; i++) {
            require(durations[i] > 0, "Duration must be greater than 0");
            require(percentages[i] > 0, "Percentage must be greater than 0");
            totalPercentage += percentages[i];
            vestingSchedules.push(VestingSchedule(durations[i], percentages[i]));
        }

        require(totalPercentage == 100, "Total percentage must equal 100");

        emit VestingScheduleUpdated(durations, percentages);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/
    //                      VIEW FUNCTIONS
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´*/

    function getCurrentPrice() public view returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (totalPurchasedAmount < tiers[i].threshold) {
                return tiers[i].price;
            }
        }
        return tiers[tiers.length - 1].price;
    }

    function ethToToken(uint256 ethAmount) public view returns (uint256 tokenAmount) {
        uint256 currentPrice = getCurrentPrice();
        tokenAmount = (ethAmount * 1e18) / currentPrice;
        return tokenAmount;
    }

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
