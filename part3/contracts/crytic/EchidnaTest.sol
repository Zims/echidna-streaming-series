pragma solidity ^0.6.0;

import "./Setup.sol";
import "../libraries/UniswapV2Library.sol";

contract EchidnaTest is Setup {
    event AmountsIn(uint256 amount0, uint256 amount1);
    event AmountsOut(uint256 amount0, uint256 amount1);
    event BalancesBefore(uint256 balance0, uint256 balance1);
    event BalancesAfter(uint256 balance0, uint256 balance1);
    event ReservesBefore(uint256 reserve0, uint256 reserve1);
    event ReservesAfter(uint256 reserve0, uint256 reserve1);

    function testProvideLiquidity(uint256 amount0, uint256 amount1) public {
        // Preconditions:
        amount0 = _between(amount0, 1000, uint256(-1));
        amount1 = _between(amount1, 1000, uint256(-1));

        if (!completed) {
            _mintTokens(amount0, amount1);
        }
        //// State before
        uint256 lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint256 reserve0Before, uint256 reserve1Before,) = pair.getReserves();
        uint256 kBefore = reserve0Before * reserve1Before;
        //// Transfer tokens to UniswapV2Pair contract
        (bool success1,) = user.proxy(
            address(testToken1), abi.encodeWithSelector(testToken1.transfer.selector, address(pair), amount0)
        );
        (bool success2,) = user.proxy(
            address(testToken2), abi.encodeWithSelector(testToken2.transfer.selector, address(pair), amount1)
        );
        require(success1 && success2);

        // Action:
        (bool success3,) =
            user.proxy(address(pair), abi.encodeWithSelector(bytes4(keccak256("mint(address)")), address(user)));

        // Postconditions:
        if (success3) {
            uint256 lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint256 reserve0After, uint256 reserve1After,) = pair.getReserves();
            uint256 kAfter = reserve0After * reserve1After;
            assert(lpTokenBalanceBefore < lpTokenBalanceAfter);
            assert(kBefore < kAfter);
        }
    }

    // function testBadSwap(uint256 amount0, uint256 amount1) public {
    //     if (!completed) {
    //         _init(amount0, amount1);
    //     }

    //     // Preconditions:
    //     pair.sync(); // we matched the balances with reserves
    //     require(pair.balanceOf(address(user)) > 0); //there is liquidity for the swap

    //     // Action:
    //     (bool success,) =
    //         user.proxy(address(pair), abi.encodeWithSelector(pair.swap.selector, amount0, amount1, address(user), ""));

    //     // Post-condition:
    //     assert(!success); //call should never succeed
    // }

    // function testSwap(uint256 amount0, uint256 amount1) public {
    //     // Preconditions:
    //     if (!completed) {
    //         _init(amount0, amount1);
    //     }
    //     require(pair.balanceOf(address(user)) > 0);
    //     require(amount0 > 0 && amount1 > 0);

    //     uint256 balance0Before = testToken1.balanceOf(address(user));
    //     uint256 balance1Before = testToken2.balanceOf(address(user));

    //     (uint256 reserve0Before, uint256 reserve1Before,) = pair.getReserves();
    //     uint256 kBefore = reserve0Before * reserve1Before;
    //     emit ReservesBefore(reserve0Before, reserve1Before);

    //     uint256 amount0In = _between(amount0, 1, reserve0Before - 1);
    //     uint256 amount1In = _between(amount1, 1, reserve1Before - 1);
    //     // emit AmountsIn(amount0In, amount1In);
    //     if (amount0In > balance0Before) {
    //         testToken1.mint(address(user), amount0In - balance0Before);
    //         balance0Before = testToken1.balanceOf(address(user));
    //     }
    //     if (amount1In > balance1Before) {
    //         testToken2.mint(address(user), amount1In - balance1Before);
    //         balance1Before = testToken2.balanceOf(address(user));
    //     }
    //     require(amount0In <= balance0Before || amount1In <= balance1Before);
    //     emit BalancesBefore(balance0Before, balance1Before);

    //     uint256 amount0Out;
    //     uint256 amount1Out;

    //     /**
    //      * Precondition of UniswapV2Pair.swap is that we transfer the token we are swapping in first.
    //      * So, we pick the larger of the two input amounts to transfer, and also use
    //      * the Uniswap library to determine how much of the other we will receive in return.
    //      */
    //     if (amount0In > balance0Before) {
    //         amount0In = 0;
    //     } else if (amount1In > balance1Before) {
    //         amount1In = 0;
    //     }
    //     if (amount0In > amount1In) {
    //         require(amount0In <= balance0Before);
    //         amount1In = 0;
    //         amount0Out = 0;
    //         amount1Out = UniswapV2Library.getAmountOut(amount0In, reserve0Before, reserve1Before);
    //         require(amount1Out > 0);
    //         emit AmountsIn(amount0In, amount1In);
    //         emit AmountsOut(amount0Out, amount1Out);
    //         (bool success1,) = user.proxy(
    //             address(testToken1), abi.encodeWithSelector(testToken1.transfer.selector, address(pair), amount0In)
    //         );
    //         require(success1);
    //     } else {
    //         require(amount1In <= balance1Before);
    //         amount0In = 0;
    //         amount1Out = 0;
    //         amount0Out = UniswapV2Library.getAmountOut(amount1In, reserve1Before, reserve0Before);
    //         require(amount0Out > 0);
    //         emit AmountsIn(amount0In, amount1In);
    //         emit AmountsOut(amount0Out, amount1Out);
    //         (bool success1,) = user.proxy(
    //             address(testToken2), abi.encodeWithSelector(testToken2.transfer.selector, address(pair), amount1In)
    //         );
    //         require(success1);
    //     }

    //     // Action:
    //     (bool success2,) = user.proxy(
    //         address(pair), abi.encodeWithSelector(pair.swap.selector, amount0Out, amount1Out, address(user), "")
    //     );

    //     // Post-condition:
    //     /* 1. Swap should be successful */
    //     assert(success2);
    //     /* 2. Reserves may change, but k should be (relatively) constant */
    //     (uint256 reserve0After, uint256 reserve1After,) = pair.getReserves();
    //     uint256 kAfter = reserve0After * reserve1After;
    //     emit ReservesAfter(reserve0After, reserve1After);
    //     // assert(kBefore == kAfter);
    //     assert(kBefore <= kAfter);
    //     /* 3. The change in the user's token balances should match our expectations */
    //     uint256 balance0After = testToken1.balanceOf(address(user));
    //     uint256 balance1After = testToken2.balanceOf(address(user));
    //     emit BalancesAfter(balance0After, balance1After);
    //     if (amount0In > amount1In) {
    //         assert(balance0After == balance0Before - amount0In);
    //         assert(balance1After == balance1Before + amount1Out);
    //     } else {
    //         assert(balance1After == balance1Before - amount1In);
    //         assert(balance0After == balance0Before + amount0Out);
    //     }
}
// }
