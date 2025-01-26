require("heapqueue.nut");

enum Direction {
    N,
    NE,
    E,
    SE,
    S,
    SW,
    W,
    NW
}

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

    static
    function AStar(start, goal,  debug) {
        local allSigns = []
        if (debug){
            AILog.Info("Start: " + start);
            AILog.Info("Goal: " + goal);
        }
        local start = Node(start, null, 0);
        local goal = Node(goal, null, 0);

        local openNodes = HeapQueue();
        openNodes.push(0, start);
        // openNodes.test();

        local cameFrom = {};

        cameFrom[start] <- "NULL";

        local gScore = {};
        gScore[start.location] <- 0;

        local fScore = {};
        fScore[start] <- AStar.Heuristic(start, goal);
        // local i = -1;
        while (openNodes.len() > 0){
            // i += 1;
            local current = openNodes.pop()[1];
            local iText = (i.tostring());
            allSigns.append(AISign.BuildSign(current.location, iText))

            if (debug){
                AILog.Info("Current: " + current);
            }
            //you need to have both reached the goal location but also have to end going straight for train station to work
            if (current.location ==  goal.location){
                local path = [];
                while (current in cameFrom && current.direction != "NULL") {
                    path.append(current.location);
                    current = cameFrom[current];
                }
                path.append(start.location);
                AILog.Info("Path Length " + path.len());
                path.reverse();

                foreach(sign in allSigns){
                    AISign.RemoveSign(sign);
                }
                return path;
            }
            local neighbours = AStar.GetNeighbours(current);
            if (debug){
                AILog.Info("# of Neighbours: " + neighbours.len());
            }
            foreach (neighbour in neighbours){
                // if (debug){
                //     AILog.Info("Neighbour: " + neighbour);
                // }
                local cost = AStar.CostToTraverseTo(current, neighbour);
                local tempGScore = gScore[current.location] + cost;
                if (!(neighbour.location in gScore) || tempGScore < gScore[neighbour.location]) {
                    if (debug){
                        AILog.Info("Neighbour to add: " + neighbour);
                    }
                    cameFrom[neighbour] <- current;
                    gScore[neighbour.location] <- tempGScore;
                    fScore[neighbour] <- tempGScore + AStar.Heuristic(current, goal);

                    openNodes.push(fScore[neighbour], neighbour);
                }
            }

        }
        return null;

    }

    static function Heuristic(current,  goal){
        return AIMap.DistanceManhattan(current.location, goal.location);
    }

    static function CostToTraverseTo(current, goal){
        return AIMap.DistanceManhattan(current.location, goal.location);
    }

    static function GetNeighbours(node){
        local tileX = AIMap.GetTileX(node.location);
        local tileY = AIMap.GetTileY(node.location);

        local neighbours = []
        for (local x = -1; x < 2; x +=  1){
            for (local y = -1; y < 2; y += 1){
                if (abs(x) + abs(y) ==  0){
                    continue;
                }
                local newTile = AIMap.GetTileIndex(tileX + x, tileY + y);
                // AILog.Info(node);
                // AILog.Info(newTile);
                local newDirection = AStar.GetPositionOfAdjacentTile(node.location, newTile)
                //if it's not a valid tile we should skip
                if (!AIMap.IsValidTile(newTile) && !AITile.IsWaterTile(newTile)){
                    continue;
                }
                neighbours.append(Node(newTile, newDirection, node.length + 1));
                continue;

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

                else if (node.length >= AStar.TRAIN_LENGTH && AStar.AreAdjacent(node.direction, newDirection)){
                    // AILog.Info("LONG ENOUGH");
                    neighbours.append(Node(newTile, newDirection, 0));
                }
            }
        }
        return neighbours;
    }

    static function GetPositionOfAdjacentTile(current, neighbour){
        local currentX = AIMap.GetTileX(current);
        local currentY = AIMap.GetTileY(current);

        local neighbourX = AIMap.GetTileX(neighbour);
        local neighbourY = AIMap.GetTileY(neighbour);

        local xDiff = currentX - neighbourX;
        local yDiff = currentY - neighbourY;

        if (xDiff == 1 && yDiff == 0) {
            // Right
            return Direction.E;
        } else if (xDiff == -1 && yDiff == 0) {
            // Left
            return Direction.W;
        } else if (xDiff == 0 && yDiff == 1) {
            // Up
            return Direction.N;
        } else if (xDiff == 0 && yDiff == -1) {
            // Down
            return Direction.S;
        } else if (xDiff == 1 && yDiff == 1) {
            // Up-Right
            return Direction.NE;
        } else if (xDiff == -1 && yDiff == 1) {
            // Up-Left
            return Direction.NW;
        } else if (xDiff == 1 && yDiff == -1) {
            // Down-Right
            return Direction.SE;
        } else if (xDiff == -1 && yDiff == -1) {
            // Down-Left
            return Direction.SW;
        }
        AILog.Error("GetPositionOfAdjacentTile is broken");
        return "ERROR";
    }

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

        return dir2 in adjacentPairs[dir1];
    }

    static function IsStraightDirection(dir){
        return dir in [Direction.N, Direction.E, Direction.S, Direction.W];
    }
}

