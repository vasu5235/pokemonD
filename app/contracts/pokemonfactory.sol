pragma solidity ^0.4.19;

import "./ownable.sol";

contract PokemonFactory is Ownable {
    // Fires the NewPokemon event
    event NewPokemon(uint pokemonId, string name, uint dna);

    // The Pokemon's genetic code is packed into these 16-bits
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    /// The main Pokemon struct. Every Pokemon is represented by a copy
    /// of this structure.
    struct Pokemon {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    /*** STORAGE ***/
    Pokemon[] public pokemons;

    /// @dev A mapping from Pokemon IDs to the address that owns them. All Pokemon have
    ///  some valid owner address.
    mapping (uint => address) public pokemonToOwner;
    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint) ownerPokemonCount;

    /// @dev An internal method that creates a new Pokemon and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.  
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
