/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll{
    uint constant payDuration = 10 seconds;
    
    address owner;
    address employee = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    uint salary = 1 ether;
    uint lastPayDay = now;
    
    function Payroll() payable {
        owner = msg.sender;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function changeEmployeeAddress(address e) {
        employee = e;
    }
    
    function changeEmployeeSalary(uint s) {
        salary = s * 1 ether;
    }
    
    // function getEmployee() returns (address){
    //     return employee;
    // }
    
    // function getSalary() returns (uint){
    //     return salary;
    // }
    
    function getPaid() {
        if (msg.sender != employee)
        {
            revert();
        }
        
        uint nextPayDay = lastPayDay + payDuration;
        
        if (nextPayDay>now){
            revert();
        }
        
        lastPayDay = nextPayDay;
        employee.transfer(salary);
    }

       
}