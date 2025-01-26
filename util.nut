class Util{
    static function Contains(array, item){
        foreach(value in array){
            if (value == item) {
                return true;
            }
        }
    }
}

class Location{

    tile = null
    x = null
    y = null
    constructor(location){
        this.tile = location
        this.x = AIMap.GetTileX(this.tile);
        this.y = AIMap.GetTileY(this.tile);
    }

    function AddVector(x, y){
        return Location(AIMap.GetTileIndex(this.x + x, this.y + y));
    }
}

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


class DirectionUtil{

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

    static function RelativeDirection(dir1, dir2) {
        if (dir1 + 1 == dir2 || (dir1 == Direction.NW && dir2 == Direction.N)) {
            return RelativeDirection.R
        }
        if (dir1 == dir2 + 1 || (dir1 == Direction.N && dir2 == Direction.NW)) {
            return RelativeDirection.L
        }
        return null
    }
}