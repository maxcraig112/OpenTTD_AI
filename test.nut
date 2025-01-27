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
    AILog.Info("Attempting to generate train station for the following town...");

    t1.GetTownInfo();
    local t1StationDirection = GetTrainStationDirection(t2, t1);
    local t1Start = PlaceStationForTown(t1, t1StationDirection, debug);
    AILog.Info("Station Direction: " + t1StationDirection + " Starting Location: " + t1Start)

    t2.GetTownInfo();
    local t2StationDirection = GetTrainStationDirection(t1, t2);
    local t2Start = PlaceStationForTown(t2, t2StationDirection debug);
    AILog.Info("Station Direction: " + t2StationDirection + " Starting Location: " + t2Start)

    AILog.Info("Generating Path between stations...")
    local path = AStar.AStar(t1Start.tile, t2Start.tile, t1StationDirection, t2StationDirection,  false, true);

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

    // AILog.Info("DiffX: " + diffX + " DiffY: " + diffY);

    if(abs(diffX) > abs(diffY)){
        //if diffX is positive, it should point west
        if(diffX < 0){
            AILog.Info("- Town is South West")
            return Direction.SW
        }
        //otherwise east
        AILog.Info("- Town is North East")
        return Direction.NE
    }
    else {
        //if diffY is positive, it should point south
        if(diffY < 0){
            AILog.Info("- Town is South East")
            return Direction.SE
        }
        //otherwise north
        AILog.Info("- Town is North West")
        return Direction.NW
    }
}

