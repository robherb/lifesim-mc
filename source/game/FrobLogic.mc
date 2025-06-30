import Toybox.Math;
import Toybox.Lang;
import Toybox.System;

/**
    * Initializes a {@link Frob}'s genotype to spec-defined random values.
    * <br><br>
    * Names and positions of dna fields <br>
    * DNA_BIRTH_MASS=0, // dna[0] controls birthmass <br>
    * DNA_BIRTH_PERCENT=1, // dna[1] controls birthpercent <br>
    * DNA_UPDATE_PERIOD=2, // dna[2] controls updateperiod <br>
    * DNA_NORTH_PREFS=3, // dna[3..6] controls north prefs <br>
    * ... <br>
    * DNA_SOUTH_PREFS=7, // base index for south preferences <br>
    * DNA_EAST_PREFS=11, // ditto, east <br>
    * DNA_WEST_PREFS=15, // ditto, west <br>
    * DNA_LENGTH=19 // OVERALL LENGTH OF DNA
    */
function initRandomGenotype() as Array<Number> {
    var genotype = new Array<Number>[19];
    genotype[0] = (randomNumberInRange(0, 256) / 2) + 20;
    genotype[1] = (randomNumberInRange(0, 256) * 100) / 255;
    genotype[2] = (randomNumberInRange(0, 256) % 32) + 5;

    for (var i = 3; i < 18; ++i) {
        genotype[i] = randomNumberInRange(0, 256);
    }
    genotype[18] = 19;

    return genotype;
}

/**
    * Sets the Frob's birthMass, birthPercent, and updatePeriod from its
    * genotype (after the genotype has been initialized and/or mutated).
    * AbstractBeing methods hendle input bounds.
    */
function setTraitsFromGenotype(f as Frob) as Void {
    f.birthMass = f.genes[0];
    f.birthPercent = f.genes[1];
    f.updatePeriod = f.genes[2];
}

function mutateGenotype(f as Frob) as Void {
    var genotype = f.genes;

    // for each genotype byte, draw a number, if zero, flip a random bit
    var rndMutBit;
    for (var i = 0; i < 19; ++i) {
        if (randomNumberInRange(0, SimParams.DNA_MUTATION_ODDS_PER_BYTE) == 0) {
            // 0..7 (index from zero for XORing 1 in the first position, i.e. 1 << 0 == 1)
            rndMutBit = randomNumberInRange(0, 7);
            genotype[i] ^= (1 << rndMutBit); // could cause == 0, but is handled elsewhere in code	
        }
    }

    f.genes = genotype;
}

/**
    * Called my {@link Frob#nextEvent()} to initiate a Frob's move attempt.
    * 
    * @param moveDir
    *            The index of the {@link Thing} in the neighborhood to move to.
    *            This parameter is obtained in {@link Frob#nextEvent()} by a
    *            call to {@link Frob# chooseMoveDir()}.
    * 
    * @return The {@link Frob}'s offspring, or null if no offspring.
    */
function makeMove( // TODO rename
    f as Frob, 
    hood as Hood, 
    moveDir as Number, 
    prio as Number, 
    killCallback as Method(t as Thing, removeFromQueue as Boolean) as Void,
    moveCallback as Method(t as Thing, newLoc as [Number, Number], prio as Number) as Void,
    childCallback as Method(t as Thing, prio as Number) as Void
) as Void {
    // System.println("makeMove()");
    var beingInN = null; // TODO refactor, don't need this
    var child = null;
    var newLoc = null;

    // System.println("makeMove moveDir " + moveDir);`
    var thingInMoveDir = hood.hood[moveDir];
    var startLoc = [f.x, f.y];

    switch (thingInMoveDir) {
        case instanceof Frob:
            beingInN = thingInMoveDir as Frob;
            payMassTax(beingInN, SimParams.FROB_HIT_PENALTY);

            // TODO separate method to re-enqueue w/o moving
            moveCallback.invoke(f, [f.x, f.y], prio);
            break;
        case instanceof Grass:
            beingInN = thingInMoveDir as Grass;
            f.mass = min(f.birthMass, f.mass + beingInN.mass);
            newLoc = [beingInN.x, beingInN.y];

            killCallback.invoke(beingInN, true);
            moveCallback.invoke(f, newLoc, prio);
            child = maybeReproduce(f, startLoc);
            break;
        case instanceof Rock:
            payMassTax(f, SimParams.ROCK_BUMP_PENALTY);
            // TODO separate method to re-enqueue w/o moving
            moveCallback.invoke(f, [f.x, f.y], prio);
            break;
        case instanceof Thing: // empty space
            newLoc = [thingInMoveDir.x, thingInMoveDir.y];
            moveCallback.invoke(f, newLoc, prio);
            child = maybeReproduce(f, startLoc);
            break;
        default:
            // System.println("bad bad bad " + thingInMoveDir);
            break;
    }

    if (child != null) {
        childCallback.invoke(child, prio);
    }
}

function maybeReproduce(f as Frob, birthLoc as [Number, Number]) as Frob? {
    if (f.mass < f.birthMass) {
        return null;
    } else {
        var massTransfer = f.mass * f.birthPercent / 100;
		f.mass -= massTransfer; // being will survive until next event if mass now <= 0
        var child = f.makeChild(birthLoc[0], birthLoc[1], massTransfer);
		return child;
    }
}

/**
    * Based on the Frob's genotype, the neighborhood is examined, and the preferred movement
    * direction is selected as per ((S.10.3.3)).
    * <br><br>
    * Prefs Indexing: dna[DNA_N/S/E/W _PREFS+DNA_E/R/G/F_OFFSET] <br>
    * <br>
    * Frob's preference for moving north when contains: <br>
    * DNA_EMPTY_OFFSET	= 0 <br>
    * DNA_ROCK_OFFSET	= 1 <br>
    * DNA_GRASS_OFFSET	= 2 <br>
    * DNA_FROB_OFFSET	= 3
    * 
    * @return The index of the {@link Thing} in the {@link AbstractBeing#neighborhood} location to move to.
    */
function chooseMoveDir(hood as Hood, genotype as Array<Number>) as Number {
    var prefsSum = 0;
    var tempSum = 0;
    var prefsList = new Array<Number>[4];

    // get types and calculate preference sum
    for (var i = 1; i < 5; ++i) {
        switch (hood.hood[i - 1]) {
        // index == (i*4)-1 + DNA_E/R/G/F_OFFSET
        case instanceof Frob:
            tempSum = genotype[(i * 4) + 2] + 1;
            break;
        case instanceof Grass:
            tempSum = genotype[(i * 4) + 1] + 1;
            break;
        case instanceof Rock:
            tempSum = genotype[(i * 4)] + 1;
            break;
        default:
            tempSum = genotype[(i * 4) - 1] + 1;
            break;
        }
        prefsList[i - 1] = tempSum;
        prefsSum += tempSum;
    }

    // choose rand num 0..<sum of prefs>-1
    var rand = randomNumberInRange(0, prefsSum-1);

    /*
        * Decrement the chosen random number by each directional preference
        * value in turn and select the direction that made the decremented
        * value negative. Since we subtract values which sum to a value larger
        * than the randomly chosen one, we will always return from the below
        * loop at the correct index. Should some glitch occur, the last index
        * will be selected.
        */
    var moveDir;
    for (moveDir = 0; moveDir < 4; ++moveDir) {
        rand -= prefsList[moveDir];
        if (rand < 0) { 
            break; 
        }
    }

    return moveDir; 
}
