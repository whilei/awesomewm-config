
- [ ] `very` : aka very special
- [ ] `better`: a pro pro `beautiful`
- [ ] `special`: custom functions and widgets that i like and you maybe wont
- [x] `icky`: my very own keybindings
- [ ] `modality`: a SpaceMacs-like way of using leader-based keybindings and modes

- [ ] `colorpicker`: a widget that allows you to pick a color from the screen.
  - it should also show a preview of the color you're picking
  - and it should have a history of colors you've picked
  - and maybe a library of colors you've marked as favorites
- [ ] `world times` : a widget that shows the time in different places. This is becoming `meridian`.

- [ ] `shitty` handle errors better (a pro pro naughty)
- [ ] `farty` make art

---

WTF

mic widget (and functionality?). frustrated with lain.

modality popup does not show hotkeys for submenus; 
only on the first level (ie root) are hotkeys are shown.
The object that the widget gets (`parent`) does not have (access to?) any of the objects fields that are tables. 
Fields that are strings or numbers are no problem, eg. `bound.n_bindings`, `bound.label`, `bound.fn`.
But `bound.bindings` and `bound.hotkeys` are nil.

alignment does not work properly for the formatting of the `textlines` that are used to represent functions and keybindings
in the search menu (here, `rofi`).

`develop.sh` is not live reloading anymore. wtf
