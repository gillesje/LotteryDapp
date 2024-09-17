// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address[] public players;
    mapping(address => uint) public balances;  // Enregistre les montants envoyés par chaque joueur

    constructor() {
        manager = msg.sender;
    }

    // Permet à un utilisateur de rejoindre la loterie avec un montant spécifié
    function enter() public payable {
        require(msg.value > 0, "Le montant doit être supérieur à 0 Ether");
        
        players.push(msg.sender);
        balances[msg.sender] += msg.value;  // Enregistre le montant envoyé par chaque joueur
    }

    // Génère un numéro pseudo-aléatoire
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    // Sélectionne le gagnant et transfère les fonds
    function pickWinner() public restricted {
        require(players.length > 0, "Pas assez de joueurs pour sélectionner un gagnant");

        uint index = random() % players.length;
        address winner = players[index];

        // Transfert des fonds à l'adresse du gagnant
        payable(winner).transfer(address(this).balance);

        // Réinitialise les participants
        players = new address ;
    }

    // Restriction d'accès aux fonctions spécifiques pour le manager
    modifier restricted() {
        require(msg.sender == manager, "Accès réservé au manager");
        _;
    }

    // Permet de voir la liste des joueurs
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Permet de voir la somme totale envoyée par chaque joueur
    function getBalance(address player) public view returns (uint) {
        return balances[player];
    }
}
