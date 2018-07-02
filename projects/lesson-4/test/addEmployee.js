// Jie You asyn testing function for addEmployee()
// 06/29/2018

// Build an object for Payroll
var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {
  //accounts come from web3 shown in the ganache-cli test terminal
  const owner = accounts[0];
  const employee1 = accounts[1];
  const employee2 = accounts[2];
  const guest = accounts[5];
  const salary = 1;
  const runway = 20;
  const fund = runway * salary;
  const payDuration = (30 + 1) * 86400;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    //Add fund into the small contract
    return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      //add employee1 by owner
      return payroll.addEmployee(employee1, salary, {from: owner});
    }).then(() => {
      return payroll.calculateRunway();
    }).then((runwayRet) => {
      //check the totalSalary is updated successfully
      assert.equal(runwayRet.toNumber(), runway, "The runway is not correct");
    });
  });

  //The first test is to gurantee that the same employee can not be added again by owner
  it("Test call addEmployee() again by owner", () => {
    return payroll.addEmployee(employee1, salary, {from: owner}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot add the same employee again by owner"); 
    });
  });
  
  //The second test is to gurantee that the negative salary can not be accepted
  it("Test calld addEmployee() with negative salary", () => {
    return payroll.addEmployee(employee2, -salary, {from: owner}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Negative salary is not accepted");
    });
  });

  //The third test is to gurantee that we can not add employee address by a guest
  it("Test addEmployee() by guest", () => {
    return payroll.addEmployee(employee2, salary, {from: guest}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Can not call addEmployee() by a guest");
    });
  });

  //The fourth test is to gurantee that gas consumption for each addEmployee() should remain the same
  let gasUsed = -1;
  it("Test gas assumption", async () => {
    for (let i = 2; i < 10; ++i) {
      await payroll.addEmployee(accounts[i], salary, {from: owner});

      const result = await payroll.calculateRunway.estimateGas();
      if (i == 2) {
        gasUsed = result;
      } else {
        assert(gasUsed == result, "Gas consumption for each addEmployee() transaction should not remain the same");
      }
    }
  });
});
