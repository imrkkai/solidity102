// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 调用其它合约
// 在solidity，一个合约可以调用另一个合约的函数,这在构建复杂的Dapps时非常有用。
// 这里，我将展示如何通过抑制合约代码（或接口）和地址的情况下，调用已部署的合约

// 目标合约
// 实现一个简单合约OtherContract，用于被其他合约调用
// 该合约包含一个状态变量_x，一个事件Log，在收到ETH时触发，三个函数
// - getBalance(): 返回合约ETH余额
// - setX(): external payable函数，可以设置_x的值，并向合约发送ETH
// - getX(): 获取_x的值
contract OtherContract {
    uint256 private _x = 0; // 状态变量x
    // 收到eth的事件，记录amount和gas
    event Log(uint256 amount, uint gas);

    // 返回合约ETH余额
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable {
        _x = x;
        if(msg.value> 0) {
            emit Log(msg.value, gasleft()); // 发送eth事件
        }
    }
    
    function getX() public view returns (uint x){
        x = _x;
    }
}



// 调用OtherContract合约
// 可以利用合约地址和合约代码（或接口）来创建合约的引用:
// _ContractName(_ContractAddress)
// 其中_ContractName为合约名称 与合约代码（或接口）中标注的合约名称保持一致
// _ContractAddress为合约地址
// 通过合约的引用来调用其函数：
// _ContractName(_ContractAddress).fun()
// 其中，fun()是要调用的函数

contract CallContract {
    
    // 1.传入合约地址
    // 可以在函数中传入目标合约地址，生成目标合约引用，调用目标函数 
    function callSetX(address contractAddress, uint256 x) external {
        OtherContract(contractAddress).setX(x);
    }

    // 2.传入合约变量
    function callGetX(OtherContract otherContract) external view returns(uint256) {
        return otherContract.getX();
    }

    // 3. 创建合约变量
    function callGetX2(address _address) external view returns (uint x){
        OtherContract otherContract = OtherContract(_address);
        return otherContract.getX();
    }


    // 4.调用合约并发数ETH
    // 如果目标合约的函数是payable，那么可以直接调用它来给合约转账
    // _ContractName(_ContractAddress).fun{value: _Value}()

    function setXTransferETH(address otherContract, uint256 x) external payable {
        OtherContract(otherContract).setX{value: msg.value}(x);
    }


}