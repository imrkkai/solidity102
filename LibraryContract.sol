// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 库合约
// 库合约是一种特殊的合约, 未了提升solidity代码的复用性和减少gas而存在
// 库合约是一系列函数的集合，有第三方（大神或项目方）提供，可以直接引用即可。
// 站在巨人的肩膀上

// 库合约跟其他普通合约主要有一下不同：
// - 不能存在状态变量
// - 不能够继承或被继承
// - 不能接受以太币
// - 不可以被消耗

// 需要注意的是 库合约中的函数可见性如被设置为public或者external
// 则在调用函数时会触发一次delegatecall。
// 而被设置为internal则不会触发。对于设置为private可见性的函数来说
// 其仅能在库合约中可见，在其他合约中不可用

// 这里，我们使用ERC721合约引用的库合约Strings为例。

// Strings库合约
// Strings库合约是将uint256类型转换为相应的string类型的代码库，样例代码如下：

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) public pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// Strings库合约，它主要包含两个函数，toString()将uint256转换为10进制的string，toHexString()将uint256转换为16进制的string。


// 如何使用库合约

// 我们使用Strings库合约的toHexString()来演示两种使用库合约中函数的方法
// 1. 使用using for指令 指令 using A for B; 可用于附加库合约（从库A）到任何类型（B）
//    添加玩指令后，库A中的函数会自动添加为B类型变量的成员,可以直接调用。
// 注意，调用时，这个变量会被当作第一个参数传递给函数

// 2.通过库合约名称调用
// Strings.toHexString(_number)

using Strings for uint256;
contract LibraryContract {
    // 方法1
    function getHexString1(uint256 _number) public pure returns(string memory) {
        return _number.toHexString();
    }
    
    function getHexString2(uint256 _number) public pure returns(string memory) {
        return Strings.toHexString(_number);
    }
}

// 常用的库合约
// - Strings 将uint256转化为String
// - Address 判断某个地址是否为合约地址
// - Create2 更安全的使用Create2 EVM opcode
// - Arrays 跟数组相关的库合约