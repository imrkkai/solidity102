// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Import 
// 在solidity中，import语句可以帮助我们在一个文件中引用另一个文件的内容
// 提高代码的可用性，有效组织代码

// import 用法
// - 1. 通过源文件相对位置导入
import './Common.sol';

// - 2. 通过源文件网站引入网上的合约的全局符号
// 通过网址引用
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol';

// - 3. 通过npm的目录导入

import '@openzeppelin/contracts/access/Ownable.sol';


// - 4. 通过指定全局符号导入合约特定的全局符号
import {Common} from './Common.sol';

// import 引入位置
// 在版本声明之后，其余代码之前

contract Import {
    using Address for address;

    Common common = new Common();

    function callCommonTest() public view returns(uint){
        return common.test(10);
    }

}