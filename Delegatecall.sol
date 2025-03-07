// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// delegatecall与call类似，是solidity中地址类型的低级成员函数
// delegate是委托/代表的意思，那么delegatecall委托了什么?

// 当用户 A 通过合约 B 来call合约 C 时，执行的是合约 C 函数
// 上下文(Context，可以理解为包含变量和状态的环境) 也是合约 C 的:
// msg.sender 是 B 的地址，但是如果函数改变一些状态变量，产生的效果会作用于合约C的变量上

// 而当用 A 通过合约 B 来delegatecall合约 C 时，执行的合约 C 的函数，
// 但上下文仍是合约B的：msg.sender 是A的地址，并且如果函数改变一些状态变量，产生的效果会作用于合约B的变量上


// 可以这样理解： 一个投资者 （用户A）把他的资产（B合约的状态变量）都交给一个风险投资代理（C合约）来代理
// 执行的风险投资dialing的函数，但是改变的是资产的状态。

// delegatecall语法和call类似，也是：
// 目标合约地址.delegatecall(二进制编码)
// 其中，二进制变量利用结构化编码函数获取：
// abi.encodeWithSignature("函数签名", 逗号分隔的具体参数);
// 函数签名为：函数名(逗号分隔的参数类型):
// abi.encodeWithSignature("fun(uint256,address)", _x, _address)

// 和call不一样，delegatecall在调用合约时可以指定交易发送的gas，但不能指定发送的ETH数额
// 注意：delegatecall存在安全隐患，使用时要保证当前合约和目标合约的状态变量存储结果相同，且目标合约安全，不然造成资产损失

// 什么情况下会使用到delegatecall?
// 目前delegatecall主要两个应用场景：
// 1.代理合约（Proxy Contract）: 将智能合约的存储合约和逻辑合约分开
//   代理合约（Proxy Contract）存储所有相关的变量, 并且保存逻辑合约的地址，所有函数存在于逻辑合约（Logic Contract）
//   通过delegate执行，当升级时，只需要将代理指向新的逻辑合约即可

// 2.EIP-2535 Diamonds（钻石）: 钻石是一个支持构建可在生产中扩展的模块化智能合约系统的标准.
// 钻石是具有多个实施合约的代理合约https://eip2535diamonds.substack.com/p/introduction-to-the-diamond-standard


// delegatecall示例
// 调用结构：A 通过合约B调用目标合约C


// 声明被调用的目标合约C
// 目标合约C： 
// - 有两个public变量，num和sender, 分别是uint256和address类型；
// - 有一个函数，可以将num设定为传入的_num, 清切将sender设定为msg.sender

contract ContractC {
    uint public num;
    address public sender;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}


// 发起调用的合约B
// 合约B必须和目标合约C的变量存储结构一致，即存在两个public变量且变量类型顺序为uint256和address
// 注意：名称可以不同
// contract ContractB {
//     uint public num;
//     address public sender;
// }

// 接下来，分别用call和delegatecall来调用合约C的setVars函数, 便于更好的理解他们


contract ContractB {
    uint public num;
    address public sender;

    // 通过call调用合约C的setVars()函数, 将改变合约C里的状态变量
    function callSetVars(address _address, uint _num) external payable  {
        // call setVars()
        (bool success, bytes memory data) = _address.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }


    // 通过delegatecall来调用C的setVars函数，将改变合约B里的状态变量
    function delegatecallSetVars(address _address, uint _num) external payable {
        (bool success, bytes memory data) = _address.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

}

// delegatecall 是solidity中另一个低级函数，与call类似，用于调用其他合约
// 不同在于运行上下文：
// - B call C 上下文为C
// - B delegatecall C 上下文B

// delegatecall最大的应用是代理合约和EIP-2535 Diamonds (钻石)