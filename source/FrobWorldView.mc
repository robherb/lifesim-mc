import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Timer;

class FrobWorldView extends WatchUi.View {
    (:initialized)
    var world as FrobWorld;
    (:initialized)
    var dcw as Number; // dc width in pixels
    (:initialized)
    var dch as Number; // dc height in pixels
    (:initialized)
    var mTileSizeX as Number;
    (:initialized)
	var mTileSizeY as Number;
    (:initialized)
	var mScreenWidthPadding as Number;
    (:initialized)
	var mScreenHeightPadding as Number;
	
    const gridX as Number = SimParams.WORLD_WIDTH; // grid size in tiles, width
    const gridY as Number = SimParams.WORLD_HEIGHT; // grid size in tiles, height

    // (class constructor)
    function initialize() {
        View.initialize();
        world = new FrobWorld(gridX, gridY);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        dcw = dc.getWidth();
        dch = dc.getHeight();
        
        var maxSquareSizeX = (dcw / Math.sqrt(2)).toNumber();
        var maxSquareSizeY = (dch / Math.sqrt(2)).toNumber();
        var tileSizeX = maxSquareSizeX / gridX;
        var tileSizeY = maxSquareSizeY / gridY;
        var gridWidth = tileSizeX * gridX;
        var gridHeight = tileSizeY * gridY;

        mScreenWidthPadding = ((dcw - gridWidth) / 2);
        mScreenHeightPadding = ((dch - gridHeight) / 2);

        // NOTE: only support square grids for now
        mTileSizeX = tileSizeX;
        mTileSizeY = tileSizeX;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        // System.println("onShow()");
        world.resumeSim();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        // System.println("onHide()");
        world.stopSim();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);

        // gfxDemo(dc);
        drawWorldGrid(dc);
    }

    const statsFont = Graphics.FONT_XTINY;

    // Enhanced bitmap based graphics starting point... need to find a good art style... only using colored squares for now
    // const rockTexture = WatchUi.loadResource($.Rez.Drawables.Rock) as BitmapResource;
    // var bitmapOptions = {:bitmapWidth => mTileSizeX - 1, :bitmapHeight => mTileSizeY - 1};
    // var rockBitmapOptions = {};

    function drawWorldGrid(dc as Dc) as Void {
        dc.clear();

        // draw loading screen
        if (world.initStage != DONE) {
            var largeFontHeight = dc.getTextDimensions("A", Graphics.FONT_LARGE)[1];

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2 - largeFontHeight,
                Graphics.FONT_LARGE,
                "Loading...",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            return;
        }

        var statsFontHeight = dc.getTextDimensions("A", statsFont)[1];
        var header = "Ticks: " + world.simTicks;
        var footerLine1 = "Grass: " + world.aliveGrass;
        var footerLine2 = "Frobs: " + world.aliveFrobs;


        // draw header
        dc.drawText(
            dc.getWidth() / 2,
            5,
            statsFont,
            header,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // draw game over
        if (world.gameOver) {
            dc.drawText(
                dc.getWidth() / 2,
                statsFontHeight,
                statsFont,
                "Game Over",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // draw footer lines
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - (statsFontHeight * 2) + 5,
            statsFont,
            footerLine1,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - statsFontHeight,
            statsFont,
            footerLine2,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // draw grid
        for(var i = 0; i < world.x; i++){
            for(var j = 0; j < world.y; j++){
                // TODO pull out constants
                if (
                    !inside_circle(
                        [(dc.getWidth() / 2) - (mTileSizeX / 2), (dc.getHeight() / 2) - (mTileSizeY / 2)], 
                        [mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY)], 
                        ((dc.getWidth() as Float / 2) - (mTileSizeX * 1) as Float)
                    )
                ) {
                    continue;
                }

                dc.setColor(world.grid[i][j].color, Graphics.COLOR_BLACK);
                if (world.grid[i][j] instanceof Rock) { 
                    // Experimental ways of drawing bitmap based texture for rocks
                    // rockBitmapOptions = {:bitmapX => x1, :bitmapY => x2, :bitmapWidth => mTileSizeX - 1, :bitmapHeight => mTileSizeY - 1};
                    // dc.drawBitmap2(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), rockTexture, rockBitmapOptions);
                    // dc.drawOffsetBitmap(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), x1, x1, mTileSizeX - 1, mTileSizeY - 1, rockTexture);
                    dc.fillRectangle(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), mTileSizeX - 1, mTileSizeY - 1);
                } else if (world.grid[i][j] instanceof Grass) {
                    dc.fillRectangle(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), mTileSizeX - 1, mTileSizeY - 1);
                } else if (world.grid[i][j] instanceof Frob) {
                    dc.fillRectangle(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), mTileSizeX - 1, mTileSizeY - 1);
                } else {
                    dc.fillRectangle(mScreenWidthPadding + (i * mTileSizeX), mScreenHeightPadding + (j * mTileSizeY), mTileSizeX - 1, mTileSizeY - 1);
                }
            }
        }
    }

    // Basis for future feature where grid can be more oval shaped to take advantage of unused space on round displays.
    // Currently only used to not draw rocks at the four corners of the grid purely for aesthetics
    function inside_circle(center as [Number, Number], tile as [Number, Number], radius as Float) as Boolean {
        var cx = center[0];
        var cy = center[1];
        var tx = tile[0];
        var ty = tile[1];

        var dx = cx - tx as Float;
        var dy = cy - ty as Float;
        var distance_squared = (dx*dx + dy*dy) as Float;
        return distance_squared <= radius*radius;
    }

    // function gfxDemo(dc as Dc) as Void {    
    //     for(var i = 0; i < 1500; i++) {
    //         dc.setColor(randomColor(), Graphics.COLOR_BLACK);
    //         var x = randomNumberInRange(0, dcw);
    //         var y = randomNumberInRange(0, dch);
            
    //         dc.fillRectangle(x, y, 5, 5);
    //     }
    // }

}
