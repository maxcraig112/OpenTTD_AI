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
    local t1StationDirection = GetTrainStationDirection(t2, t1);
    local t1Start = PlaceStationForTown(t1, t1StationDirection, debug);
    local t2StationDirection = GetTrainStationDirection(t1, t2);
    local t2Start = PlaceStationForTown(t2, t2StationDirection debug);

    AILog.Info("Generating Path between stations...")
    local path = AStar.AStar(t1Start.tile, t2Start.tile,  false, true);

    local i = 0;
    foreach(tile in path) {
        local iText = (i.tostring()); // Convert i to a string* using Text@
        AISign.BuildSign(tile, iText);
        i += 1;
    }


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

    AILog.Info("DiffX: " + diffX + " DiffY: " + diffY);

    if(abs(diffX) > abs(diffY)){
        AILog.Info("Other Town is further in the X direction")
        //if diffX is positive, it should point west
        if(diffX < 0){
            AILog.Info("Station is West")
            return "West"
        }
        //otherwise east
        AILog.Info("Station is East")
        return "East"
    }
    else {
        AILog.Info("Other Town is further in the Y direction")
        //if diffY is positive, it should point south
        if(diffY < 0){
            AILog.Info("Station is South")
            return "South"
        }
        //otherwise north
        AILog.Info("Station is North")
        return "North"
    }
}

function PlaceStationForTown(town, direction, debug) {
    //This is a boolean representing whether or not the placed tile of the station is also where
    //The pathfinding algorithm should begin
    //Direction is which way the train station is oriented

    //this is adjusting the desired space of the train station so that the side which the train leads has at least some space
    //to begin pathfinding
    local desiredSizeX = null;
    local desiredSizeY = null;
    local stationDirection = null;
    //This is the desired size of the searching radius. the reason I'm defining it separately
    //for each X,Y start and end is so that I can limit the train station being built on the opposite
    //side of a town relative to where the other town is
    local startingXPosition = 1
    local endingXPosition = 1

    local startingYPosition = 1
    local endingYPosition = 1

    switch (direction){
        case "North":
            desiredSizeX = CONSTANTS.TRAIN_NUMBER_PLATFORMS
            desiredSizeY = CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE
            // startingYPosition = 0
            stationDirection = AIRail.RAILTRACK_NW_SE
            break;
        case "East":
            desiredSizeX = CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE
            desiredSizeY = CONSTANTS.TRAIN_NUMBER_PLATFORMS
            // endingXPosition = 0
            stationDirection = AIRail.RAILTRACK_NE_SW
            break;
        case "South":
            desiredSizeX = CONSTANTS.TRAIN_NUMBER_PLATFORMS
            desiredSizeY = CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE
            // endingYPosition = 0
            stationDirection = AIRail.RAILTRACK_NW_SE
            break;
        case "West":
            desiredSizeX = CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE
            desiredSizeY = CONSTANTS.TRAIN_NUMBER_PLATFORMS
            // startingXPosition = 0
            stationDirection = AIRail.RAILTRACK_NE_SW
            break;
    }


    //Start at the centre of the town
    local foundValidPosition = false;

    local searchingSigns = []
    local location = null;


    AILog.Info("Finding Valid Station Location for " + town.name);
    while(!foundValidPosition){
        for (local x = -startingXPosition; x < endingXPosition + 1; x += 1){
            for (local y = -startingYPosition; y < endingYPosition + 1; y += 1){
                //it should only try to search tiles in it's current ring
                if (!(Util.Contains([startingXPosition,endingXPosition],abs(x)) || Util.Contains([startingYPosition,endingYPosition],abs(y)))){
                    continue;
                }
                location = Location(AIMap.GetTileIndex(town.x + x, town.y + y));
                if(direction == "North"){
                    location = location.AddVector(0,-CONSTANTS.TRAIN_PLATFORM_LENGTH)
                }
                if(direction == "East"){
                    location = location.AddVector(-CONSTANTS.TRAIN_PLATFORM_LENGTH,0)
                }
                if(debug){
                    local string = " "
                    searchingSigns.append(AISign.BuildSign(location.tile, string));
                }

                //found a valid spot as close as possible
                
                if (AITown.IsWithinTownInfluence(town.index, location.tile) && AITile.IsBuildableRectangle(location.tile, desiredSizeX, desiredSizeY)) {
                    foundValidPosition = true;
                    break;
                }
            }
            if(foundValidPosition){
                break;
            }
        }
        if (startingXPosition != 0){
            startingXPosition += 1
        } 
        if (endingXPosition != 0){
            endingXPosition += 1
        } 
        if (startingYPosition != 0){
            startingYPosition += 1
        } 
        if (endingYPosition != 0){
            endingYPosition += 1
        } 
    }
    if(debug){
        foreach(sign in searchingSigns){
            AISign.RemoveSign(sign);
        }
    }
    searchingSigns = []
    for (local x = 0; x < desiredSizeX; x +=  1){
        for (local y = 0; y < desiredSizeY; y +=  1){
            local tile = AIMap.GetTileIndex(location.x + x, location.y + y);
            local string = x + " " + y;
            searchingSigns.append(AISign.BuildSign(tile, string));
        }
    }

    foreach(sign in searchingSigns){
        AISign.RemoveSign(sign);
    }


    local correctLocation = location

    if (direction == "North"){
        correctLocation = location.AddVector(0, -4);
    }
    else if (direction == "South"){
        correctLocation = location.AddVector(0, 4);
    }
    else if (direction == "East"){
        correctLocation = location.AddVector(-4, 0);

    } else if (direction == "West"){
        correctLocation = location.AddVector(4, 0);
    }
    local string = "pathfind from"
    AISign.BuildSign(correctLocation.tile, string);
    
    local string = "Placed tile"

    AISign.BuildSign(location.tile,string)
    AIRail.BuildRailStation(location.tile, stationDirection, CONSTANTS.TRAIN_NUMBER_PLATFORMS, CONSTANTS.TRAIN_PLATFORM_LENGTH, AIBaseStation.STATION_NEW);

    return correctLocation
}

