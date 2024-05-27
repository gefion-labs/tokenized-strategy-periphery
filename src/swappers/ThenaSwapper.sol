// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IThenaRouter01} from "../interfaces/Thena/IThenaRouter01.sol";

/**
 *   @title ThenaSwapper
 *   @author gefion.finance
 *   @dev This is a simple contract that can be inherited by any tokenized
 *   strategy that would like to use Uniswap V2 for swaps. It holds all needed
 *   logic to perform exact input swaps.
 *
 *   The global address variables default to the ETH mainnet addresses but
 *   remain settable by the inheriting contract to allow for customization
 *   based on needs or chain its used on.
 */
contract ThenaSwapper {
    using SafeERC20 for ERC20;

    // Optional Variable to be set to not sell dust.
    uint256 public minAmountToSell;
    // Defaults to WETH on mainnet.
    address public base = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // Defaults to Uniswap V2 router on mainnet.
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    /**
     * @dev Used to swap a specific amount of `_from` to `_to`.
     * This will check and handle all allowances as well as not swapping
     * unless `_amountIn` is greater than the set `_minAmountToSell`
     *
     * If one of the tokens matches with the `base` token it will do only
     * one jump, otherwise will do two jumps.
     *
     * @param _from The token we are swapping from.
     * @param _to The token we are swapping to.
     * @param _amountIn The amount of `_from` we will swap.
     * @param _minAmountOut The min of `_to` to get out.
     */
    function _swapFrom(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _minAmountOut,
        bool _stable
    ) internal virtual {
        if (_amountIn > minAmountToSell) {
            _checkAllowance(router, _from, _amountIn);

            IThenaRouter01(router).swapExactTokensForTokensSimple(
                _amountIn,
                _minAmountOut,
                _from,
                _to,
                _stable,
                address(this),
                block.timestamp
            );
        }
    }

    /**\
     * @dev Internal function to get a quoted amount out of token sale.
     *
     * NOTE: This can be easily manipulated and should not be relied on
     * for anything other than estimations.
     *
     * @param _from The token to sell.
     * @param _to The token to buy.
     * @param _amountIn The amount of `_from` to sell.
     * @return . The expected amount of `_to` to buy.
     */
    function _getAmountOut(
        address _from,
        address _to,
        uint256 _amountIn,
        bool _stable
    ) internal view virtual returns (uint256) {
        uint256[] memory amounts = IThenaRouter01(router).getAmountsOut(
            _amountIn,
            _getTokenRoutes(_from, _to, _stable)
        );

        return amounts[amounts.length - 1];
    }

    /**
     * @notice Internal function used to easily get the path
     * to be used for any given tokens.
     *
     * @param _tokenIn The token to swap from.
     * @param _tokenOut The token to swap to.
     * @return _path Ordered array of the path to swap through.
     */
    function _getTokenRoutes(
        address _tokenIn,
        address _tokenOut,
        bool _stable
    ) internal view virtual returns (IThenaRouter01.route[] memory) {
        IThenaRouter01.route[] memory routes = new IThenaRouter01.route[](1);
        routes[0].from = _tokenIn;
        routes[0].to = _tokenOut;
        routes[0].stable = _stable;

        return routes;
    }

    /**
     * @dev Internal safe function to make sure the contract you want to
     * interact with has enough allowance to pull the desired tokens.
     *
     * @param _contract The address of the contract that will move the token.
     * @param _token The ERC-20 token that will be getting spent.
     * @param _amount The amount of `_token` to be spent.
     */
    function _checkAllowance(
        address _contract,
        address _token,
        uint256 _amount
    ) internal virtual {
        if (ERC20(_token).allowance(address(this), _contract) < _amount) {
            ERC20(_token).safeApprove(_contract, 0);
            ERC20(_token).safeApprove(_contract, _amount);
        }
    }
}
