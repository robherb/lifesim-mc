import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class FrobWorldDelegate extends WatchUi.BehaviorDelegate {
    
    (:initialized)
    var menuSettings as Dictionary;

    function initialize(menuSettings as Dictionary) {
        BehaviorDelegate.initialize();
        self.menuSettings = menuSettings;
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=>new $.DrawableMenuTitle()});
        var delegate;
        menu.addItem(
            new MenuItem(
                "Unpause",
                "", // subLabel
                "item_1",
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "Restart",
                "",
                "item_2",
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "New Sim",
                "",
                "item_3",
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                "Seed",
                (Storage.getValue(seedStoreKey) as Number).toString(),
                "item_4",
                {}
            )
        );
        delegate = new FrobWorldMenuDelegate(menuSettings);
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
        // WatchUi.showToast("test", {:icon=>Rez.Drawables.LauncherIcon});
        return true;
    }

    // venu 3 key event 4 = top button, 5 = bottom button
    function onKey(keyEvent) {
        // System.println(keyEvent.getKey());
        switch(keyEvent.getKey()) {
            case KEY_ENTER:
               // TODO hide menu if already showing
                return onMenu();
            default:
                return false;
        }
    }

}
