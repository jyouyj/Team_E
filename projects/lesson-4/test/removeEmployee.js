// Jie You asyn testing function for removeEmployee()
// 06/29/2018

// Build an object for Payroll
let Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', (accounts) => {
  const owner = accounts[0];
  const employee = accounts[1];
  const employee2 = accounts[2];
  const guest = accounts[2];
  const salary = 1;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    });
  });

  //The first test is to guarantee that removeEmployee() works well
  it("Test call removeEmployee() by owner", () => {
    // Remove employee
    return payroll.removeEmployee(employee, {from: owner}).then(() => {
      return payroll.getPaid({from: employee});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "The employee has not been moved");
    });
  });

  //The second test is to gurantee that we can not remove employee address by a guest
  it("Test call removeEmployee() by guest", () => {
    return payroll.removeEmployee(employee, {from: guest}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
    });
  });

  //The third test is to remove the non-exist employee address by a owner
  it("Test call removeEmployee() to remove the non-exist address by owner", () => {
    return payroll.removeEmployee(employee2, {from: owner}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() to remove a unexist address by owner");
    });
  });

});