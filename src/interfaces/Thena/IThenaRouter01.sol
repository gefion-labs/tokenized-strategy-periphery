// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

interface IThenaRouter01 {
    struct route {
        address from;
        address to;
        bool stable;
    }

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function swapExactTokensForTokensSimple(
        uint amountIn,
        uint amountOutMin,
        address tokenFrom,
        address tokenTo,
        bool stable,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountOut(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint amount, bool stable);

    function getAmountsOut(
        uint amountIn,
        route[] memory routes
    ) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function isPair(address pair) external view returns (bool);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint reserveA, uint reserveB);
}
