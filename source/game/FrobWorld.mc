import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Timer;
// import Toybox.Test; // not available on device, works in sim only

class FrobWorld {

    // TODO possible starting point for passing world state to menu w/o using Storage API
    var menuSettings as Dictionary = {};

    (:initialized)
    private var q as PQueue;

    (:initialized)
    var timer as Timer.Timer;

    (:initialized)
    var grid as Array<Array<Thing>>;

    (:initialized)
    var emptySlots as Dictionary;

    (:initialized)
    var initStage as InitStage;

    (:initialized)
    var x as Number; // width (columns)

    (:initialized)
    var y as Number; // height (rows)

    (:initialized)
    var simTicks as Number;

    (:initialized)
    var aliveFrobs as Number;
    
    (:initialized)
    var aliveGrass as Number;

    (:initialized)
    var gameOver as Boolean;

    (:initialized)
    var seed as Number;

    // TODO have more detailed stats show up in the menu
    // TODO adjust sim params in menu

    const TICK_MILLIS = 0;
    const MAX_SIM_TICKS = 10000;

    function initialize(x as Number, y as Number) {
        self.x = x;
        self.y = y;
        timer = new Timer.Timer();
        simTicks = 0;
        aliveFrobs = 0;
        aliveGrass = 0;
        gameOver = false;
        initStage = PRE;
        seed = 0;
        emptySlots = {};
        Storage.clearValues();
        Storage.setValue(isPausedStoreKey, true);
        Storage.setValue(restartStoreKey, false);
    }

    function preInit() as Void {
        if (Storage.getValue(restartStoreKey) as Boolean == false) {
            seed = Time.now().value().toNumber();
        } else {
            Storage.setValue(restartStoreKey, false);
            // picker seed picked then restarted
            seed = Storage.getValue(seedStoreKey) as Number;
        }
        
        Math.srand(seed);
        Storage.setValue(seedStoreKey, seed);
        q = new PQueue(x * y);

        var j;
        var outer = new Array[x];
        for(var i = 0; i < x; i++) {
            outer[i] = new Array<Thing>[y];
            for(j = 0; j < y; j++) {
                outer[i][j] = new Thing(i, j, -1, -1);
                if (i > 0 && i < x - 1 && j > 0 && j < y - 1) {
                    emptySlots.put([i, j], null);
                }
            }
        }

        grid = outer as Array<Array<Thing>>;
    }

    function initGrid() as Void {
        var i;

        // init rock perimeter
		// (0,0) ... (0,y) left side
		for (i = 0; i < y; ++i) {
			grid[0][i] = new Rock(0, i);
        }

		// (MAX,0) ... (MAX,y) right side
		for (i = 0; i < y; ++i) {
			grid[x - 1][i] = new Rock(x - 1, i);
        }

		// (0,0) ... (x,0) top side 
		for (i = 0; i < x; ++i) {
			grid[i][0] = new Rock(i, 0);
        }

		// (0,MAX) ... (x,MAX) bottom side
		for (i = 0; i < x; ++i) {
			grid[i][y - 1] = new Rock(i, y - 1);
        }

        // init rocks
        for(i = 0; i < SimParams.INIT_ROCKS; i++) {
            var xy = getRandomEmptySpot(emptySlots);
            if (xy == [0, 0]) {
                break;
            } 

            grid[xy[0]][xy[1]] = new Rock(xy[0], xy[1]);
        }

        // init grass
        for(i = 0; i < SimParams.INIT_GRASSES; i++) {
            var xy = getRandomEmptySpot(emptySlots);
            if (xy == [0, 0]) {
                break;
            } 

            aliveGrass += 1;
            grid[xy[0]][xy[1]] = new Grass(xy[0], xy[1], SimParams.GRASS_GENESIS_MASS);
        }

        // init frobs
        for(i = 0; i < SimParams.INIT_FROBS; i++) {
            var xy = getRandomEmptySpot(emptySlots);
            if (xy == [0, 0]) {
                break;
            } 

            aliveFrobs += 1;
            grid[xy[0]][xy[1]] = new Frob(xy[0], xy[1], SimParams.FROB_GENESIS_MASS);
        }

    }

    function initQueue() as Void {
        var j;
        var temp;
        // inner locations only
        for(var i = 1; i < x - 1; i++) {
            for(j = 1; j < y - 1; j++) {
                temp = grid[i][j];
                if (temp instanceof Grass || temp instanceof Frob) {
                    q.insert([0, temp]);
                }
            }
        }
    }
    
    function stopSim() as Void {
        timer.stop();
        Storage.setValue(isPausedStoreKey, true);
    }

    function resumeSim() as Void {
        if (Storage.getValue(isPausedStoreKey) as Boolean == false ||
            Storage.getValue(restartStoreKey) as Boolean == true
        ) {
            resetSim();
        }

        Storage.setValue(isPausedStoreKey, false);
        timer.start(method(:gameTick), TICK_MILLIS, true);
    }

    function resetSim() as Void {
        initStage = PRE;
        simTicks = 0;
        aliveFrobs = 0;
        aliveGrass = 0;
        gameOver = false;
        q = new PQueue(0);
        grid = new Array<Array<Thing>>[0];
        // seed = 0;
        emptySlots = {};
    }

    function initLogic() as Void {
        switch(initStage) {
            case PRE:
                preInit();
                initGrid();
                initStage = ONE;
                break;
            case ONE:
                initQueue();
                initStage = TWO;
                break;
            case TWO:
                initStage = DONE;
                break;
            case DONE:
                break;
            default:
                break;
        }
    }

