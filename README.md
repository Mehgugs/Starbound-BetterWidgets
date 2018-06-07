### Starbound Better Widgets (BW)

>A simple library that provides lua object representations of starbound's UI widgets.

---

#### Motivation


##### BW makes code terser and easer to read

```lua
require"/better-widgets.lua"
function init()
    --either load widgets directly
    button = bw("mybutton")
    button.Text = "My Button!"
    button.Image = "/myimg.png"
end
-- Vanilla starbound requires you to pass the widget name everywhere which is cumbersome
function init()
    widget.setText("mybutton", "My Button!")
    widget.setButtonImage("mybutton", "/myimg.png")
end
```

##### BW provides some *very* useful abstractions for more complex widgets

```lua
require"/better-widgets.lua"
function init()
    list = bw("mylist")
    list:addItems(5)
    for i, component in list:components() do 
        component.title.Text = ("Item: %s"):format(i)
    end
    list:remove(5) -- removes the 5th item
end
-- Vanilla starbound list manipulation is brutal
function init()
    local listfmt = "mylist.%s.%s"
    local mylistids = {}
    widget.clearListItems("mylist")
    for i = 1, 5 do 
        local id = widget.addListItem("mylist") -- these are unique per list so must be recorded 
                                                -- or there's no way to access the item again
        mylistids[i] = id
        local titleWid = listfmt:format(id, "title")
        widget.setText(titleWid, ("Item: %s"):format(i))
    end
    widget.removeListItem("mylist", 5)
    table.remove(mylistids)
end
```
- BW lists dont need to be cleared on initialization,
- *All* list methods can accept position or item id,
- Components are sets of BW objects for the widgets in each list item,
- Utility methods like makeItems()

##### Custom widgets
```json
"mycolorpicker": {

    "type" : "canvas",
    "typeOverride" : "colorpicker",
    //regular canvas options...
}
```

```lua
require"/better-widgets.lua"
function init()
    mycolorpicker = bw("mycolorpicker")
end

-- somewhere
function widgetCallback()
    --code here
    local colorToUse = mycolorpicker.Color
end
```
All widget objects can be extended, as long as the custom widget is documented in `custom-widgets.json` BW will know about them. 

(Custom widgets must extend `Widget` or an extension of `Widget`)

#### Callbacks

```json
"button" : {
    "type" : "button", 
    "callback" : "betterwidget"
    //regular button options...
},
```
```lua
require"/better-widgets.lua"
function init()
    local button = bw("button") -- BW will log a warning since no callback was attached to the button on init
    button.callback = function(name) sb.logInfo("Hello from %s!", name) end
    button.callback = function(name) sb.logInfo("This callback completely changable!") end
end
```

```lua
....
MyCustomWidget = Something:extend()
function MyCustomWidget:callback()
    self.name --works as expected
end
```
BW has callback detection and alerts you when no callback is available on widget creation.
If you provide a callback in you custom class it will have it's self correctly assigned,
right now assigning new callbacks via `wid.callback = f` do not receive a self binding.
You can still use vanilla callbacks without issues too!

#### Casting


```lua
require"/better-widgets.lua"
require"/better-widgets/widgets/button.lua"

local MyButton = Button:extend()

function MyButton:callback()
    self.master.log("Hello from %s", self.name)
end

function init()
    local button = bw("button") 
    button = MyButton:cast(button) -- converts a Button -> MyButton
end
```
If you want to create small extension objects without using `"typeOverride"` you can use `Widget:cast` to change
a widget from one type to another!


---

#### Installation

- Place `starbound-betterwidgets.pak` in your `/mods` folder

#### Using the library in your mods

- Use `"requires" : ["starbound-betterwidgets",...]`

#### Creating custom widget packs

- Use `"requires" : ["starbound-betterwidgets",...]`