require("heapqueue.nut");
require("util.nut");
require("constants.nut")


//Every tile is represented as a node that contains information relating to it's location,
//the direction that it was facing when it was connected to the previous node
//And the length of the longest length of track
class Node{
    location = null;
    direction = null;
    length = null;

    constructor(location, direction, length) {
        this.location = location
        this.direction = direction
        this.length = length
    }
}

    static function Test(start){
        local tileX = AIMap.GetTileX(start);
        local tileY = AIMap.GetTileY(start);

        local neighbours = []
        //This will get all neighbours within a 3x3 radius of the current tile
        for (local x = -1; x < 2; x +=  1){
            for (local y = -1; y < 2; y += 1){

                local newTile = AIMap.GetTileIndex(tileX + x, tileY + y);

                local text = x + " " + y
                AISign.BuildSign(newTile, text);
            }
        }
    }
    static function AStar(start, goal, debug) {
        local allSigns = []

        if (debug){
            AILog.Info("Start: " + start);
            AILog.Info("Goal: " + goal);
        }

        local start = Node(start, null, 0);
        local goal = Node(goal, null, 0);

        local openNodes = HeapQueue();

        openNodes.push(0, start);

        local cameFrom = {};

        cameFrom[start] <- null;
        //gscore is the cost to traverse from the start node to the given node
        local gScore = {};
        gScore[start.location] <- 0;

        //fscore is the approximate heuristic cost to travel from a given node
        local fScore = {};
        fScore[start] <- AStar.Heuristic(start, goal);

        //debugging purposes
        while (openNodes.len() > 0){
            local current = openNodes.pop()[1];

            if (debug){
                AILog.Info("Current: " + current);
            }

            //if the current location is the goal you've found a shortest path
            //as well, should
            if (current.location == goal.location) {// && DirectionUtil.IsStraightDirection(current.direction)){
                local path = [];
                while (current in cameFrom && current.direction != null) {
                    path.append(current.location);
                    current = cameFrom[current];
                }
                path.append(start.location);

                AILog.Info("Path Length " + path.len());

                //We have to reverse the path as it begins from the destination
                path.reverse();

                return path;
            }

            local neighbours = AStar.GetNeighbours(current);
            if (debug){
                AILog.Info("# of Neighbours: " + neighbours.len());
            }

            foreach (neighbour in neighbours){

                local tempGScore = gScore[current.location] + AStar.CostToTraverseTo(current, neighbour);
                //if we haven't seen the neighbour before, or the score to traverse
                //is less than what we have previously scene
                if (!(neighbour.location in gScore) || tempGScore < gScore[neighbour.location]) {
                    if (debug){
                        AILog.Info("Neighbour to add: " + neighbour);
                    }
                    //expand to that node, add the reference to where we came from in
                    //cameFrom, and add scores to traverse for particular node
                    cameFrom[neighbour] <- current;
                    gScore[neighbour.location] <- tempGScore;
                    fScore[neighbour] <- tempGScore + AStar.Heuristic(current, goal);

                    //add the new neighbour to the list of open nodes to check with it's associated score
                    openNodes.push(fScore[neighbour], neighbour);
                }
            }

        }
        return null;

    }

    static function Heuristic(current,  goal){
        local currentX = AIMap.GetTileX(current.location);
        local currentY = AIMap.GetTileY(current.location);

        local goalX = AIMap.GetTileX(goal.location);
        local goalY = AIMap.GetTileY(goal.location);

        local diffX = goalX - currentX
        local diffY = goalY - currentY

        if(diffX < diffY){
            return AIMap.DistanceManhattan(current.location, AIMap.GetTileIndex(goalX, currentY)) + AIMap.DistanceManhattan(AIMap.GetTileIndex(goalX, currentY), goal.location)
        }
        else{
            return AIMap.DistanceManhattan(current.location, AIMap.GetTileIndex(currentX, goalY)) + AIMap.DistanceManhattan(AIMap.GetTileIndex(currentX, goalY), goal.location)
        }
    }

    static function CostToTraverseTo(current, goal){
        return AIMap.DistanceManhattan(current.location, goal.location);
    }

    static function GetNeighbours(node){
        local tileX = AIMap.GetTileX(node.location);
        local tileY = AIMap.GetTileY(node.location);

        local neighbours = []
        //This will get all neighbours within a 3x3 radius of the current tile
        for (local x = -1; x < 2; x +=  1){
            for (local y = -1; y < 2; y += 1){
                //ignore the current tile
                if (abs(x) + abs(y) ==  0){
                    continue;
                }
                //get the tile object
                local newTile = AIMap.GetTileIndex(tileX + x, tileY + y);
                //TODO additional checks for water, roads, etc...
                if (!AIMap.IsValidTile(newTile)){
                    continue;
                }
                local newDirection = DirectionUtil.GetPositionOfAdjacentTile(node.location, newTile)


                //if it's the starting node we shouldn't care
                if (node.direction == null){
                    // AILog.Info("NULL DIRECTION");
                    neighbours.append(Node(newTile, newDirection, node.length + 1));
                }
                //A neighbour is only valid if it either
                //- in the same direction that the lastTile was already travelling in
                //- is changing directions by at most one degree, and it's current length is equal to the minimum length we want

                //in the same direction
                else if (node.direction ==  newDirection){
                    // AILog.Info("SAME DIRECTION");
                    neighbours.append(Node(newTile, newDirection, node.length + 1));
                }

                else if (node.length >= CONSTANTS.TRAIN_LENGTH && DirectionUtil.AreAdjacent(node.direction, newDirection)){
                    // AILog.Info("LONG ENOUGH");
                    neighbours.append(Node(newTile, newDirection, 0));
                }
            }
        }
        return neighbours;
    }


}
