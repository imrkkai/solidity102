// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// CREATE2操作码使我们能够造智能合约部署在以太坊网络之前就能预测合约的地址
// Uniwap创建Pair合约用的就是Create2而不是Create

// CREATE如何计算地址
// 智能合约可以由其他合约和普通用户利用create操作码创建
// 在这两种情况下，新合约的地址都以相同的方式计算:
// 创建者的地址（通常为部署的钱包地址或者合约地址）和nonce（该地址发送交易的总数，对于合约账户是创建合约的总数，每创建一个合约nonce+1）的哈希
// 新地址 = hash(创建者地址, nonce)
// 创建者地址不会改变，但nonce可能会随时间而改变，因此用CREATE创建的合约地址不好预测

// CREATE2如何计算地址
// CREATE2的目的是为了让合约地址独立于未来的事件，不管未来区块链上发送了什么，都可以吧合约部署在事先计算的地址上。
// 用户CREATE2创建的合约地址由4个部分决定
// - 0xFF：一个常数，避免和CREATE冲突
// - CreatorAddress：调用CREATE2的当前合约（创建合约）的地址
// - salt: 盐，一个创建者指定的bytes32类型的值，它的主要目的是用来影响新创建的合约的地址
// - initcode: 新合约的初始化字节码(合约的Create Code和构造函数的参数)

// 新地址 = hash("0xFF", 创建者地址, salt, initcode)

// CREATE2保证，如果创建者使用CREATE2和提供的salt部署给定的合约initcode，它将存储在新地址中

// 如何使用CREATE2
// CREATE2的用法和之前的CREATE类似，同样new一个合约，并传入新合约构造函数所需的参数，只不过要多穿一个salt参数

// Contract x = new Contract{salt: _salt, value: _value}(params);
// 其中Contract是要创建的合约名，x是合约对象(地址),_salt是指定的盐
// 如果构造函数时payable，可以创建时传入_value数量的ETH，params是新合约构造函数的参数

// 极简Uniswap2

// Pair合约
// Pair合约很简单，包含3个状态变量：factory，token0和token1。
// 构造函数constructor在部署时将factory赋值为工厂合约地址。initialize函数会在Pair合约创建的时候被工厂合约调用一次，将token0和token1更新为币对中两种代币的地址。
contract Pair{
    address public factory; // 工厂合约地址
    address public token0; // 代币1
    address public token1; // 代币2

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }
}


// PairFactory2
// 工厂合约（PairFactory2）有两个状态变量getPair是两个代币地址到币对地址的map，
// 方便根据代币找到币对地址；allPairs是币对地址的数组，存储了所有币对地址。
// PairFactory2合约只有一个createPair2函数，
// 使用CREATE2根据输入的两个代币地址tokenA和tokenB来创建新的Pair合约。其中
// Pair pair = new Pair{salt: salt}();


contract PairFactory2{
     // 通过两个代币地址查Pair地址
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs; // 保存所有Pair地址

    function createPair2(address tokenA, address tokenB) external returns (address pairAddr) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES'); //避免tokenA和tokenB相同产生的冲突
        // 用tokenA和tokenB地址计算salt
         //将tokenA和tokenB按大小排序
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // salt为token1和token2的hash：
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // 用create2部署新合约
        Pair pair = new Pair{salt: salt}(); 
        // 调用新合约的initialize方法
        pair.initialize(tokenA, tokenB);
        // 更新地址map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }


    //事先计算Pair地址
    // 提前计算pair合约地址
    // 我们写了一个calculateAddr函数来事先计算tokenA和tokenB将会生成的Pair地址。通过它，我们可以验证我们事先计算的地址和实际地址是否相同。

function calculateAddr(address tokenA, address tokenB) public view returns(address predictedAddress){
    require(tokenA != tokenB, 'IDENTICAL_ADDRESSES'); //避免tokenA和tokenB相同产生的冲突
    // 计算用tokenA和tokenB地址计算salt
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); //将tokenA和tokenB按大小排序
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    // 计算合约地址方法 hash()
    predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
        bytes1(0xff), // 常数
        address(this), // 创建者地址
        salt,  // 盐
        keccak256(type(Pair).creationCode) // 新合约初始化字节码
        )))));
}



}


// 大家可以部署好PairFactory2合约，然后用下面两个地址作为参数调用createPair2，看看创建的币对地址是什么，是否与事先计算的地址一样：

// WBNB地址: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
// BSC链上的PEOPLE地址: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

// 预测地址：0x14B53fE4C5aFE51d311cA0F8f57A322559e319Ac
// 实际地址：0x14B53fE4C5aFE51d311cA0F8f57A322559e319Ac



// CREATE2的实际应用场景
// 1. 交易所为新用户预留创建钱包合约地址
// 2. 由CREAET2驱动factory合约，在Uniswap V2中交易对的创建
//    是在factory中调用CREATE2完成。这样做的好处是：它可以得到一个确定的pair地址，使得Router中就可以通过（token0，token1）计算出
//    pair地址，不需要执行一次Factgory.getPair(token0, token1)的跨合约调用

// CREATE2让我们可以在部署合约前确定它的合约地址，这也是一些layer2项目的基础。
