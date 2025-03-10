// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 哈希函数(hash function) 是一个密码学概念，它可以将任意长度的消息转换为一个固定长度的值，这个值成为哈希（hash）。

// 哈希的性质
// - 单向性
// - 灵敏性
// - 高效性
// - 均一性
// - 抗碰撞性
// - 不可逆性


// 哈希的应用
// - 生成数据唯一标识
// - 加密签名
// - 安全加密

// Keccack256
// Keccack256函数是Solidity中最常用的哈希函数，用法非常简单：
// 哈希 = keccack256(数据)

// - 生成数据唯一标识

contract Hash {

    bytes32 public _msg = keccak256(abi.encodePacked("0xAA"));
    bytes32 public _temp;
    
    function hash(uint _num, string memory _string, address _address)  
    public pure returns(bytes32){
        return keccak256(abi.encodePacked(_num, _string, _address));
    }

    function week(
        string memory _string
    ) public returns(bool) {
        return (_temp = keccak256(abi.encodePacked(_string))) == _msg;
    }

    // 强抗碰撞性
    function strong(
            string memory string1,
            string memory string2
        )public pure returns (bool){
        return keccak256(abi.encodePacked(string1)) == keccak256(abi.encodePacked(string2));
    }

}