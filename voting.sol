// SPDX-License-Identifier: MIT

//Instanciar la versión de solidity
pragma solidity  ^0.8.13;

contract Voting {
   // Candidatos:
   // - Nombre - Puesto - Nacionalidad
   // Estructura de datos para cada candidato
   struct Candidate{
        bytes32 name; //Nombre del candidato
        // uint place; //Puesto del candidato
        //bytes32 nationality; //Nacionalidad del candidato
        uint voteCount;  //Votos acumulados
    }

   //Votantes
   //Solo pueden votar por un candidato
    struct Voter{
        uint vote;  //saber da un voto
        bool alreadyVoted; //Saber si voto o no
        uint accessToVote; //Saber si puede votar
    }

    //Un array para almacenar los candidatos
    //Es accesible fuera del contrato
    Candidate[] public candidates;

    //Mapping nos permite iterar sobre valores  y sus indexes
    //Para rastrear las direcciones de los votantes
    mapping(address => Voter) public voters; 
    //voters obtienen la address como clave y Voter el valor
    //Es accesible fuera del contrato

   //Propietario del contrato
   // Único que puede dar derecho al voto 
   // identificar al propietario
    address public contractOwner;


    //memory define una ubicación de datos temporal 
    //en Solidity solo durante el tiempo de ejecución
    //un loop para agregar candidatos al array  de candidatos
    constructor(bytes32[] memory candidateNames) {
       for(uint i=0; i<candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                //place: candidateNames[i].place,
                //nationality: candidateNames[i].nationality,
                voteCount: 0
            }));
        }
    }

   //Votación debe terminar despúes de un tiempo limitado
   //o cuando un candidato alcance cierto número de votos
   //Autenticar a los votantes
   //El propietario del contracto es el unico puede dar permiso
   //Validar que los votantes no han votado aún
   function allowAccessToVote(address voter) public{
       require(msg.sender == contractOwner, 
       "El propietario del contracto es el unico puede dar permiso de votar");
       require(!voters[voter].alreadyVoted, "El votante ya ha votado");
       require(voters[voter].accessToVote == 0);
       //Dando el permiso de votar
       voters[voter].accessToVote = 1;
    }
   
   function onVoting(uint candidate) public {
       Voter storage sender = voters[msg.sender];
       require(sender.accessToVote != 0, "No tiene permiso para votar");
       require(!sender.alreadyVoted, "Ya ha votado"); 
       sender.alreadyVoted = true;
       sender.vote = candidate;

       candidates[candidate].voteCount += sender.vote;
   }

   //Una vez finalizada  se debe ver el ganador 
   //Mostrar la dirección del contrato inteligente

   function getWinning() public view returns (uint winningCandidate){
       uint winnigVoteCount = 0;
       for(uint i=0; i< candidates.length; i++) {
           if(candidates[i].voteCount >  winnigVoteCount  ){
                winnigVoteCount = candidates[i].voteCount;
                winningCandidate = i;
           }
       }
   }

   //Desplegarlo en una red de prueba

}
