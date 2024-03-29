
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
contract TaskList {
    
    // structure storing the task
    struct task{
        string nameTask;   // name's task
        uint32 timestamp;  // time of addition
        bool flag;         // flag of completion of the case
    }

    int8 counterTask; // number of elements in mapping
    mapping (int8 => task) public mapTaskList;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept() {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}
    
    // add a task
    function addTask(string name) public checkOwnerAndAccept() {
        mapTaskList[counterTask] = task(name, now, false);
        counterTask++;
    }

    // get the number of open tasks
    function counterOpenTask() public checkOwnerAndAccept() returns (uint) {
        uint counter = 0;
        for(int8 i = 0; i < counterTask; ++i) {
            if(mapTaskList[i].flag == false) {
                counter++;
            }
        }

        return counter;
    }

    // get a list of tasks
     function taskList() public checkOwnerAndAccept() returns (string[]) {
        string[] tasks;
        for(uint i = 0; i < mapTaskList.length; ++i) {
           if(mapTaskList[i].flag == false) {
               tasks.push(mapTaskList[i].nameTask);
           }
        }

        return tasks;
    }

    // get a description of the task by key
    function taskDescription(int8 number) public checkOwnerAndAccept() returns (string) {
        return mapTaskList[number].nameTask;
    }

    // delete a task by key
    function deleteTask(int8 number) public checkOwnerAndAccept() {
        for(int8 i = number; i < counterTask - 1; ++i) {
            mapTaskList[i] = mapTaskList[i + 1];
        }

        counterTask--;
        delete mapTaskList[counterTask];
    }

    // mark the task as completed by key
    function completeTask(int8 number) public checkOwnerAndAccept() {
        mapTaskList[number].flag = true;
    }
}