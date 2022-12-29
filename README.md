
- [x] `special`: custom functions and widgets that i like and you maybe wont
- [x] `special.pretty`: very especially pretty; stuff that could not work in beautiful

- [x] `icky`: my very own keybindings. tightly coupled with:
- [x] `modality`: a SpaceMacs-like way of using leader-based keybindings and modes

- [x] `meridian` : a widget that shows the time in different places.

- [ ] `colorpicker`: a widget that allows you to pick a color from the screen.
  - it should also show a preview of the color you're picking
  - and it should have a history of colors you've picked
  - and maybe a library of colors you've marked as favorites

- [ ] `shitty` handle errors/debugging better (a pro pro naughty)
- [ ] `farty` make art

- [ ] modality: run previous command (abstracts to history?)


---

my mouse does not always behave like i expect it to
i use the keyboard to move the mouse around because i use it to shift focus
i would like it to always show up where i last left it for each client
instead of moving to the middle of it
or not coming with me when i switch screens with hints
or not coming with me when i cycle through client.focus history with awesome
or not allowing me to minimize clients?
or not allowing me to move tags on a screen once i've move to a new screen
 because i'm actually still focused, maybe, somehow on the original screen (mouse left behind?)


i'm always dicking around with Goland trying to get my tab or pane or window group or whatever in a comfortable position (its usually too far left)
reasonable magnifier
places the current client in a magnified window
where my current mouse location in the client
is placed in the center of the screen
offscreen allowed
client should remain centered and maximized vertically


when awesome does stuff, it suprises me
fears: debug mode

i have a lot of screen space and it takes forever to move the mouse from one side to the next
territorial: move mouse anywhere in three moves

running Xephyr in a floating window seems ugly
xephyr instance of awmtt/awesome should be as equivalent to a real screen as possible
but then i need to give a visual indication if awesome is running via awmtt or not,
because i currently rely on the Xephyr titlebar to tell me whether I have the mouse and keyboard grabbed, or how to release them


my awesome instance has no idea if its the real deal or a development xephyr instance
awesome watch self for reloadable, then load


---



---

## WTF: known bugs

Modality:
The modality widget does not get the parent.bindings[code].bindings object (a tree) that I expect it to.
The object that the widget gets (`parent`) does not have (access to?) any of the objects fields that are tables.
Fields that are strings or numbers are no problem, eg. `bound.n_bindings`, `bound.label`, `bound.fn`.
But `bound.bindings` and `bound.hotkeys` are nil.

Modality:
alignment does not work properly for the formatting of the `textlines` that are used to represent functions and keybindings
in the search menu (here, `rofi`).

---


I am realizing that I want a key/path:function system that is function-centric, rather than binding or keypath centric.
