# AutoLight

Controlling one or several lights, with optional auto light with sun position.

There are 2 variants, depending on what you want:
* **`AutoLight`**: controlling one light in an object made of 1 or more links
* **`LinksetAutoLight`**: controlling several lights in a linkset, one link serving as a controller for lights

The reason of the two variants is the overhead of the linkset one isn't needed for a simple light, choose accordingly.

Both permit to change the light by:
* setting a face **full bright**
* make a face **glowing**
* generate **particles**
* show or hide a prim
* using the sun position or not for automatic light up
* change the rate sun position is checked, when it lights on or off
* enable or disable chat when changing state
* access to owner, group or all

To setup, open the script after putting it in the object and modify variables at the top, below the line
```lsl
// Options
```

Once done, save and it works :)

> If you want to use the *Point Light* (*Light* in Features tab of the object), then set it up before enabling the light. The script will make a save of those settings before turning the light off.

## Simple AutoLight

Put the script `AutoLight` in the prim that will light up (and where it will be touched).

### Options

* **FACE**
  
  Initially set to `-2`, prevents the script from working. Tells on the prim which face to control settings (`ALL_SIDES` for all faces).

* **BRIGHT**

  Boolean (`TRUE`/`FALSE`) telling if the **FACE** should be made `FULLBRIGHT` when light is turned on.

* **GLOW**

  Float (between `0.0` and `1.0`) telling how much the **FACE** should glow when light is turned on.

* **PARTICLES**

  List of [particle system settings](http://wiki.secondlife.com/wiki/LlParticleSystem) to enable when light is turned on.

* **SHOW**

  If set to a different value than `-1`, references a link to show when the light is turned on, and hide when off (handy for flammes using animated textures).

* **USESUN**

  Boolean (`TRUE`/`FALSE`) enabling the use of sun position to detect if the light should be turned on (during night).

* **SUNOPTS**

  Vector of 3 values for sun options: <**rate**, **turnon**, **turnoff**>.
  * **rate** is the number of seconds between two checks of the sun position (that means the script will awake each **rate** seconds to know the new sun position)
  * **turnon** is the sun height from which light should be turned on
  * **turnoff** is the sun height from which light should be turned off

  The system compares **turnon** and **turnoff** with the altitude (`z`) result of [llGetSunDirection()](http://wiki.secondlife.com/wiki/LlGetSunDirection).

* **CHAT**

  How the light should babble on state change:
  * `0` no chat
  * `1` chat to owner only
  * `2` whisper in local chat

* **ACCESS**

  Who can use the light by touching it:
  * `0` owner only
  * `1` members of the sanme group than the object containing the script (group tag must be active on the avatar using it)
  * `2` everyone can change light state

## One controller for many lights

Put the script `LinksetAutoLight` in the prim that will be touched (does not need to be the root prim).

### Naming links

The script uses link names to know which links to use for lights. To set them, edit the object and check *Edit linked*, then for each prim in the linkset, set the object (*link name*) to something distinctive (that will be used in script options), like `!light`.

### Options

* **MODFACES**

  The script can manage several groups (kind) of lights, and will apply settings differently based on the name of the links. For this, the **modfaces** is a list of several items containing for each:
  * **link name** the following settings will be applied to all links having this name in the linkset
  * **face** on those links, apply settings on that face (`ALL_SIDES` for all faces)
  * **show/hide** boolean (`TRUE`/`FASE`) indicating if those links should be hidden when light is turned off
  * **point light source** boolean (`TRUE`/`FASE`) telling if *point light* (see the **POINTLIGHT** option below) shoud be used (note that point lights are the same for all turned on links, it's not possible to use different ones for links with different names)
  * **particles** bllean (`TRUE`/`FALSE`) telling if particles (see the **PARTICLES** option) should be used (note that point lights are the same for all turned on links, it's not possible to use different ones for links with different names)
  * **fullbright** boolean (`TRUE`/`FASE`) telling if face should be made `FULLBRIGHT` when light is turned on
  * **glow** amount of glow to apply (`0.0` to `1.0`) when light is turned on

* **POINTLIGHT**

  Settings controlling how the links will light up the scene (those are the same than in the *Light* options in the Feature tab of the object)
  * **color** color of the light
  * **intensity** amount of light
  * **radius** how far the light goes
  * **falloff** how the light fades off with distance

* **PARTICLES**

  List of [particle system settings](http://wiki.secondlife.com/wiki/LlParticleSystem) to enable when light is turned on.

* **SUNOPTS**

  Vector of 3 values for sun options: <**rate**, **turnon**, **turnoff**>.
  * **rate** is the number of seconds between two checks of the sun position (that means the script will awake each **rate** seconds to know the new sun position)
  * **turnon** is the sun height from which light should be turned on
  * **turnoff** is the sun height from which light should be turned off

  The system compares **turnon** and **turnoff** with the altitude (`z`) result of [llGetSunDirection()](http://wiki.secondlife.com/wiki/LlGetSunDirection).

* **CHAT**

  How the light should babble on state change:
  * `0` no chat
  * `1` chat to owner only
  * `2` whisper in local chat

* **ACCESS**

  Who can use the light by touching it:
  * `0` owner only
  * `1` members of the sanme group than the object containing the script (group tag must be active on the avatar using it)
  * `2` everyone can change light state

## Examples

Simple linkset with one type of light, controlling links named `!light`, on all faces:
```lsl
list MODFACES = [
    // prim name, face,      show/hide, point light, use particles, fullbright, glow
    "!light",     ALL_SIDES, FALSE,     TRUE,        FALSE,         TRUE,       0.2
];
list POINTLIGHT = [
    <1.0, 1.0, 0.5>,    // light color vector
    0.8,                // intensity
    10.0,               // radius
    0.5                 // falloff
];
list PARTICLES  [];
vector SUNOPTS = <
    10.0,   // check interval in seconds
    -0.2,   // sun height from which light should be turned on
    0.12    // sun height from which light should be turned off
>;
integer CHAT = 1;
integer ACCESS = 0;
```

More complex setup with two kinds of light, one using particles (`!flamme`), the other using an animated texture (`!light`) on face `2`:
```lsl
list MODFACES = [
    // prim name, face,      show/hide, point light, use particles, fullbright, glow
    "!flamme",    ALL_SIDES, FALSE,     TRUE,        TRUE,          FALSE,      0.0,
    "!light",     ALL_SIDES, TRUE,      TRUE,        FALSE,         TRUE,       0.2
];
list POINTLIGHT = [
    <1.0, 1.0, 0.5>,    // light color vector
    0.8,                // intensity
    10.0,               // radius
    0.5                 // falloff
];
list PARTICLES  [
    // set your own particle system list ;-)
];
vector SUNOPTS = <
    10.0,   // check interval in seconds
    -0.2,   // sun height from which light should be turned on
    0.12    // sun height from which light should be turned off
>;
integer CHAT = 1;
integer ACCESS = 0;
```
