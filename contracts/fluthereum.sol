// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Fluthereum {
    int public balance;
    
    constructor() {
        balance = 0;
    }
    
    function deposit(int amount) public {
        balance += amount;
    }
    
    function withdraw(int amount) public {
        balance -= amount;
    }
}