require("town.nut");
require("astar.nut");
require("util.nut");

class RailLine{
    stations = null;
    trains = null;
    pathRoute = null;
}

class Train{
    index = null;
}

class RailRoute{
    path = null;
    depots = null;
}

class Station{
    town = null;
}

function GenerateTrainLine(towns, debug) {
    local twoLargestTowns = towns.Get2LargestTowns();
    local t1 = twoLargestTowns[0];
    local t2 = twoLargestTowns[1];

    //Print information about towns
    AILog.Info("Attempting to generate train line between the following Towns...");
    t1.GetTownInfo();
    t2.GetTownInfo();

    AILog.Info("Attempting to generate train station...");
    local direction = GetTrainStationDirection(t1.location, t2.location);
    PlaceStationForTown(t1, direction, debug);
    PlaceStationForTown(t2, direction debug);

    AILog.Info("Generating Path between stations...")
    local path = AStar.AStar(t1.location.tile, t2.location.tile,  false, true);

    // local i = 0;
    // foreach(tile in path) {
    //     local iText = (i.tostring()); // Convert i to a string* using Text@
    //     AILog.Info(AISign.BuildSign(tile, iText));
    //     i += 1;
    // }


    //Find a way to place down rails between them

    //Build depots

    //Build trains

    //Set up routes

    //Set up group (optional)

    //Send them on their way
}

    //return the direction enum for the train station, as well as a boolean on whether or not the
    //tile the train station will be built on is the true front
    //if it is false, you will need to move it over by the length of the platform
    function GetTrainStationDirection(location1,  location2){
    local diffX = location2.x - location1.x;
    local diffY = location2.y - location1.y;

    if(diffX > diffY){
        //if diffX is positive, it should point west
        if(diffX > 0){
            return [AIRail.RAILTRACK_NW_SE, true]
        }
        //otherwise east
        return [AIRail.RAILTRACK_NW_SE, false]
    }
    else {
        //if diffY is positive, it should point south
        if(diffY > 0){
            return [AIRail.RAILTRACK_NE_SW, true]
        }
        //otherwise north
        return [AIRail.RAILTRACK_NE_SW, false]
    }
}

function PlaceStationForTown(town, direction, debug) {
    local correctSide = direction[1];
    direction = direction[0];

    local desiredSpaceX = null;
    local desiredSpaceY = null;
    if (direction == AIRail.RAILTRACK_NW_SE){
        desiredSpaceX = CONSTANTS.TRAIN_NUMBER_PLATFORMS
        desiredSpaceY = CONSTANTS.TRAIN_PLATFORM_LENGTH * 2
    }
    else{
        desiredSpaceX = CONSTANTS.TRAIN_PLATFORM_LENGTH * 2
        desiredSpaceY = CONSTANTS.TRAIN_NUMBER_PLATFORMS
    }


    //Start at the centre of the town
    local searchingRingRadius = 1;
    local foundValidPosition = false;

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
                location = Location(AIMap.GetTileIndex(town.x + x, town.y + y));

                if(debug){
                    local string = " "
                    searchingSigns.append(AISign.BuildSign(location.tile, string));
                }

                //found a valid spot as close as possible
                if (AITown.IsWithinTownInfluence(town.index, location.tile) && AITile.IsBuildableRectangle(location.tile, desiredSpaceX, desiredSpaceY)) {
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
    if(debug){
        foreach(sign in searchingSigns){
            AISign.RemoveSign(sign);
        }
    }
    searchingSigns = []
    for (local x = 0; x < desiredSpaceX; x +=  1){
        for (local y = 0; y < desiredSpaceY; y +=  1){
            local tile = AIMap.GetTileIndex(location.x + x, location.y + y);
            local string = x + " " + y;
            searchingSigns.append(AISign.BuildSign(tile, string));
        }
    }

    foreach(sign in searchingSigns){
        AISign.RemoveSign(sign);
    }

    local string = "Placed tile"

    if (!correctSide){
        local correctLocation = null
        if (direction == AIRail.RAILTRACK_NW_SE){
            correctLocation = location.AddVector(4, 0);
        }
        else{
            correctLocation = location.AddVector(0, 4);
        }
        AISign.BuildSign(location.tile, string);
    }
    AISign.BuildSign(location.tile,string)
    AIRail.BuildRailStation(location.tile, direction, CONSTANTS.TRAIN_NUMBER_PLATFORMS, CONSTANTS.TRAIN_PLATFORM_LENGTH, AIBaseStation.STATION_NEW);
}

