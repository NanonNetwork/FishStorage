// Sources flattened with hardhat v2.22.5 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/nanon-haskey/FishStorage.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity =0.8.24;

contract FishStorage is Ownable {
    struct Fish {
        uint256 id;
        uint256 buyType;
        uint256 fee;
        bool isSynthetic;
    }

    mapping(address => Fish[]) public userFish;

    event EvtPurchaseRecord(
        address indexed user,
        uint buyType,
        uint256 id,
        uint256 fee
    );
    event EvtSynthetic(address indexed user, uint256 id);
    event EvtDelete(address indexed user, uint256 id);

    constructor() Ownable(msg.sender) {}

    function buy(uint _type, uint _id, uint _fee) external {
        Fish memory newFish = Fish({
            id: _id,
            buyType: _type,
            fee: _fee,
            isSynthetic: false
        });

        userFish[msg.sender].push(newFish);

        emit EvtPurchaseRecord(msg.sender, _type, _id, _fee);
    }

    function syntheticFish(uint _id) external {
        Fish[] storage fishes = userFish[msg.sender];

        for (uint i = 0; i < fishes.length; i++) {
            if (fishes[i].id == _id) {
                fishes[i].isSynthetic = true;
                break;
            }
        }

        emit EvtSynthetic(msg.sender, _id);
    }

    function deleteFish(uint _id) external {
        Fish[] storage fishes = userFish[msg.sender];
        uint indexToRemove;
        bool found = false;

        for (uint i = 0; i < fishes.length; i++) {
            if (fishes[i].id == _id) {
                indexToRemove = i;
                found = true;
                break;
            }
        }

        if (found) {
            fishes[indexToRemove] = fishes[fishes.length - 1];
            fishes.pop();
        }

        emit EvtDelete(msg.sender, _id);
    }
}