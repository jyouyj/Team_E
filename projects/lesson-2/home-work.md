46_Jie_You_第二次工作分析

1) 调用calculateRunway 10次 Gas的消耗情况:

序号	 execution cost		transaction cost	

+1	    1726		          22998	

+2	    2502		          23774	

+3	    3278		          24550	

+4	    4054		          25326

+5	    4830		          26102	

+6	    5606		          26878	

+7	    6382		          27654	

+8	    7158		          28430

+9	    7934		          29206	

+10	    8710		          29982	

从上面数据可以知道gas消耗再变化，逐步增加。

2）优化calculateRunway函数

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
我们由上述的calculateRunway函数可以看到，随着employee人数增加，函数循环数也有相应的增加，必然会消耗更好的gas。

优化的想法非常直接。
(1) 我们把totalSalary设为状态变量，它将保存记录在smart contract里;

(2) 我们增加一个bool salaryModified; 当salary发生任何变化时候，我们可以把salaryModified = true; 

(3) 只有当salaryModified变化时候我们才重新计算totalSalary，没变化时候直接沿用上次的计算结果。

contract Payroll {

     uint totalSalary;
     bool salaryModified;
     ...
     
     function Payroll() payable public {
        owner = msg.sender;
        totalSalary = 0;
        salaryModified = true;
    }
    
    function addEmployee(address employeeAddress, uint salary) public {
        ...
        salaryModified = true;
    }
    
    function removeEmployee(address employeeId) public {
        ...
        salaryModified = true;
        _partialPay(previousInfo);
    }
    
    function updateEmployee(address employeeAddress, uint salary) public {
        ...
        salaryModified = true;
        _partialPay(_previousInfo);
    }
    
    function calculateRunway() public view returns (uint) {
        if (salaryModified) {
            totalSalary = 0;
            for (uint i = 0; i < employees.length; ++i) {
                totalSalary += employees[i].salary;
            }
            salaryModified = false;
        }
        assert(totalSalary > 0);
        return this.balance / totalSalary;
    }
}
