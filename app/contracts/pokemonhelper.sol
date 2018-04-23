pragma solidity ^0.4.19;

import "./pokemonfeeding.sol";

contract PokemonHelper is PokemonFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _pokemonId) {
    require(pokemons[_pokemonId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _pokemonId) external payable {
    require(msg.value == levelUpFee);
    pokemons[_pokemonId].level++;
  }

  function changeName(uint _pokemonId, string _newName) external aboveLevel(2, _pokemonId) {
    require(msg.sender == pokemonToOwner[_pokemonId]);
    pokemons[_pokemonId].name = _newName;
  }

  function changeDna(uint _pokemonId, uint _newDna) external aboveLevel(20, _pokemonId) {
    require(msg.sender == pokemonToOwner[_pokemonId]);
    pokemons[_pokemonId].dna = _newDna;
  }

  function getPokemonsByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerPokemonCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < pokemons.length; i++) {
      if (pokemonToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

