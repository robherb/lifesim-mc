import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Factory that controls which numbers can be picked
class NumberFactory extends WatchUi.PickerFactory {
    private var _start as Number;
    private var _stop as Number;
    private var _increment as Number;
    private var _formatString as String;
    private var _font as FontDefinition;

    // TODO find a way to get hands on the index of which picker item is being picked, not the index of the current digit being mapped to 0 to 9
    (:initialized)
    var updateNumberPreviewMethod as Method;

    //! Constructor
    //! @param start Number to start with
    //! @param stop Number to end with
    //! @param increment How far apart the numbers should be
    //! @param options Dictionary of options
    //! @option options :font The font to use
    //! @option options :format The number format to display
    //! @param updateNumberPreviewMethodCallback callback to draw current uncommited state so long lumbers can be previewed (incomplete)
    public function initialize(start as Number, stop as Number, increment as Number, options as {
        :font as FontDefinition,
        :format as String
    },
    updateNumberPreviewCallback as Method(value as Number, index as Number) as Void
    ) {
        updateNumberPreviewMethod = updateNumberPreviewCallback;
        PickerFactory.initialize();

        _start = start;
        _stop = stop;
        _increment = increment;

        var format = options.get(:format);
        if (format != null) {
            _formatString = format;
        } else {
            _formatString = "%d";
        }

        var font = options.get(:font);
        if (font != null) {
            _font = font;
        } else {
            _font = Graphics.FONT_NUMBER_HOT;
        }
    }

    //! Get the index of a number item
    //! @param value The number to get the index of
    //! @return The index of the number
    public function getIndex(value as Number) as Number {
        return (value / _increment) - _start;
    }

    //! Generate a Drawable instance for an item
    //! @param index The item index (as in which digit value between 0 and 9 is selected)
    //! @param selected true if the current item is selected, false otherwise
    //! @return Drawable for the item
    public function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var value = getValue(index);
        // TODO need some way to know which digit we are picking to draw a preview of the uncommited state :(
        var text = " ";
        if (selected && value instanceof Number) {
            text = value.format(_formatString);
            // here, index is not which digit of the multidigit number we are picking but the index of the array of possible single digit values 0-9
            // updateNumberPreviewMethod.invoke(value as Number, index); 
        }
        return new WatchUi.Text({
            :text=>text, 
            :color=>Graphics.COLOR_WHITE, 
            :font=>_font,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }

    //! Get the value of the item at the given index
    //! @param index Index of the item to get the value of
    //! @return Value of the item
    public function getValue(index as Number) as Object? {
        return _start + (index * _increment);
    }

    //! Get the number of picker items
    //! @return Number of items
    public function getSize() as Number {
        return (_stop - _start) / _increment + 1;
    }

}
