require("heapqueue.nut");
require("util.nut");

enum Direction {
    N = 0,
    NE = 1,
    E = 2,
    SE = 3,
    S = 4,
    SW = 5,
    W = 6,
    NW = 7
}

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


class AStar{

    TRAIN_LENGTH = 4
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
    static
    function AStar(start, goal, debugConsole,  showPathfinding) {

        local adjacentPairs = {}
        adjacentPairs[Direction.NE] <- [Direction.N, Direction.E];
        local x =  adjacentPairs[Direction.NE]

        foreach(y in x){
            AILog.Info(y);
        }
        AILog.Info(Direction.NE)
        AILog.Info("THIS VALUE SHOULD BE FALSE " + (1 in [1, 3]))

        AILog.Info(Direction.NE in adjacentPairs[Direction.NE]);
        local allSigns = []

        if (debugConsole){
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
        local i = -1;
        local allSigns = []
        while (openNodes.len() > 0){

            local current = openNodes.pop()[1];

            if (showPathfinding){
                i += 1;
                local text = (i.tostring());
                allSigns.append(AISign.BuildSign(current.location, text));
            }

            if (debugConsole){
                AILog.Info("Current: " + current);
            }

            //if the current location is the goal you've found a shortest path
            //as well, should
            if (current.location == goal.location) {// && AstarUtil.IsStraightDirection(current.direction)){
                local path = [];
                while (current in cameFrom && current.direction != null) {
                    path.append(current.location);
                    current = cameFrom[current];
                }
                path.append(start.location);

                AILog.Info("Path Length " + path.len());

                //We have to reverse the path as it begins from the destination
                path.reverse();

                //remove all debugging signs if there are any
                foreach(sign in allSigns){
                    AISign.RemoveSign(sign);
                }
                return path;
            }

            local neighbours = AStar.GetNeighbours(current);
            if (debugConsole){
                AILog.Info("# of Neighbours: " + neighbours.len());
            }

            foreach (neighbour in neighbours){

                local tempGScore = gScore[current.location] + AStar.CostToTraverseTo(current, neighbour);
                //if we haven't seen the neighbour before, or the score to traverse
                //is less than what we have previously scene
                if (!(neighbour.location in gScore) || tempGScore < gScore[neighbour.location]) {
                    if (debugConsole){
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
                local newDirection = AStarUtil.GetPositionOfAdjacentTile(node.location, newTile)


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

                else if (node.length >= AStar.TRAIN_LENGTH && AStarUtil.AreAdjacent(node.direction, newDirection)){
                    // AILog.Info("LONG ENOUGH");
                    neighbours.append(Node(newTile, newDirection, 0));
                }
            }
        }
        return neighbours;
    }


}

class AStarUtil{
    //This function is used to make sure the trains are able to successfully traverse along the rail
    //They can't make 90 degree turns
    static function AreAdjacent(dir1, dir2) {
        local adjacentPairs = {}
        adjacentPairs[Direction.N] <- [Direction.NE, Direction.NW];
        adjacentPairs[Direction.NE] <- [Direction.N, Direction.E];
        adjacentPairs[Direction.E] <- [Direction.NE, Direction.SE];
        adjacentPairs[Direction.SE] <- [Direction.E, Direction.S];
        adjacentPairs[Direction.S] <- [Direction.SE, Direction.SW];
        adjacentPairs[Direction.SW] <- [Direction.S, Direction.W];
        adjacentPairs[Direction.W] <- [Direction.SW, Direction.NW];
        adjacentPairs[Direction.NW] <- [Direction.N, Direction.W];

        return Util.Contains(adjacentPairs[dir1], dir2);
    }

    //This can be used in later code to ensure that it ends on a straight so that it can connect
    //To the train station easier
    static function IsStraightDirection(dir){
        return Util.Contains([Direction.NE, Direction.SE, Direction.SW, Direction.NW], dir);
    }


    static function GetPositionOfAdjacentTile(current, neighbour){
        local currentX = AIMap.GetTileX(current);
        local currentY = AIMap.GetTileY(current);

        local neighbourX = AIMap.GetTileX(neighbour);
        local neighbourY = AIMap.GetTileY(neighbour);

        local xDiff = neighbourX - currentX;
        local yDiff = neighbourY - currentY;

        if (xDiff == -1 && yDiff == 1) {
            // Right
            return Direction.E;
        } else if (xDiff == 1 && yDiff == -1) {
            // Left
            return Direction.W;
        } else if (xDiff == -1 && yDiff == -1) {
            // Up
            return Direction.N;
        } else if (xDiff == 1 && yDiff == 1) {
            // Down
            return Direction.S;
        } else if (xDiff == -1 && yDiff == 0) {
            // Up-Right
            return Direction.NE;
        } else if (xDiff == 0 && yDiff == -1) {
            // Up-Left
            return Direction.NW;
        } else if (xDiff == 0 && yDiff == 1) {
            // Down-Right
            return Direction.SE;
        } else if (xDiff == 1 && yDiff == 0) {
            // Down-Left
            return Direction.SW;
        }
        AILog.Error("GetPositionOfAdjacentTile is broken");
        return "ERROR";
    }

}