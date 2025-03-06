// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// solidity支持两种特殊的回调函数 receive和fallback，它们主要在两种情况下被使用
// 1. 接收ETH
// 2. 处理合约中不存在的函数调用（代理合约proxy contract）

// 在solidity0.6.x之前，语法上只有fallback（）函数, 用来接受用户发送的ETH时调用
// 以及在被调用函数签名没有匹配时调用。
// 在0.6版本之后，solidity才将fallback()函数拆分为receive()和fallback()两个函数

// 接收ETH函数的receive
// receive（）函数是在合约收到ETH转账时被调用的函数，一个合约最多有一个receive（）函数，
// 声明方式与一般函数不一样，不要function关键字:
// receive() external payable {...}
// receive()函数不能有任何参数，不能返回任何值，必须包含external和payable
// 当合约接受ETH的时候，receive（）会被触发。receive（）最好不要执行太多的逻辑，
// 因为如果别人用send和transfer方法发送ETH的话，gas会限制在2300，receive（）太复杂可能会触发Out of Gas错误
// 如果用call就可以自定义gas执行更加复杂的逻辑（这三种发生ETH的方式之后会讲到）

contract ReceiveETH {
    // 定义事件
    event Received(address Sender, uint Value);

    // 接收ETH时触发Received事件
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // 有些恶意合约，会在receive（）函数嵌入恶意消耗gas的内容或者zhix恶意失败的代码，
    // 导致一些包含退款和转账逻辑的合约不能正常工作，因此写包含退款等逻辑的合约是，一定要注意此类情况


    // 回退函数 fallback
    // fallback() 函数会再调用合约不存在的函数时被触发。可用于接收ETH，也可以用于代理合约proxy contract。
    // fallback（）声明时不需要function关键字，必须有external修饰，一般也会用payable修饰. 用于接收ETH
    // fallback() external payable { ... }

    event FallbackCalled(address Sender, uint Value, bytes Data);
    
    // fallback
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data); 
    }


    // receive和fallback的区别
    // receive和fallback都能够用于接收ETH, 触发规则如下:
    /*
    触发fallback() 还是 receive()?
           接收ETH
              |
         msg.data是空？
            /  \
          是    否
          /      \
receive()存在?   fallback()
        / \
       是  否
      /     \
receive()   fallback()
*/

// 简单来说，合约接收ETH时，msg.data为空且存在receive（）时，会触发receive();
// msg.data不为空或不存在receive()时，会触发fallback（）, 此时fallback（）必须为payable。

// payable fallback() 均不存在时，向合约直接发送ETH将会保存（你仍可以通过带有payable的函数向合约发送ETH）




}