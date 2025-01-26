require("town.nut");
require("astar.nut")

function ConnectTwoLargestTowns(towns) {
    local twoLargestTowns = towns.Get2LargestTowns();
    local t1 = twoLargestTowns[0];
    local t2 = twoLargestTowns[1];

    t1.GetTownInfo();
    t2.GetTownInfo();

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
    local stationRadius = 5
}



