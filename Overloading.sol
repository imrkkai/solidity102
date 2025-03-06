// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 函数重载
// 在Solidity中允许函数进行重载（overloading）, 即名字相同但输入参数类型不同的函数可以同时存在
// 它们被视为不同的函数
// 注意：Solidity不允许修饰器Modifier重载


contract Overloading {

    // 这里定了两个都叫add()的函数，一个携带两个参数，一个携带三个参数

    function add(uint a, uint b) public  pure returns (uint result) {
        return a + b;
    }

    function add(uint a, uint b, uint c) public pure returns (uint result) {
        return a + b + c;
    }

    // 重载函数经过编译器编译后，由于不同的参数类型，都变成了不同的函数选择器（selector）


    // 参数匹配
    // 在调用重载函数时，会吧传入的实际参数和函数惨的类型做匹配
    // 如果出现多个匹配的重载函数，则会报错
    // 这里，在声明两个fun()的函数, 一个参数为uint8, 一个参数为uint256
    // 没见报错??
    function fun(uint8 a) public pure returns(uint8 out){
        out = a;
    }

    function fun(uint256 a) public pure returns(uint256 out) {
        out = a;
    }

    function fun(string memory a) public pure returns(string memory) {
        return a;
    }

}