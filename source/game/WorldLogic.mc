import Toybox.Math;
import Toybox.Lang;
import Toybox.System;

function getNeighborhood(grid as Array<Array<Thing>>, x as Number, y as Number) as Hood {
    // System.println("getNeighborhood x " + x + " y " + y);

    var neighborhood = new Array<Thing>[4];
    var hoodGrass = 0; // number of Grasses in "neighborhood"
    var hoodSpace = 4; // number of unoccupied spaces in neighborhood

    // Living things exist only in interior locations,
    neighborhood[0] = grid[x][y-1]; // north
    neighborhood[1] = grid[x][y+1]; // south;
    neighborhood[2] = grid[x+1][y]; // east
    neighborhood[3] = grid[x-1][y]; // west;

    // System.println("north " + neighborhood[0]);
    // System.println("south " + neighborhood[1]);
    // System.println("east " + neighborhood[2]);
    // System.println("west " + neighborhood[3]);

    for (var i = 0; i < 4; ++i) {
        var t = neighborhood[i];
        if (t instanceof Frob || t instanceof Grass || t instanceof Rock) {
            --hoodSpace;
        }
        if (t instanceof Grass) {
            ++hoodGrass;
        }
    }

    return new Hood(neighborhood, hoodGrass, hoodSpace);
}

function getRandomEmptySpotInNeighborhood(hood as Hood, emptySlots as Dictionary) as [Number, Number] {
    // System.println("getRandomEmptySpotInNeighborhood");
    
    if (emptySlots.isEmpty()) {
        return [0, 0];
    } else {
        var emptyLocs = new Array<Thing>[4];
        var emptyLocSize = 0;
        for (var i = 0; i < 4; ++i) {
            // TODO type enum better perf?
            if (!(hood.hood[i] instanceof Frob || hood.hood[i] instanceof Grass || hood.hood[i] instanceof Rock)) {
                emptyLocs[emptyLocSize] = hood.hood[i];
                ++emptyLocSize;
            }	
        }

        var randIdx = randomNumberInRange(0, emptyLocSize - 1);
        // System.println("randIdx " + randIdx);
        // System.println("emptyLocs " + arrayToString(emptyLocs));
        // System.println("emptySlots " + genArrayToString(emptySlots.keys()));
        
        if (emptyLocSize == 0) {
            return [0, 0];
        } else {
            var t = emptyLocs[randIdx];
            emptySlots.remove([t.x, t.y]);
            return [t.x, t.y];
        }
    }
}

function getRandomEmptySpot(emptySlots as Dictionary) as [Number, Number] {
    if (emptySlots.isEmpty()) {
        return [0, 0];
    } else {
        var maxIdx = emptySlots.keys().size() - 1;
        var randomIndex = randomNumberInRange(0, maxIdx);
        var randomSpot = emptySlots.keys()[randomIndex] as [Number, Number];
        emptySlots.remove(randomSpot);
        return randomSpot;
    }
}

function grassCanSplit(g as Grass, hood as Hood) as Boolean {
    return (hood.emptySpace > 0 && hood.grassCnt < SimParams.GRASS_CROWD_LIMIT && g.mass >= SimParams.GRASS_BIRTH_MASS);
}

function payMassTax(t as Thing, tax as Number) as Boolean { 
    // System.println("payMassTax()");
    t.mass -= tax;
    return t.mass > 0;
}
