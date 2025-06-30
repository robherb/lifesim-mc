import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

const isPausedStoreKey = "isPaused";
const restartStoreKey = "restart"; // flag to reset sim w/ same seed
const seedStoreKey = "seed";

function min(a as Number, b as Number) as Number{
    if (a < b) {
        return a;
    }
    return b;
}

function max(a as Number, b as Number) as Number{
    if (a > b) {
        return a;
    }
    return b;
}

function arrayToString(a as Array<Thing>) as String {
    var size = a.size();
    var str = "";

    if (size < 1) {
        return str;
    }
    str = a[0].toString();

    for(var i = 1; i < size; ++i) {
        if (a[i] == null) {
            break;
        }
        str += ", " + a[i].toString();
    }

    return str;
}

function genArrayToString(a as Array<Object>) as String {
    var size = a.size();
    var str = "";

    if (size < 1) {
        return str;
    }
    str = a[0].toString();

    for(var i = 1; i < size; ++i) {
        if (a[i] == null) {
            break;
        }
        str += ", " + a[i].toString();
    }

    return str;
}

// TODO test with negative numbers
function numberToDigitArray(number as Number) as Array<Number> {
    var digits = [] as Array<Number>;
    var numString = number.toString();

    for (var i = 0; i < numString.length(); i++) {
        digits.add((numString.substring(i, i + 1) as String).toNumber() as Number);
    }

    return digits;
}

function randomNumberInRange(lo as Number, hi as Number) as Number {
    // return lo + (Math.rand() % (hi - lo + 1));
    return lo + (Math.rand() % (max(hi - lo, 0) + 1));
}

function randomColor() as ColorType {
    var temp = 0;
    var color = Graphics.COLOR_WHITE;
    
    temp = randomNumberInRange(1, 16);

    switch (temp) {
        case 1: 
            color = Graphics.COLOR_WHITE;
            break;
        case 2: 
            color = Graphics.COLOR_LT_GRAY;
            break;
        case 3: 
            color = Graphics.COLOR_DK_GRAY;
            break;
        case 4: 
            color = Graphics.COLOR_BLACK;
            break;
        case 5: 
            color = Graphics.COLOR_RED;
            break;
        case 6: 
            color = Graphics.COLOR_DK_RED;
            break;
        case 7: 
            color = Graphics.COLOR_ORANGE;
            break;
        case 8: 
            color = Graphics.COLOR_YELLOW;
            break;
        case 9: 
            color = Graphics.COLOR_GREEN;
            break;
        case 10: 
            color = Graphics.COLOR_DK_GREEN;
            break;
        case 11: 
            color = Graphics.COLOR_BLUE;
            break;
        case 12: 
            color = Graphics.COLOR_DK_BLUE;
            break;
        case 13: 
            color = Graphics.COLOR_PURPLE;
            break;
        case 14: 
            color = Graphics.COLOR_PINK;
            break;
    }

    return color;
}
