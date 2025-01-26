//The entire purpose of this file is to try
//and get information regarding towns

// #include <script_town.hpp>
require("util.nut");

class Towns {

    townCount = null;
    towns = null;

    constructor(){
        this.townCount = AITown.GetTownCount();
        this.towns = [];

        for (local i = 0; i < townCount; i += 1){
            local newTown = Town(i);
            // newTown.GetTownInfo();
            towns.append(newTown);
        }
    }

    function Get2LargestTowns(){
        local largest = null;
        local secondLargest = null;

        foreach (town in this.towns) {
            if (largest == null || town.population > largest.population) {
                secondLargest = largest;  // Update secondLargest before largest
                largest = town;
            } else if (secondLargest == null || town.population > secondLargest.population) {
                secondLargest = town;
            }
        }

        return [largest, secondLargest];
    }
}

class Town {
    townIndex = null;
    name = null;
    population = null;
    location = null;

    constructor(i)
    {
        if(!AITown.IsValidTown(i)){
            AILog.Error("Town with townIndex " + i + " is not valid");
        }
        this.townIndex = i;
        this.name = AITown.GetName(i);
        this.population = AITown.GetPopulation(i);
        this.location = AITown.GetLocation(i);
    }

    function GetTownInfo(){
        local info = "Name: " + this.name + " Index: " + this.townIndex;
        info += " Population: " + this.population + " Location: " + this.location;
        AILog.Info(info);
    }
}