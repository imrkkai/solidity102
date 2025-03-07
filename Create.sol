// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 以太坊上，用户（外部账户，EOA）可以创建智能合约，智能合约同样也可以创建新的智能合约
// 去中心化交易所unswap就是利用工厂合约（PairFactory）创建了无数个币对合约（Pair）
// 这里以简化版的unswap来介绍如何通过合约创建合约

// create
// 有两种方法可以在合约中创建新合约
// - create
// - create2

// create的用法很简单，就是new一个合约，并传入新合约构造函数所需的参数
// Contract x = new Contract{value:_value}(params)
// 其中Contract是要创建的合约名，x是合约对象（地址），如果构造函数是payable，可以创建时转入_value数量的ETH
// params是新合约构造函数的参数

// 极简Uniswap
// Uniswap v2核心合约中包含两个合约:
// 1. UniswapV2Pair：币对合约，用于管理币对地址、流动性、买卖
// 2. UniswapV2Factory: 工厂合约, 用于创建新的币对，并管理币对地址

// 接下来，使用create方法实现一个简单的Uniswap：Pair币对合约负责管理币对地址,
// PairFactory工厂合约用于创建新的币对，并管理币对地址


// Pair合约
// Pair合约很简单，包含3个状态变量factory,token0和token1
// 构造函数在部署时将factory赋值为工厂合约地址
// initialize函数会由工厂合约在部署完成后手动调用以初始化代币地址, 将token0和token1更新为币对中两种代币的地址

// 为什么uniswap不在constructor中将token0和token1地址更新好？
// 因为uniswap使用的是create2创建和，生成的合约地址可以实现预测

contract Pair {
    address public factory; // 工厂合约地址
    address public token0; // 代币0
    address public token1; // 代币1

    constructor() payable {
        factory = msg.sender;
    }


    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2 FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

}


// PairFactory
// 工厂合约有两个状态变量
// - getPair是两个代币地址到币对地址的map，便于根据代币找到币对地址
// - allPairs是币对地址的数组,存储了所有币对地址

// PairFactory合约只有一个createPair函数，根据传入的两个代币地址token0和token1来创建新的Pair合约
// 就是创建合约的代码，非常简单。大家可以部署好PairFactory合约，然后用下面两个地址作为参数调用createPair，看看创建的币对地址是什么：

// WBNB地址: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
// BSC链上的PEOPLE地址: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

contract PairFactory {
    // 通过两个代币地址查Pair地址
    mapping(address => mapping(address => address)) public getPairs;

    address[] public allPairs; // 保存所有的pair地址

    function createPair(address token0, address token1) external returns (address pairAddress) {
        // 创建合约
        Pair pair = new Pair();
        // 调用新合约的initialize方法
        pair.initialize(token0, token1);

        // 获取合约地址
        pairAddress = address(pair);
        // 保存Pair地址到getPairs中
        allPairs.push(pairAddress);

        // 保存币对地址和币对合约地址之间映射关系
        getPairs[token0][token1] = pairAddress;
        getPairs[token1][token0] = pairAddress;

    }

}