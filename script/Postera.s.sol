// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Postera} from "../src/Postera.sol";

contract PosteraRun is Script {
    function run() external returns (Postera) {
        // Before startBroadcast --> not a "real" tx
        // address EthUsdPrice = helper.activeConfig();

        // After startBroadcast --> a "real" tx
        vm.startBroadcast();
        Postera postera = new Postera();
        vm.stopBroadcast();
        return postera;
    }
}
