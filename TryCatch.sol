// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// try-catch 是现代编程语言几乎都有的处理异常的一种标准方式, Solidity 0.6开始引入。
// 我们将介绍如何利用try-catch处理智能合约中的异常

 // try-catch 
 // 在Solidity中，try-catch智能被用于external函数或public函数或创建合约时constructor（被视为external函数）的调用.基本语法如下：
 // 
 // try externalContract.fun() {
 //     // call成功，运行一些代码
 //  }catch {
 //     // call失败，运行一些代码
 // }

 // 其中，externalContract.fun()是某个外部合约的函数调用，try模块在调用成功的情况下运行，而catch模块
 // 则在调用失败时运行

 // 同样可以使用this.fun()来代替externalContract.fun（）, 因为this.fun（）也被视为外部调用，但不可以在构造函数中使用，因为此时合约还未创建.

 // 如果调用的函数有返回值，那么必须在try之后声明returns(returnType val)，并且在try模块中可以使用返回的变量
 // 如果是创建合约，那么返回值就是新创建的合约变量

 // 另外，catch模块支持补货特殊的异常原因
 
//  try externalContract.fun() returns(returnType) {
//     // call成功，运行一些代码
//  }catch Error(string memory /* reason */) {
//     // 捕获revert("reasonString") 和require(false, "reasonString")
//  }catch Panic(uint /* errorCode */) {
//     // 捕获panic导致的错误，如assert失败、溢出、除零、数组 访问越界
//  }catch(bytes memory /* lowLevelData */ {
//     // 如果发送了revert，且上面2个异常类型匹配都失败，会进入该分支
//     // 例如revert（），require(false)，revert自定义类型的error
//  }


// try-catch 实战
 
// 创建一个外部合约OnlyEven，并使用try-catch来处理异常:
contract OnlyEven {
    constructor(uint a) {
        require(a != 0, "invalid number");
        assert( a != 1);
    }

    function onlyEvent(uint256 b) external  pure returns(bool success) {
        require((b % 2) == 0, "Ups Reverting");
        success = true;
    }

}




// 在TryCatch合约中定义一些事件和状态变量
contract TryCatch {
    // 成功Event
    event SuccessEvent();

    // 失败Event
    event CatchEvent(string message);
    event CatchByte(bytes data);

    // 声明OnlyEvent合约变量
    OnlyEven even;

    constructor() {
        even = new OnlyEven(2);
    }


    // 处理外部函数调用异常

    // SuccessEvent是调用成功会释放的事件
    // 而CatchEvent和CatchByte是抛出异常时会释放的事件
    // 在execute函数中使用try-catch处理调用外部函数onlyEvent中的异常

    // 在external call中使用try-catch
    function execute(uint amount) external returns (bool success){
        try even.onlyEvent(amount) returns (bool _result) {
            // 成功则，是否SuccessEvent
            emit SuccessEvent();
            return _result;
        }catch Error(string memory reason) {
            // Error异常，则是否CatchEvent
            emit CatchEvent(reason);
        }
    }


    // 处理合约创建异常
    // 利用try-catch来处理合约创建时异常，只要把try模块改为OnlyEven合约的创建即可。

    
    function executeNew(uint a) external returns (bool success){
        try new OnlyEven(a) returns(OnlyEven _even) {
            // 成功，发射SuccessEvent事件
            emit SuccessEvent();
            // 调用新合约_even的onlyEven函数
            success = _even.onlyEvent(a);
        }catch Error(string memory reason) {
            // 发生Error异常，发射CatchEvent事件
            emit CatchEvent(reason);
        }catch (bytes memory reason) {
            // 发生了异常且与Error不匹配，则发射CatchByte事件
            emit CatchByte(reason);
        }
    }


    // function onlyOdd(uint b) external  returns (bool success) {
    //     require((b % 2) != 0, "Ups Reverting");
    //     success = true;
    // }

    function onlyOdd(uint b) public returns (bool success) {
        require((b % 2) != 0, "Ups Reverting");
        success = true;
    }

    function executeSelf(uint amount) external returns (bool success){
        try this.onlyOdd(amount) returns (bool _result) {
            // 成功则，是否SuccessEvent
            emit SuccessEvent();
            return _result;
        }catch Error(string memory reason) {
            // Error异常，则是否CatchEvent
            emit CatchEvent(reason);
        }
    }


}

// 在Solidity使用try-catch来处理智能合约运行中的异常：
// - 只能用于外部合约调用和合约创建。
//    - 函数可见性必须public或external
//    - 调用方式为合约变量.fun() 或 this.fun()， 其中this.fun为在合约内部调用自己的函数, 也被视为外部合约调用
// - 如果try执行成功，返回变量必须声明，并且与返回的变量类型相同。