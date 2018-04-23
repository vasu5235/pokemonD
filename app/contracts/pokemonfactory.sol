pragma solidity ^0.4.19;

import "./ownable.sol";

contract PokemonFactory is Ownable {

    event NewPokemon(uint pokemonId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    struct Pokemon {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    Pokemon[] public pokemons;

    mapping (uint => address) public pokemonToOwner;
    mapping (address => uint) ownerPokemonCount;

    function _createPokemon(string _name, uint _dna) internal {
        uint id = pokemons.push(Pokemon(_name, _dna, 1, uint32(now + cooldownTime))) - 1;
        pokemonToOwner[id] = msg.sender;
        ownerPokemonCount[msg.sender]++;
        NewPokemon(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerPokemonCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createPokemon(_name, randDna);
    }

}