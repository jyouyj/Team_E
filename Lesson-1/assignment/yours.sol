/*作业请提交在这个目录下*/
pragma solidity ^0.4.21;

// 46 + Jie You + Assignment1
//06/17/2018

contract singlePayPoll {
    uint salary = 1 ether; 
    address ceoAddress;
    address employee;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    
    // Constructor to set the ceo address
    function singlePayPoll() public {
        ceoAddress = msg.sender;
    }
    
    // Only ceo can set the employee address
    function setEmployee(address _employee) public {
        if (msg.sender != ceoAddress) {
            revert();
        }
        employee = _employee;
    }
    
    // Check the current employee address
    function currentEmployee() view public returns(address) {
        return employee;
    }
    
    // Add the fund to the contract address
    function addFund() payable public returns (uint) {
        return this.balance;
    }
    
    // Return the remaining pay day.
    function calculateRemain() public returns (uint) {
        return this.balance / salary;
    }
    
    // Check whether the fund is enough or not
    function hasEnoughFund() public returns (bool) {
        return calculateRemain() > 0;
    }
    
    // Get the payment from the contract address
    // Only the setted employee address can obtain the payment
    function getPaid() public {
        if (msg.sender != employee) {
            revert();
        }
        uint nextPay = lastPayDay + payDuration;
        if (nextPay > now) {
            revert();
        }
        lastPayDay = nextPay;
        employee.transfer(salary);
    }
}
