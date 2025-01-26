//The entire purpose of this file is to try
//and get information regarding towns

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
        // return [this.towns[AIBase.RandRange(this.towns.len())], this.towns[AIBase.RandRange(this.towns.len())]];
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
        AILog.Info("Name: " + this.name + " Index: " + this.townIndex + " Population: " + this.population + " Location: " + this.location);
    }
}