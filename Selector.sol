// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// msg.data 是Solidity中的一个全局变量，值为完成的calldata（调用函数时传入的数据）

// method id、selector和函数签名
// - method id 为函数签名的keccak哈希后的前4个字节，当selector与method id相匹配时，即表示调用该函数
// - 函数签名 函数名(逗号分隔的类型参数)
// - 在同一个智能合约中，不同的函数有不同的函数签名，因此可以通过函数签名来确定要调用哪个函数

// 注意： 在函数签名中, uint 和 int要写成 uint256 和 int256


// 由于计算method id时，需要通过函数名和函数的参数类型来计算
// 在Solidity中，函数的参数类型主要分为： 基础类型参数、固定长度类型参数、可变程度类型参数、映射类型参数


contract DemoContract {

}





contract Selector {
    event Log(bytes data);

    // 基础类型参数
    // - uint256(uint8, ..., uint256)
    // - bool
    // - address

    // 在计算method id时，只需要计算bytes4(keccak("函数名(参数类型1, 参数类型2, ...)"))
    // 如函数名为elementaryParamSelector,参数类型分别为uint256和bool。则只需要计算
    // bytes4(keccak256("elementaryParamSelector(uint256, bool)")) 即可得到该函数的
    // method id

    function mint(address to) external {
        emit Log(msg.data);
    }
    // 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
    // 0x6a6278420000000000000000000000002c44b726adf1963ca47af88b284c06f30380fc78

    function mintSelector() external  pure returns(bytes4 selector) {
        return bytes4(keccak256("mint(address)"));
    }

    event SelectorEvent(bytes4 selector);

     // elementary（基础）类型参数selector
    // 输入：param1: 1，param2: 0
    // elementaryParamSelector(uint256,bool) : 0x3ec37834
    function elementaryParamSelector(uint256 param1, bool param2) external returns(bytes4 selectorWithElementaryParam){
        emit SelectorEvent(this.elementaryParamSelector.selector);  
        return bytes4(keccak256("elementaryParamSelector(uint256,bool)"));
    }


    // 固定长度类型参数
    // 固定长度的参数类型通常为固定长度的数组，例如：uint256[5]
    // 如fixedSizeParamSelector函数，其参数为uint256[3],因此计算该函数的method id时，
    // 只需要通过bytes4(keccak256)

    // fixed size（固定长度）类型参数selector
    // 输入： param1: [1,2,3]
    // fixedSizeParamSelector(uint256[3]) : 0xead6b8bd
    function fixedSizeParamSelector(uint256[3] memory param1) external returns(bytes4 selectorWithFixedSizeParam){
        emit SelectorEvent(this.fixedSizeParamSelector.selector);
        return bytes4(keccak256("fixedSizeParamSelector(uint256[3])"));
    }



    // 可变长度类型参数
    // 可变长度参数类型通常为可变长的数组，例如：address[], uint8[], string 等
    // 如nonFixedSizeParamSelector函数，其参数为uint256[] 和string。因此，计算该函数的method id时，
    // 只需要通过bytes4(keccak256("nonFixedSizeParamSelector(uint256[],string)")) 即可。

    // non-fixed size（可变长度）类型参数selector
    // 输入： param1: [1,2,3]， param2: "abc"
    // nonFixedSizeParamSelector(uint256[],string) : 0xf0ca01de
    function nonFixedSizeParamSelector(uint256[] memory param1,string memory param2) external returns(bytes4 selectorWithNonFixedSizeParam){
        emit SelectorEvent(this.nonFixedSizeParamSelector.selector);
        return bytes4(keccak256("nonFixedSizeParamSelector(uint256[],string)"));
    }

    // 映射类型参数
    // 映射类型参数通常有：contract、Enum、struct等，在计算method id时，需要将该类型转换为ABI类型

    // 如：mappingParamSelector函数，参数类型DemoContract需要转换为address，结构体User需要转换为tuple类型(uint256, bytes)
    // 枚举类型Side需要转化为uint8。因此计算该函数的method id的代码为
    // bytes4(keccak256("mappingParamSelector(address,(uint256,bytes),uint256[],uint8)"))

    struct User {
        uint256 uid;
        bytes name;
    }

    enum Side { BUY, SELL}

    function mappingParamSelector(DemoContract demo, User memory user, uint256[] memory count, Side side) 
    external returns(bytes4 selectorWithMappingParam){
        emit SelectorEvent(this.mappingParamSelector.selector);
        return bytes4(keccak256("mappingParamSelector(address,(uint256,bytes),uint256[],uint8)"));
    }



    // 使用selector
    // 我们可以利用selector来调用目标函数
    // 例如想要调用elementaryParamSelector函数
    // 只需要利用abi.encodeWithSelector将elementaryParamSelector函数的method id作为
    // selector 和参数打包编码，传给call函数

    // 使用selector来调用函数
    function callWithSignature() external returns (bool success, bytes memory data){
        (bool success, bytes memory data) = address(this).call(abi.encodeWithSelector(0x3ec37834, 1, true));

    }


}