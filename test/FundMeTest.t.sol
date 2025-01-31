// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("User");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 1000 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // ---> govori nam da sljedeca linija ne smije uspjeti
        // sto bih ovdje znacilo da se ocekuje da sljedeca linija nece ispuniti
        // zadane uvjete u funkciji "fund()" i znaci da ce test proci na testiranju
        fundMe.fund(); // ---> funkciji "fund()" nismo pridodali niti jedan parametar
        // namjerno da nam ugradena funkcija "vm.expectRevert()" odradi za ono sto je
        // smisljena
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrwWithASingleFunder() public funded {
        // Arrangge
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // ---> ARRANGE
        uint160 numberOfFunders = 10; // -> "uint160" jer kreiramo adrese brojevima
        uint160 startingFunderIndex = 1; // krecemo s 1 jer ako krecemo s 0 ponekad
        // se funkcija revert-a zbog provjera
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank -> kreiramo novu adresu
            // vm.deal -> dodjeljujemo novoj adresi balance
            // address() -> ako zelimo kreirati adrese s brojevima
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund contract fundMe
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // ---> ARRANGE
        uint160 numberOfFunders = 10; // -> "uint160" jer kreiramo adrese brojevima
        uint160 startingFunderIndex = 1; // krecemo s 1 jer ako krecemo s 0 ponekad
        // se funkcija revert-a zbog provjera
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank -> kreiramo novu adresu
            // vm.deal -> dodjeljujemo novoj adresi balance
            // address() -> ako zelimo kreirati adrese s brojevima
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund contract fundMe
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
