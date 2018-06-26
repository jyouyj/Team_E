pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

// Smart contract HomeWork3
//Jie You, 06/25/2018
//Note that please follow the rule that change the variable first, then transfer the money

contract Payroll is Ownable {
    
    using SafeMath for uint;
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    //uint constant payDuration = 5 seconds;

    uint public totalSalary;
    
    //ceo address
    address owner;
    //vector contains all the employees' information
    mapping(address => Employee) public employees;
    
    
    modifier employeeExist(address employeeAddress) {
        var employee = employees[employeeAddress];
        assert(employee.id != address(0));
        _;
    }
    
    modifier addressNotExist(address employeeAddress) {
        require(employeeAddress != address(0));
        var employee = employees[employeeAddress];
        assert(employee.id == address(0));
        _;
    }
    
    modifier checkValidAddress(address oldAddress, address newAddress)  {
        require(oldAddress != newAddress);
        _;
    }
    
    function Payroll() payable public {
        owner = msg.sender;
    }

    //Add the new employee information into small contract
    function addEmployee(address employeeAddress, uint salary) 
             public 
             onlyOwner 
             addressNotExist(employeeAddress) {
        require(int(salary) > 0);
        employees[employeeAddress] = Employee(employeeAddress, salary.mul(1 ether), now);
        totalSalary = totalSalary.add(employees[employeeAddress].salary);
    }

    // remove the information of employee from the smart contract
    function removeEmployee(address employeeAddress) 
              public 
              onlyOwner employeeExist(employeeAddress) {
                  
        Employee memory employee = employees[employeeAddress];     

        uint salary = employees[employeeAddress].salary;
        delete employees[employeeAddress];

        totalSalary = totalSalary.sub(salary);
        
        _partialPay(employee);
    }
    
    
    
    //Change the payment address of employees
    //There are three modifiers
    //1) msg.sender must be the owner
    //2) newAddress can not be empty and it should be an existing address
    //3) msg.sender == oldAddress && oldAddress == msg.sender
    function changePaymentAddress(address oldAddress, address newAddress) 
             public 
             onlyOwner
             addressNotExist(newAddress) 
             checkValidAddress(oldAddress, newAddress) {
        
        uint oldSalary = employees[oldAddress].salary;
        uint oldLastPayDay = employees[oldAddress].lastPayDay;
    
        delete employees[oldAddress];
        
        employees[newAddress] = Employee(newAddress, oldSalary, oldLastPayDay);
    }

    //Update the salary of the corresponding employee
    //The unit of salary is ether
    function updateEmployee(address employeeAddress, uint salary) 
             public 
             onlyOwner employeeExist(employeeAddress) {
        //salary > 0 and avoid overflow
        require(int(salary) > 0);
        
        Employee memory employee = employees[employeeAddress];
        
        totalSalary = totalSalary.sub(employees[employeeAddress].salary);
        employees[employeeAddress].salary = salary.mul(1 ether);
        employees[employeeAddress].lastPayDay = now;
        totalSalary = totalSalary.add(salary.mul(1 ether));
        
        //Partially pay the previous salary
        _partialPay(employee);
    }

    function addFund() 
             payable public 
             returns (uint) {
        return address(this).balance;
    }

    //calculate the remaining number of payment
    function calculateRunway() 
             public view 
             returns (uint) {
        // Calculate the total salary
        assert(totalSalary > 0);
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() 
             public view 
             returns (bool) {
        return calculateRunway() >= totalSalary;
    }

    function getPaid() 
             public  
             employeeExist(msg.sender) {
        // The message senders require their salaries through this function 
        var employee = employees[msg.sender];
    
        uint nextPayDay = employee.lastPayDay.add(payDuration);
        assert (nextPayDay < now);
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
    function _partialPay(Employee employee) 
             internal {
        uint payment =  employee.salary.mul(now.sub(employee.lastPayDay))
                        .div(payDuration);
        employee.id.transfer(payment);
    }
}
