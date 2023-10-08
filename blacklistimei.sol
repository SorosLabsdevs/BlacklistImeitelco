// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//Author : SorosLabsdevs

import "@openzeppelin/contracts/access/Ownable.sol";

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
