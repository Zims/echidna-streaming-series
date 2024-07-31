pragma solidity ^0.8.0;

import "token.sol";

contract TestToken is Token {
    constructor() public {
        paused(); // pause the contract
        owner = address(0); // lose ownership
    }

    // add the property
    function echidna_cannot_be_unpaused() public view returns(bool) {
        return is_paused;
    }

    function isPausable() public{
        assert(is_paused);
    }
}
