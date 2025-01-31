// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // -> prije 'startBrodacast()' nije prava transakcija i nece se potrositi gas
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // -> ova linija gore je napisana ovako zato jer solidity ispravlja i mice zagrade.
        // Trebala je izgledati ovako "(address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();"
        // gdje 'address ethUsdPriceFeed' je stavljena u zagrade zbog toga sto je to 'struct' koji
        //  inace prima vise parametara pa bi i te parametre morali pripisati novim varijablama
        // ali posto imamo samo jednu solidity automatski mice zagrade

        // -> poslije 'startBroadcast()' je prava transakcija i poslace se na chain
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
