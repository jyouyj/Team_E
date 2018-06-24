pragma solidity ^0.4.14;

// Smart contract HomeWork2
//Jie You, 06/22/2018
//Note that please follow the rule that change the variable first, then transfer the money

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    //uint constant payDuration = 5 seconds;

    //ceo address
    address owner;
    //vector contains all the employees' information
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }

    //Add the new employee information into small contract
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        // Check the salary > 0
        require(salary > 0);
        
        //Find the corresponding information
        var (employee, index) = _findEmployee(employeeAddress);
        assert(employee.id == 0x0);
        
        employees.push(Employee(employeeAddress, 1 ether * salary, now));
    }

    // remove the information of employee from the smart contract
    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        // Find the employee index
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        
        //previousInfo is a temporate variable for partial pay later
        Employee previousInfo = employees[index];
        
        //Delete the employee
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
        
        //Change the informaiton first. Then transfer the money.
        _partialPay(previousInfo);
    }

    //Update the salary of the corresponding employee
    //The unit of salary is ether
    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        // Check the salary > 0
        require(salary > 0);
        
        var (employee, index) = _findEmployee(employeeAddress);
        assert(employee.id != 0x0);
        
       //previousInfo is a temporate variable for partial pay later
        Employee _previousInfo = employees[index];
        
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayDay = now;
        
        //Partially pay the previous salary
        _partialPay(_previousInfo);
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    //calculate the remaining number of payment
    function calculateRunway() public view returns (uint) {
        // Calculate the total salary
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; ++i) {
            totalSalary += employees[i].salary;
        }
        assert(totalSalary > 0);
        return this.balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        // The message senders require their salaries through this function 
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert (nextPayDay < now);
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
    function _findEmployee(address _employeeId) private returns (Employee, uint) {
        for (uint i = 0; i < employees.length; ++i) {
            if (employees[i].id == _employeeId) {
                return (employees[i], i);
            }
        }
    } 
    function _partialPay(Employee _employee) private {
        uint payment =  _employee.salary * (now - _employee.lastPayDay) / payDuration;
        _employee.id.transfer(payment);
    }
}
