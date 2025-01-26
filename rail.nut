require("town.nut");
require("astar.nut")

function ConnectTwoLargestTowns(towns) {
    local twoLargestTowns = towns.Get2LargestTowns();
    local t1 = twoLargestTowns[0];
    local t2 = twoLargestTowns[1];

    t1.GetTownInfo();
    t2.GetTownInfo();

    FindLocationToPlaceStation(t1);
    FindLocationToPlaceStation(t2);
    // local text = "HERE";
    // AISign.BuildSign(AIMap.GetTileIndex(1, 1), text);
    // AStar.Test(2794);
    local path = AStar.AStar(t1.location, t2.location,  false);

    local i = 0;
    foreach(tile in path) {
        local iText = (i.tostring()); // Convert i to a string* using Text@
        AILog.Info(AISign.BuildSign(tile, iText));
        i += 1;
    }

    //Find place to put down train stations

    //Find a way to place down rails between them

    //Build depots

    //Build trains

    //Set up routes

    //Set up group (optional)

    //Send them on their way
}

function FindLocationToPlaceStation(town){
    local stationRadius = 8;

    //Start at the centre of the town
    local searchingRingRadius = 1;
    local foundValidPosition = false;

    local townX = AIMap.GetTileX(town.location);
    local townY = AIMap.GetTileY(town.location);

    local searchingSigns = []
    local location = null;
    AILog.Info("Finding Valid Station Location for " + town.name);
    while(!foundValidPosition){
        for (local x = -searchingRingRadius; x < searchingRingRadius + 1; x += 1){
            for (local y = -searchingRingRadius; y < searchingRingRadius + 1; y += 1){
                //it should only try to search tiles in it's current ring
                if (!(abs(x) == searchingRingRadius || abs(y) == searchingRingRadius)){
                    continue;
                }
                location = AIMap.GetTileIndex(townX + x, townY + y);

                local string = " "
                searchingSigns.append(AISign.BuildSign(location, string));
                //found a valid spot as close as possible
                if (AITown.IsWithinTownInfluence(town.index, location) && AITile.IsBuildableRectangle(location, stationRadius, stationRadius)) {
                    foundValidPosition = true;
                    break;
                }
            }
            if(foundValidPosition){
                break;
            }
        }
        searchingRingRadius += 1;
    }

    foreach(sign in searchingSigns){
        AISign.RemoveSign(sign);
    }
    local locationX = AIMap.GetTileX(location);
    local locationY = AIMap.GetTileY(location);
    for (local x = 0; x < stationRadius; x +=  1){
        for (local y = 0; y < stationRadius; y +=  1){
            local tile = AIMap.GetTileIndex(locationX + x, locationY + y);
            local string = x + " " + y;
            AISign.BuildSign(tile, string);
        }
    }
}

