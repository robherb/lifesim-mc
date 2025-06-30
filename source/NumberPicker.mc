//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Picker that allows the user to choose a date
class NumberPicker extends WatchUi.Picker {

    // TODO need a way to "hook" into which digit is being picked, does not appear possible using std lib WatchUi.Picker as-is :(
    // this is intended to be a callback called when a digit in the seed has been picked so a preview of the seed (a long number)
    // can be shown before applying/saving it. WIP
    public function updateNumberPreview(value as Number, index as Number) as Void {
        System.println("updateNumberPreview callback " + value + " " + index);
    }
    const updateNumberPreviewMethod = method(:updateNumberPreview);

    //! Constructor
    public function initialize() {
        var state = Storage.getValue(seedStoreKey) as Number;
        var digits = numberToDigitArray(state) as Array<Number>;
        System.println("digits array: " + digits);

        // idea is to show the entire seed including changed digits as they are picked before saving
        var title = new WatchUi.Text(
            {:text=>state.toString(), 
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});

        var pattern = new Array<NumberFactory>[digits.size()];
        
        for(var i = 0; i < digits.size(); ++i) {
            pattern[i] = new $.NumberFactory(0, 9, 1, {}, updateNumberPreviewMethod);
        }

        Picker.initialize({
            :title=>title, 
            :defaults=>digits,
            :pattern=>pattern,
            });
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

//! Responds to a date picker selection or cancellation
class NumberPickerDelegate extends WatchUi.PickerDelegate {

    //! Constructor
    public function initialize() {
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Array) as Boolean {
        // convert array of picked digits to a single number serving as the seed
        if (values[0] != null) {
            var digits = "";
            for (var i = 0; i < values.size(); ++i){
                digits = digits + values[i];
            }
            // System.println("digits picked: " + digits);
            // System.println("digits as number: " + digits.toNumber().toString());
            
            Storage.setValue(seedStoreKey, digits.toNumber());
            Storage.setValue(restartStoreKey, true);
            
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // close the picker
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // close the menu
        }
        return true;
    }

}
