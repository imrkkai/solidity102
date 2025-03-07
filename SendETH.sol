// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// solidity有三种方法向其它合约发送ETH
// - transfer
// - send 
// - call 
// call()是被鼓励使用的

// 接收ETH合约
// 我先部署一个接收ETH的合约ReceiveETH。
// 该合约有一个事件Log，记录收到的ETH数量和剩余gas
// 还有另外两个函数
// - 一个是receive（）函数，收到ETH被触发，并发送Log事件
// - 另一个是查询合约ETH余额的getBalance（）函数

contract ReceiveETHTest {
    // 日志事件，记录amount和gas
    event Log(uint amount, uint gas);

    // receive方法，接收ETH时触发
    receive() external payable {
        emit Log(msg.value, gasleft());
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }


}


// 定义SendETH，实现payable的构造函数和receive()
// 让我们能够部署合约时和部署后向合约转账
contract SendETH {
    // 构造函数，payable使得部署合约时可以转ETH进去
    constructor() payable {}


    // receive()方法，接收ETH时被触发
    receive() external payable { }


    // transfer
    // 用法：接收方地址.transfer(发送ETH数量)
    // transfer（）的gas限制2300，足够用于转账，
    // 但对方合约的fallback（）和receive（）函数不能实现太复杂的逻辑
    // transfer()如果转账失败，会自动revert（回滚交易）

    // 使用transfer()发送ETH
    function transferETH(address payable to, uint256 amount) external {
        to.transfer(amount);
    }



    // send
    // 用法：接收方地址.send(发送ETH数量)
    // send()的gas限制2300，足够用于转账，
    // 但对方合约的fallback（）和receive() 不能实现太复杂的逻辑
    // send()如果转账失败，不会revert。
    // send()返回值是bool，代表转账成功或失败，需要额外处理

    // 声明error，用于send发送失败
    error SendFailed();

    // 使用send发送ETH
    function sendETH(address payable to, uint256 amount) external payable  {
        bool success = to.send(amount);
        // 如果失败，revert交易，并发送error
        if(!success) {
            revert SendFailed();
        }
    }

    // call
    // 用法：接收方地址.call{value: 发送ETH数量}("")
    // call没有gas限制，可以支持对方合约fallback或receive（）
    // 实现复杂逻辑
    // call()如果失败，不会revert
    // call（）的返回值是（bool, bytes），其中bool代表着转账成功或失败，需要额外处理

    error CallFailed(); // 用call发送ETH失败
    
    // 使用call（）发送ETH
    function callETH(address payable to, uint256 amount) external  payable {
        (bool success,) = to.call{value: amount}("");
        if(!success) {
            revert CallFailed();
        }
    }

    // 三种方法都可以成功向合约发送ETH
    // - call 没有gas限制，失败不会自动revert，最灵活，最优选择
    // - transfer gas限制为2300，失败会自动revert。次优选择
    // - send gas限制为2300，失败不会自动revert，不推荐使用
}