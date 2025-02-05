//The entire purpose of this file is to try
//and get information regarding towns

require("util.nut");

class Towns {
    townCount = null;
    towns = null;

    constructor(){
        this.townCount = AITown.GetTownCount();
        this.towns = [];

        for (local i = 0; i < townCount; i += 1){
            local newTown = Town(i);
            towns.append(newTown);
        }
    }

    function Get2LargestTowns(){
        // return [this.towns[3], this.towns[5]];
        return [this.towns[AIBase.RandRange(this.towns.len())], this.towns[AIBase.RandRange(this.towns.len())]];
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
    index = null;
    name = null;
    population = null;
    location = null;
    x = null;
    y = null;

    constructor(i) {
        if (!AITown.IsValidTown(i)) {
            AILog.Error("Town with index " + i + " is not valid");
        }
        this.index = i;
        this.name = AITown.GetName(i);
        this.population = AITown.GetPopulation(i);

        this.location = AITown.GetLocation(i);
        this.x = AIMap.GetTileX(this.location);
        this.y = AIMap.GetTileY(this.location);

    }

    function GetTownInfo() {
        AILog.Info("Name: " + this.name + " Index: " + this.index + " Population: " + this.population + " Location: " + this.location);
    }
}