// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ---> ovo je contract za oponasanje gdje cemo deployati
// contract-e dok smo na lokalnom anvil chain-u
// ---> pratit cemo adrese contrcat-a na razlicitim chains
// kao na primjer -> Sepolia ETH/USD, Mainnet ETH/USD su dvije razlicite adrese
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIALS_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // -> ovo ce biti ETH/USD price feed adresa
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // -> za ovo ce nam trebati price feed adresa
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // -> za ovo ce nam trebati price feed adresa
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // -> za ovo ce nam isto trebati price feed adresa
        // -> moramo deploy-ati mock smart contract i kada ga deploy-amo na lokalni
        // chain (anvil) moramo 'getAnvilEthConfig-u' priloziti tu adresu
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIALS_PRICE
        );
        // ---> "(8, 2000e8) su parametri koje prima constructor u ugovoru "MockV3Aggregator.sol" i "8"
        // predstavlja decimale a mi znamo da 'ETH/USD' ima 8 decimala, a "2000e8" je proizvoljna
        // cijena koju smo mi stavili gdje smo joj jos samo dodali 8 decimala da cijena bude
        // u istom 'uint-u'. Pritom da ne 'hardcode-amo' i koristimo 'magic numbers'
        // na vrhu contract-a definiramo konstante i dodjelimo im ove vrijednosti.
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
