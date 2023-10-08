
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// File: imeiblacklister.sol


pragma solidity ^0.8.0;
//Author : SorosLabsdevs


contract CellphoneBlacklist is Ownable {
    
    struct Cellphone {
        string imei;
        string model;
        string locationOfTheft;
        bool isStolen;
    }
    
    struct Entity {
        address entityAddress;
        string country;
        uint256 id;
    }
    
    mapping(string => Cellphone) public blacklistedCellphones;
    mapping(address => bool) private approvedEntities;
    mapping(string => Entity[]) private entitiesByCountry;
    
    uint256 private idCounter = 0;

    event CellphoneBlacklisted(string imei, string model, string location);
    event CellphoneWhitelisted(string imei);
    event EntityAdded(address entityAddress, string country, uint256 id);
    event EntityRemoved(address entityAddress, string country);
    
    modifier onlyApprovedEntities() {
        require(approvedEntities[msg.sender], "Not an approved entity");
        _;
    }
    
    function addApprovedEntity(address entity, string memory country) external onlyOwner {
        require(!approvedEntities[entity], "Entity already approved");
        
        // Incrementing the ID counter for uniqueness.
        idCounter++;
        
        Entity memory newEntity = Entity(entity, country, idCounter);
        entitiesByCountry[country].push(newEntity);
        
        approvedEntities[entity] = true;

        emit EntityAdded(entity, country, idCounter);
    }
    
    function removeApprovedEntity(address entity, string memory country) external onlyOwner {
        require(approvedEntities[entity], "Entity not found");
        
        approvedEntities[entity] = false;
        
        // Removing the entity from the entitiesByCountry mapping.
        Entity[] storage entities = entitiesByCountry[country];
        for (uint256 i = 0; i < entities.length; i++) {
            if (entities[i].entityAddress == entity) {
                entities[i] = entities[entities.length - 1];
                entities.pop();
                break;
            }
        }
        emit EntityRemoved(entity, country);
    }
    
    function blacklistCellphone(string memory imei, string memory model, string memory location, bool isStolen) external onlyApprovedEntities {
        require(bytes(blacklistedCellphones[imei].imei).length == 0, "Cellphone already blacklisted");
        
        blacklistedCellphones[imei] = Cellphone(imei, model, location, isStolen);
        
        emit CellphoneBlacklisted(imei, model, location);
    }
    
    function whitelistCellphone(string memory imei) external onlyApprovedEntities {
        require(bytes(blacklistedCellphones[imei].imei).length != 0, "Cellphone not found in blacklist");
        require(!blacklistedCellphones[imei].isStolen, "Stolen cellphones cannot be whitelisted");
        
        delete blacklistedCellphones[imei];
        
        emit CellphoneWhitelisted(imei);
    }
    

    
    function getBlacklistedCellphone(string memory imei) public view returns(Cellphone memory) {
        return blacklistedCellphones[imei];
    }
    
    function getEntitiesByCountry(string memory country) public view returns(Entity[] memory) {
        return entitiesByCountry[country];
    }
}
