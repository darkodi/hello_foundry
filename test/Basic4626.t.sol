// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "forge-std/Test.sol";

interface ITestERC20 {
    function balanceOf(address owner_) external view returns (uint256);
    function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(address to_, uint256 amount_) external;
}

contract Basic4626Deposit {

    /**********************************************************************************************/
    /*** Storage                                                                                ***/
    /**********************************************************************************************/

    address public immutable asset;

    string public name;
    string public symbol;

    uint8 public immutable decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    /**********************************************************************************************/
    /*** Constructor                                                                            ***/
    /**********************************************************************************************/

    constructor(address asset_, string memory name_, string memory symbol_, uint8 decimals_) {
        asset    = asset_;
        name     = name_;
        symbol   = symbol_;
        decimals = decimals_;
    }

    /**********************************************************************************************/
    /*** External Functions                                                                     ***/
    /**********************************************************************************************/

    function deposit(uint256 assets_, address receiver_) external returns (uint256 shares_) {
        shares_ = convertToShares(assets_);

        require(receiver_ != address(0), "ZERO_RECEIVER");
        require(shares_   != uint256(0), "ZERO_SHARES");
        require(assets_   != uint256(0), "ZERO_ASSETS");

        totalSupply += shares_;

        // Cannot overflow because totalSupply would first overflow in the statement above.
        unchecked { balanceOf[receiver_] += shares_; }

        require(
            ITestERC20(asset).transferFrom(msg.sender, address(this), assets_),
            "TRANSFER_FROM"
        );
    }

    function transfer(address recipient_, uint256 amount_) external returns (bool success_) {
        balanceOf[msg.sender] -= amount_;

        // Cannot overflow because minting prevents overflow of totalSupply,
        // and sum of user balances == totalSupply.
        unchecked { balanceOf[recipient_] += amount_; }

        return true;
    }

    /**********************************************************************************************/
    /*** Public View Functions                                                                  ***/
    /**********************************************************************************************/

    function convertToShares(uint256 assets_) public view returns (uint256 shares_) {
        uint256 supply_ = totalSupply;  // Cache to stack.

        shares_ = supply_ == 0 ? assets_ : (assets_ * supply_) / totalAssets();
    }

    function totalAssets() public view returns (uint256 assets_) {
        assets_ = ITestERC20(asset).balanceOf(address(this));
    }

}

contract DepositHandler {
    ITestERC20 asset;
    Basic4626Deposit token;

    constructor(address assetAddress, address tokenAddress) {
        asset = ITestERC20(assetAddress);
        token = Basic4626Deposit(tokenAddress);
    }

    function depositHandler(uint256 assets) public {
        // Mint the required ERC-20 tokens to this contract
        asset.mint(address(this), assets);

        // Approve the `Basic4626Deposit` contract to spend the tokens
        asset.approve(address(token), assets);

        // Make the deposit call to the `Basic4626Deposit` contract
        token.deposit(assets, address(this));
    }

    // Additional functions...
}

contract TestERC20 is ITestERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) public override {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(balanceOf[from] >= amount, "ERC20: transfer amount exceeds balance");
        require(allowance[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Basic4626DepositTest is Test {
    ITestERC20 testToken;
    Basic4626Deposit basicDeposit;
    DepositHandler depositHandler;

    function setUp() public {
        // Deploy the test ERC20 token
        testToken = new TestERC20("Test Token", "TT", 18); // TestERC20 is an ERC20 implementation with mint function

        // Deploy the Basic4626Deposit contract
        basicDeposit = new Basic4626Deposit(address(testToken), "Test Token", "TT", 18);

        // Deploy the DepositHandler with references to the test token and the Basic4626Deposit contract
        depositHandler = new DepositHandler(address(testToken), address(basicDeposit));
    }

    function testDepositFlow() public {

        uint256 depositAmount = 100 * 1e18; // 100 tokens

        // Use DepositHandler to mint tokens and make a deposit
        depositHandler.depositHandler(depositAmount);

        // Check that the Basic4626Deposit contract received the deposit
        assertEq(basicDeposit.totalAssets(), depositAmount);

        // Additional assertions can be added to validate the behavior of the deposit
    }
}


