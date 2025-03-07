// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 删除合约
// selfdestruct命令可以用来删除智能合约，并将该合约剩余ETH转到指定地址.
// selfdestruct是为了应对合约出错的极端情况而设计的，
// 它最早被命名为suicide（自杀）, 但这个词太敏感。
// 为了保护抑郁的程序员，改名为selfdestruct
// 在v0.8.18版本中，selfdestruct关键字被标记为【不建议使用】
// 在一些情况下它会导致预期之外的合约语义，但由于目前还没有替代方案，目前只是对开发者做了编译阶段的警告
// 相关内容可以查看EIP-6049

// 然而，在以太坊cancun升级中，EIP-6780被纳入升级以实现对Verkle Tree更好的支持
// EIP-6780减少了selfdestruct操作码的功能，
// 根据提案描述，当前selfdestruct仅会被用来将合约中的ETH转移到指定地址,
// 原先的删除功能只有在合约创建-自毁这两个操作处在同一笔交易时才能生效
// 所以目前来说：
// 已经部署的合约无法被selfdestruct了
// 如果要使用原先的selfdestruct功能，必须在同一笔交易中创建并selfdestruct。

// 如何使用selfdestruct
// selfdestrucvt使用非常简单：
// selfdestruct(_address)
// 其中，_address是接收合约中剩余ETH的地址，_addr地址不需要有receive（）或fallback（）也能接收ETH

//Demo-转移ETH功能

contract DeleteContract {
    uint public value = 10;
    constructor() payable {}

    receive() external payable {}

    function deleteContract() external {
        // 调用selfdestruct销毁合约，并把剩余的ETH转给msg.sender
        selfdestruct(payable (msg.sender));
    }

    function getBalance() external view returns(uint balance) {
        balance = address(this).balance;
    }


}

//在DeleteContract合约中，我们写了一个public状态变量value，两个函数：getBalance()用于获取合约ETH余额，deleteContract()用于自毁合约，并把ETH转入给发起人。
//部署好合约后，我们向DeleteContract合约转入1 ETH。这时，getBalance()会返回1 ETH，value变量是10。

//当我们调用deleteContract()函数，合约将触发selfdestruct操作。
// 在坎昆升级前，合约会被自毁。
// 但是在升级后，合约依然存在，只是将合约包含的ETH转移到指定地址，而合约依然能够调用。



//Demo-同笔交易内实现合约创建-自毁

// 根据提案，原先的删除功能只有在合约创建-自毁这两个操作处在同一笔交易时才能生效。所以我们需要通过另一个合约进行控制。

contract DeployContract {
    
    struct DemoResult {
        address addr;
        uint balance;
        uint value;
    }
    
    constructor() payable {

    }


    function getBalance() external view returns(uint balance) {
        balance = address(this).balance;
    }


    function demo() public payable returns(DemoResult memory) {

        DeleteContract del = new DeleteContract{value: msg.value}();
        
        DemoResult memory res = DemoResult({
            addr: address(del),
            balance: del.getBalance(),
            value: del.value()
        });
        
        del.deleteContract();

        return res;
    }


}


// 对外提供合约销毁接口时，最好设置为只有合约所有者可以调用，
// 可以使用函数修饰符onlyOwner进行函数声明。
// 当合约中有selfdestruct功能时常常会带来安全问题和信任问题，
// 合约中的selfdestruct功能会为攻击者打开攻击向量
// (例如使用selfdestruct向一个合约频繁转入token进行攻击，这将大大节省了GAS的费用，虽然很少人这么做)，
// 此外，此功能还会降低用户对合约的信心。


// selfdestruct是智能合约的紧急按钮，销毁合约并将剩余ETH转移到指定账户。
// 当著名的The DAO攻击发生时，以太坊的创始人们一定后悔过没有
// 在合约里加入selfdestruct来停止黑客的攻击吧。
// 在坎昆升级后，selfdestruct的作用也逐渐发生了改变，什么都不是一成不变的，还是要保持学习。

