pragma solidity ^0.4.19;

import "./pokemonfactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
);
}

contract PokemonFeeding is PokemonFactory {

KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function feedAndMultiply(uint _pokemonId, uint _targetDna, string species) public {
    require(msg.sender == pokemonToOwner[_pokemonId]);
    Pokemon storage myPokemon = pokemons[_pokemonId];
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myPokemon.dna + _targetDna) / 2;
    if (keccak256(species) == keccak256("kitty")) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createPokemon("NoName", newDna);
  }

  function feedOnKitty(uint _pokemonId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_pokemonId, kittyDna, "kitty");
  }

}