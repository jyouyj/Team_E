/*作业请提交在这个目录下*/
pragma solidity ^0.4.21;

// 46 + Jie You + First HomeWork
// In this new version, I add the function for reseting the salary and resumbit it again
//06/17/2018

contract singlePayPoll {
    uint salary; 
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
        address temp = employee;
        employee = _employee;
        
        partialPay(temp);
    }
    
    // Set the salary
    function setSalary(uint _salary) public returns (uint){
        // Only ceo can set the salary
        if (msg.sender != ceoAddress) {
            revert();
        }
        // Salary should be greater than zero
        require(_salary > 0);
        salary = _salary * 1 ether;
        return salary;
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
        require(salary > 0);
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
    
    function _partialPay(address _employee) private {
        uint payment =  salary * (now - lastPayDay) / payDuration;
        _employee.id.transfer(payment);
    }
}
