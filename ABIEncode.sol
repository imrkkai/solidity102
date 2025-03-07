// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// ABI （应用二进制接口）
// ABI 是与以太坊智能合约交互的标准。数据基于他们的类型编码, 并且由于编码后不包含类型信息，解码
// 需要注明他们的类型

// Solidity中，ABI编码有4个函数：
// - abi.encode 
// - abi.encodePacked
// - abi.encodeWithSignature
// - abi.encodeWithSelector

// 而ABI解码有一个函数
// - abi.decode 用于解码abi.encode的数据


// ABI编码
// 我们将编码4个变量，他们的类型分别是uint256（别名 uint）, address, string, uint256[2]：
/*
uint x = 10;
address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
string name = "0xAA";
uint[2] array = [5, 6]; 
*/

// abi.encode
// 将给定的参数利用ABI规则编码
// ABI被设计出来跟智能合约交互，它将每个参数填充为32字节的数据，并拼接在一起。
// 如果要和合约交互，要用的就是abi.encode
// result = abi.encode(x, addr, name, array);
//0x000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
/*
000000000000000000000000000000000000000000000000000000000000000a    // x
0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c71    // addr
00000000000000000000000000000000000000000000000000000000000000a0    // name 参数的偏移量
0000000000000000000000000000000000000000000000000000000000000005    // array[0]
0000000000000000000000000000000000000000000000000000000000000006    // array[1]
0000000000000000000000000000000000000000000000000000000000000004    // name 参数的长度为4字节
3078414100000000000000000000000000000000000000000000000000000000    // name
*/

// 其中 name 参数被转换为UTF-8的字节值 0x30784141，
// 在 abi 编码规范中，string 属于动态类型 ，动态类型的参数需要借助偏移量进行编码，可以参考动态类型的使用。
// 由于 abi.encode 会将每个参与编码的参数元素（包括偏移量，长度）都填充为32字节（evm字长为32字节），
// 所以可以看到编码后的数据中有很多填充的 0 。


// abi.encodePacked
// 将给定参数根据其所需最低空间编码, 它类似 abi.encode。但是会把其中填充的很多0省略。
// 只用1字节来编码uint8类型。
// 当你想省空间，并且不与合约交互的时候，可以使用abi.encodePacked
// 例如算一些数据的hash时。需要注意，abi.encodePacked因为不会做填充，
// 所以不同的输入在拼接后可能会产生相同的编码结果，导致冲突，这也带来了潜在的安全风险。


// abi.encodeWithSignature
// 与abi.encode功能类似，只不过第一个参数为函数签名，
// 比如"foo(uint256,address,string,uint256[2])"。
// 当调用其他合约的时候可以使用。
// 0xe87082f1000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
//等同于在abi.encode编码结果前加上了4字节的函数选择器。

// abi.encodeWithSelector
//与abi.encodeWithSignature功能类似，只不过第一个参数为函数选择器，
// 为函数签名Keccak哈希的前4个字节。
// 0xe87082f1000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
// 与abi.encodeWithSignature结果一样。

// ABI解码
// abi.decode
// abi.decode用于解码abi.encode生成的二进制编码，将它还原成原本的参数。




contract ABIEncode {
    uint x = 10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6]; 

    function encode() public view returns(bytes memory result) {
        result = abi.encode(x, addr, name, array);
    }

    /**
     0x000000000000000000000000000000000000000000000000000000000000000a7a58c0be72be218b41c608b7fe7c5bb630736c713078414100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006
    */
    //由于abi.encodePacked对编码进行了压缩，长度比abi.encode短很多。
    function encodePacked() public view returns(bytes memory result) {
        result = abi.encodePacked(x, addr, name, array);
    }

    /**
    0xe87082f1000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
    */
    function encodeWithSignature() public view returns(bytes memory result) {
        result = abi.encodeWithSignature("foo(uint256,address,string,uint256[2])", x, addr, name, array);
    }


    function encodeWithSelector() public view returns(bytes memory result) {
        result = abi.encodeWithSelector(bytes4(keccak256("foo(uint256,address,string,uint256[2])")), x, addr, name, array);
    }


    function decode(bytes memory data) public pure returns(uint dx, address daddr, string memory dname, uint[2] memory darray) {
        (dx, daddr, dname, darray) = abi.decode(data, (uint, address, string, uint[2]));
    }




}


// ABI的使用场景
// 1.在合约开发中，ABI常配合call来实现对合约的底层调用
/*
bytes4 selector = contract.getValue.selector;

bytes memory data = abi.encodeWithSelector(selector, _x);
(bool success, bytes memory returnedData) = address(contract).staticcall(data);
require(success);

return abi.decode(returnedData, (uint256));
*/

// 2. ethers.js中常用ABI实现合约的导入和函数调用。
/*
const wavePortalContract = new ethers.Contract(contractAddress, contractABI, signer);
// Call the getAllWaves method from your Smart Contract
const waves = await wavePortalContract.getAllWaves();

*/

// 3. 对不开源合约进行反编译后，某些函数无法查到函数签名，可通过ABI进行调用。

// 0x533ba33a() 是一个反编译后显示的函数，只有函数编码后的结果，并且无法查到函数签名

//这种情况无法通过构造interface接口或contract来进行调用
//但可以通过ABI函数选择器来调用
/*
bytes memory data = abi.encodeWithSelector(bytes4(0x533ba33a));

(bool success, bytes memory returnedData) = address(contract).staticcall(data);
require(success);

return abi.decode(returnedData, (uint256));

*/

// 在以太坊中，数据必须编码成字节码才能和智能合约交互。这一讲，我们介绍了4种abi编码方法和1种abi解码方法。

//  函数选择器就是通过函数名和参数进行签名处理(Keccak–Sha3)来标识函数，可以用于不同合约之间的函数调用 ↩