function PlaceStationForTown(town, direction, debug) {
    //This is a boolean representing whether or not the placed tile of the station is also where
    //The pathfinding algorithm should begin
    //Direction is which way the train station is oriented

    //this is adjusting the desired space of the train station so that the side which the train leads has at least some space
    //to begin pathfinding
    local desiredFullSize = null;
    local desiredStationSize = null;
    local stationDirection = null;
    //The offset from the location for where the clearway should begin
    local clearwayOffset = null
    //This is the desired size of the searching radius. the reason I'm defining it separately
    //for each X,Y start and end is so that I can limit the train station being built on the opposite
    //side of a town relative to where the other town is
    local startingXPosition = 1
    local endingXPosition = 1

    local startingYPosition = 1
    local endingYPosition = 1

    if(direction == Direction.NW){
        desiredFullSize = Vector(CONSTANTS.TRAIN_NUMBER_PLATFORMS, CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE)
        desiredStationSize = Vector(CONSTANTS.TRAIN_NUMBER_PLATFORMS,CONSTANTS.TRAIN_PLATFORM_LENGTH)
        clearwayOffset = Vector(0,-4)
        // startingYPosition = 0
        stationDirection = AIRail.RAILTRACK_NW_SE
    }
    else if(direction == Direction.NE){
        desiredFullSize = Vector(CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE, CONSTANTS.TRAIN_NUMBER_PLATFORMS)
        desiredStationSize = Vector(CONSTANTS.TRAIN_PLATFORM_LENGTH, CONSTANTS.TRAIN_NUMBER_PLATFORMS)
        clearwayOffset = Vector(-4,0)
        // endingXPosition = 0
        stationDirection = AIRail.RAILTRACK_NE_SW
    }
    else if (direction == Direction.SE){
        desiredFullSize = Vector(CONSTANTS.TRAIN_NUMBER_PLATFORMS, CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE)
        desiredStationSize = Vector(CONSTANTS.TRAIN_NUMBER_PLATFORMS,CONSTANTS.TRAIN_PLATFORM_LENGTH)
        clearwayOffset = Vector(0,4)
        // endingYPosition = 0
        stationDirection = AIRail.RAILTRACK_NW_SE
    }
    else if (direction == Direction.SW){
        desiredFullSize = Vector(CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE, CONSTANTS.TRAIN_NUMBER_PLATFORMS)
        desiredStationSize = Vector(CONSTANTS.TRAIN_PLATFORM_LENGTH, CONSTANTS.TRAIN_NUMBER_PLATFORMS)
        clearwayOffset = Vector(4,0)
        // startingXPosition = 0
        stationDirection = AIRail.RAILTRACK_NE_SW
    }



    //Start at the centre of the town
    local foundValidPosition = false;

    local searchingSigns = []
    local clearwayLocation = null;
    local stationLocation = null;

    AILog.Info("Finding Valid Station Location for " + town.name);
    while(!foundValidPosition){
        for (local x = -startingXPosition; x < endingXPosition + 1; x += 1){
            for (local y = -startingYPosition; y < endingYPosition + 1; y += 1){
                //it should only try to search tiles in it's current ring
                if (!(Util.Contains([startingXPosition,endingXPosition],abs(x)) || Util.Contains([startingYPosition,endingYPosition],abs(y)))){
                    continue;
                }
                //Get the location to check valid
                stationLocation = Location(AIMap.GetTileIndex(town.x + x, town.y + y));
                clearwayLocation = stationLocation.AddVector(clearwayOffset);

                if(debug){
                    local string = " "
                    searchingSigns.append(AISign.BuildSign(stationLocation.tile, string));
                }

                //check that the point where the station is being added is a tile within the town
                //Check that from the clearway, there is a buildable section of the desired length
                if (direction == Direction.SE){
                    stationLocation = stationLocation.AddVector(Vector(0,-1 * (CONSTANTS.TRAIN_PLATFORM_LENGTH)))
                    clearwayLocation = clearwayLocation.AddVector(Vector(0,1 * (CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE)))
                }
                else if (direction == Direction.SW){
                    stationLocation = stationLocation.AddVector(Vector(-1 * (CONSTANTS.TRAIN_PLATFORM_LENGTH),0))
                    clearwayLocation = clearwayLocation.AddVector(Vector(1 * (CONSTANTS.TRAIN_PLATFORM_LENGTH + CONSTANTS.TRAIN_PLATFORM_CLEARANCE),0))
                }
                if (AITown.IsWithinTownInfluence(town.index, stationLocation.tile) && AITile.IsBuildableRectangle(clearwayLocation.tile, desiredFullSize.x, desiredFullSize.y)) {
                    //Not that we know where is a buildable location, we need to verify that at the very least the area where the station
                    //is being built is flat
                    local isFlatSurface = true
                    local flatSigns = []
                    for (local x = 0; x < desiredStationSize.x; x +=  1){
                        for (local y = 0; y < desiredStationSize.y; y +=  1){
                            local tile = AIMap.GetTileIndex(stationLocation.x + x, stationLocation.y + y);
                            local string = x + " " + y;

                            flatSigns.append(AISign.BuildSign(tile, string));
                            if(AITile.GetSlope(tile) != AITile.SLOPE_FLAT && AITile.IsBuildable(tile)){
                                isFlatSurface = false
                                break;
                            }
                        }
                        if(!isFlatSurface){
                            break
                        }
                    }
                    foreach(sign in flatSigns){
                        AISign.RemoveSign(sign);
                    }
                    if(isFlatSurface){
                        foundValidPosition = true;
                        break;
                    }

                }
                // foreach(t in test){
                //     AISign.RemoveSign(t);
                // }
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

        for (local x = 0; x < desiredFullSize.x; x +=  1){
            for (local y = 0; y < desiredFullSize.y; y +=  1){
                local tile = AIMap.GetTileIndex(clearwayLocation.x + x, clearwayLocation.y + y);
                local string = x + " " + y;
                searchingSigns.append(AISign.BuildSign(tile, string));
            }
        }

    }

    foreach(sign in searchingSigns){
        AISign.RemoveSign(sign);
    }
    AISign.BuildSign(clearwayLocation.tile, "Clearway start");

    AISign.BuildSign(stationLocation.tile,"Station start")
    AIRail.BuildRailStation(stationLocation.tile, stationDirection, CONSTANTS.TRAIN_NUMBER_PLATFORMS, CONSTANTS.TRAIN_PLATFORM_LENGTH, AIBaseStation.STATION_NEW);

    return clearwayLocation
}

