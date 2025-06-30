import Toybox.Graphics;
import Toybox.Lang;

typedef PQAble as [Number, Thing];

enum InitStage {
    PRE,
    ONE,
    TWO,
    DONE
}

// typedef Thing interface {
//     var x as Number;
//     var y as Number;
//     var mass as Number;
//     const color as Number = Graphics.COLOR_DK_GRAY;

//     // function initialize(x as Number, y as Number) {
//     //     self.x = x;
//     //     self.y = y;
//     // }

//     // function toString() as String {
//     //     return "Nothing(" + x + ", " + y + ")";
//     // }
// }

// TODO rename to Empty
class Thing {

    (:initialized)
    var x as Number;

    (:initialized)
    var y as Number;

    (:initialized)
    var mass as Number;

    (:initialized)
    var updatePeriod as Number; // number of "days" between events

    // really only needed for grass
    var qIdx as Number = 0;

    const color as Number = Graphics.COLOR_DK_GRAY;

    function initialize(x as Number, y as Number, mass as Number, updatePeriod as Number) {
        // Nothing.initialize(x, y);
        self.x = x;
        self.y = y;
        self.mass = mass;
        self.updatePeriod = updatePeriod;
    }

    function toString() as String {
        return "Thing(" + x + ", " + y + ") qIdx: " + qIdx;
    }
}

class Rock extends Thing {

    const color as Number = Graphics.COLOR_LT_GRAY;
    
    function initialize(x as Number, y as Number) {
        Thing.initialize(x, y, -1, -1);
    }

    function toString() as String {
        return "Rock(" + x + ", " + y + ")";
    }

}

class Grass extends Thing {

    const color as Number = Graphics.COLOR_DK_GREEN;
    
    function initialize(x as Number, y as Number, mass as Number) {
        Thing.initialize(x, y, mass,  SimParams.GRASS_INITIAL_UPDATE_PERIOD);
    }

    function toString() as String {
        return "Grass(" + x + ", " + y + ") qIdx: " + qIdx;
    }

}

class Frob extends Thing {

    (:initialized)
    var genes as Array<Number>;

    (:initialized)
    var birthMass as Number;

    (:initialized)
    var birthPercent as Number;

    // const color as Number = Graphics.COLOR_DK_BLUE;
    const color as Number = Graphics.COLOR_BLUE;
    
    function initialize(x as Number, y as Number, mass as Number) {
        Thing.initialize(x, y, mass,  0);
        genes = initRandomGenotype();
        setTraitsFromGenotype(self);
    }

    function makeChild(x as Number, y as Number, massTransfer as Number) as Frob {
        var c = new Frob(x, y, massTransfer);
        c.genes = genes.slice(null, null); // make copy
        mutateGenotype(c);
        setTraitsFromGenotype(c);

        return c;
    }

    function toString() as String {
        return "Frob(" + x + ", " + y + ") qIdx: " + qIdx;
    }

}

class Hood {

    (:initialized)
    var hood as Array<Thing>;

    (:initialized)
    var grassCnt as Number;

    (:initialized)
    var emptySpace as Number;

    function initialize(hood as Array<Thing>, grassCnt as Number, emptySpace as Number) {
        self.hood = hood;
        self.grassCnt = grassCnt;
        self.emptySpace = emptySpace;
    }

}
