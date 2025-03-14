// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 利用call来调用合约
// call是address类型的低级别成员函数，它用来与其他合约交互
// 其返回值为(bool, bytes memory) 分别对应是否成功和目标函数的返回值

// - call是solidity官方推荐的通过触发fallback或receive函数发送ETH的方法
// - 不推荐用call来调用另一个合约，因为当调用不安全合约的函数时，
//   主动权交给了它。推荐的方法仍是声明合约变量后调用合约函数
// 当不知道对方合约的源码或者abi时，就没法生成合约变量，这时仍可以通过call调用对方合约的函数

// call使用规则
// 目标合约地址.call(字节码)
// 其中字节码利用结构化编码函数abi.encodeWithSignature获得
// abi.encodeWithSignature("函数签名", 逗号分隔的具体参数)
// 函数签名为函数名(逗号分隔的参数类型)。如
// abi.encodeWithSignature(fun(uint256,address), _x, _addr);

// 另外，call在调用合约时可以指定交易发送的ETH数额和gas数额
// 目标合约地址.call{value:发送数额,gas:gas数额}(字节码)


// 目标合约

contract OtherContract {

    uint256 private _x = 0; // 状态变量

    event Log(uint amount, uint gas);

    fallback() external payable {}
    receive() external payable { }

    // 返回合约ETH余额
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

    // 可以调整状态变量_x的函数，并且可以往合约转ETH (payable)
    function setX(uint256 x) external payable{
        _x = x;
        // 如果转入ETH，则释放Log事件
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }

    function getX() external  view returns(uint256 x) {
        x = _x;
    }

}


// 利用call调用目标合约
// 这里编写一个MyCall合约来调用目标合约函数
contract MyCall {
    // 定义Response事件
    event Response(bool success, bytes data);


    // 定义callSetX函数来调用目标合约的setX（）函数， 转入msg.value数额的ETH, 并发射Response事件输出success和data
    function callSetX(address payable _address, uint256 x) public payable {
        (bool success, bytes memory data) = _address.call{value: msg.value}(abi.encodeWithSignature("setX(uint256)", x));
        emit Response(success, data);
    }

    // 调用getX函数
    function callGetX(address _address) external  returns(uint256) {
        (bool success, bytes memory data) = _address.call(
            abi.encodeWithSignature("getX()")
        );

        emit Response(success, data);
        // data返回为0x0000...000 十六进制的数据，
        // 通过decode进行解码，得到10进制的数值
        return abi.decode(data, (uint256));
    }

    // 调用不存在的函数
    function callNonExist(address _address) external {
        (bool success, bytes memory data) = _address.call(
            abi.encodeWithSignature("foo(unit256)")
        );

        emit Response(success, data);
    }

}


// 使用call低级函数来调用其他合约
// call不是调用合约的推荐方法，因为不安全
// 但他能够在不知道源码和aib的情况下调用目标合约，非常有用