    function gameTick() as Void {
        //  System.println("gameTick);

        if (initStage != DONE) {
            initLogic();
            return;
        }

        if (!gameOver && simTicks <= MAX_SIM_TICKS) {
            ++simTicks;
            handleNextEvent();
        } else {
            var msg = "Game Over!";
            stopSim();
            System.println(msg);
            WatchUi.showToast(msg, {});
        }

        WatchUi.requestUpdate();
    }

    function handleNextEvent() as Void {
        if (q.isEmpty() || aliveFrobs < 1) {
            gameOver = true;
            return;
        }

        var next = q.extractNext();
        var prio = next[0];
        var thing = next[1];
        var hood = getNeighborhood(grid, thing.x, thing.y);
        // System.println("nextEvent " + thing);
        // System.println("hood " + arrayToString(hood.hood));
        // System.println("hoodGrass " + hood.grassCnt);
        // System.println("hoodSpace " + hood.emptySpace);    

        // if (simTicks % 100 == 0) {
        //     System.println("queue:");
        //     for(var x = 0; x < q.getSize(); ++x) {
        //         System.println("idx: " + x + " prio: " + q.q[x][0] + " " + q.q[x][1]);
        //     }
        // }

        var toKill = null;
        switch (thing) {
            case instanceof Grass:       
                toKill = handleGrass(thing as Grass, hood, prio);         
                break;
            case instanceof Frob:
                handleFrob(thing as Frob, hood, prio);
                break;
            default:
                // System.println("unhandled " + thing);
                break;
        }

        if (toKill != null) {
            kill(toKill as Thing, false);
        }
    }

    function kill(t as Thing, removeFromQueue as Boolean) as Void {
        // System.println("killing: " + t);
        if (t instanceof Grass) {
            --aliveGrass;
        }

        var newEmptyLoc = [t.x, t.y];
        emptySlots.put(newEmptyLoc, null);
        grid[t.x][t.y] = new Thing(t.x, t.y, -1, -1);
        if (removeFromQueue) {
            q.remove(t.qIdx);
        }
    }

    // assumed newLoc is empty, old loc will become empty, t will have coords updated
    function moveAndEnqueue(t as Thing, newLoc as [Number, Number], prio as Number) as Void {
        // System.println("move: " + t + " to " + newLoc[0] + ", " + newLoc[1]);
        grid[t.x][t.y] = new Thing(t.x, t.y, -1, -1);
        emptySlots.put([t.x, t.y], null);

        t.x = newLoc[0];
        t.y = newLoc[1];
        grid[newLoc[0]][newLoc[1]] = t;
        removeEmptySlot([newLoc[0], newLoc[1]]);
        q.insert([prio + t.updatePeriod, t]);
    }

    function placeChild(t as Thing, prio as Number) as Void {
        // System.println("new child: " + t);  
        if (t instanceof Frob) {
            ++aliveFrobs;
        }
        if (t instanceof Grass) {
            ++aliveGrass;
        }
        grid[t.x][t.y] = t;
        removeEmptySlot([t.x, t.y]);
        q.insert([prio + t.updatePeriod, t]);
    }

    // return self if g died during event, null if survived event
    private function handleGrass(g as Grass, hood as Hood, prio as Number) as Thing? {
        var tax = (SimParams.GRASS_MASS_TAX_MILLS * g.updatePeriod / 1000) + SimParams.GRASS_FIXED_OVERHEAD;
        var isAlive = payMassTax(g, tax);
        var canSplit = isAlive && grassCanSplit(g, hood); 

        if (canSplit) {
            var newLoc = getRandomEmptySpotInNeighborhood(hood, emptySlots);
            if (newLoc == [0, 0]) {
                System.println("ERROR: grass moved to [0,0]: " + g.toString());
            }
            var massTransfer = (g.mass * SimParams.GRASS_BIRTH_PERCENT) / 100;
            g.mass -= massTransfer; // being will survive until next event if mass is now <= 0

		    var child = new Grass(newLoc[0], newLoc[1], massTransfer);
            placeChild(child, prio);
        } else {
            var newUpdatePeriod = max(g.updatePeriod * 2, SimParams.GRASS_MAX_UPDATE_PERIOD);
		    g.updatePeriod = newUpdatePeriod;
		    g.mass = SimParams.GRASS_BIRTH_MASS;
        }

        if (isAlive) {
            q.insert([prio + g.updatePeriod, g]);
        }
        return (isAlive == false) ? g : null;
    }

    const killMethod = method(:kill);
    const moveAndEnqueueMethod = method(:moveAndEnqueue);
    const placeChildMethod = method(:placeChild);

    private function handleFrob(f as Frob, hood as Hood, prio as Number) as Void {
        // System.println("handleFrob()");

        var tax = (SimParams.FROB_MASS_TAX_MILLS * f.updatePeriod / 1000) + SimParams.FROB_FIXED_OVERHEAD;
		if (payMassTax(f, tax)) { // true if we paid and didn't die, false otherwise
			var moveDir = chooseMoveDir(hood, f.genes); // N S E W ... 0 1 2 3
			makeMove(f, hood, moveDir, prio, killMethod, moveAndEnqueueMethod, placeChildMethod);
		} else {
            kill(f, false);
            aliveFrobs -= 1;
        }
    }

    private function removeEmptySlot(key as [Number, Number]) as Void {
        if (emptySlots != null && emptySlots.hasKey(key)) {
            emptySlots.remove(key);
        }
    }

}
