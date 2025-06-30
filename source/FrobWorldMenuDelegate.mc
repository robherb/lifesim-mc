import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FrobWorldMenuDelegate extends WatchUi.Menu2InputDelegate {

    (:initialized)
    var menuSettings as Dictionary;

    function initialize(menuSettings as Dictionary) {
        Menu2InputDelegate.initialize();
        self.menuSettings = menuSettings;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        // System.println("itemid " + item.getId());
        switch (item.getId() as String) {
            case "item_1":
                System.println("Unpause");
                onBack();
                break;
            case "item_2":
                System.println("Restart");
                Storage.setValue(restartStoreKey, true);
                onBack();
                break;
            case "item_3":
                System.println("New Sim");
                Storage.setValue(isPausedStoreKey, false);
                onBack();
                break;
            case "item_4":
                System.println("seed");
                // Note: if picker result is accepted, a new sim will start
                WatchUi.pushView(new $.NumberPicker(), new $.NumberPickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            default:
                break;
        }
    }

    function onWrap(key as Key) as Boolean {
        // Don't allow wrapping
        return false;
    }
}
