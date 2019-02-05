// AutoLight 1.2 - manages the light point of a prim
// Typhaine Artez (@sacrarium24.ru) - 2017/11/30
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Put the script in the prim (child link if it's a linkset) which will be the light.
// Then change options below to fit your needs.
// When the light is turned on, you can change the Light options in the Features tab of the
// viewer edit window.
// The light options will be saved when the light is turned off.
//
// When it's touched, the light changes of state, switching between off, on, or automatic if
// sun isn't disabled in options.

////////////////////////////////////////////////////////////////////////////////////////////////
// Options

// whith face to modify (-1 for ALL_SIDES)
integer FACE = -2; // initial value to disable the script until options are set
// alter Fullbright with turning on/off
integer BRIGHT = TRUE;
// glow intensity when turned on
float GLOW = 0.1;
// if this list is non empty, it will be used as a particle system
// when the light is on
list PARTICLES = [];
// prim to show/hide when the light is turned on/off
integer SHOW = -1;
// Using sun: auto change light with sun position (TRUE) or not (FALSE)
integer USESUN = TRUE;
// sun options:
// x: check interval in seconds
// y: sun height from which light should be turned on
// y: sun height from which light should be turned off
vector SUNOPTS = <10.0, -0.2, 0.12>;
// Chat options when changing state: 0=no chat, 1=owner only, 2=whisper
integer CHAT = 1;
// Access option for touching: 0=owner only, 1=group, 2=all
integer ACCESS=0;

////////////////////////////////////////////////////////////////////////////////////////////////
// Don't change anything under this line

integer active = -1;
list plbackup;  // point light parameters saved when turning off

doLight(integer on) {
    if (FACE != -2) {
        integer f = FACE;
        if (f == ALL_SIDES) {
            f = 0;
        }
        float g = 0.0;
        integer b = FALSE;
        integer l = FALSE;
        float a = 0.0;
        list ps;
        if (on) {
            g = GLOW;
            l = TRUE;
            if (BRIGHT) {
                b = TRUE;
            }
            a = 1.0;
            ps = PARTICLES;
        }
        if (on == FALSE || llGetListLength(plbackup) == 0) { // save those settings when turned off
            plbackup = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POINT_LIGHT]);
        }
        list p = [PRIM_GLOW, (integer)FACE, g, PRIM_POINT_LIGHT, l] + llList2List(plbackup, 1, -1);
        if ((integer)BRIGHT) {
            p += [PRIM_FULLBRIGHT, (integer)FACE, b];
        }
        if (~SHOW) {
            p += [
                PRIM_LINK_TARGET, SHOW,
                PRIM_GLOW, ALL_SIDES, g,
                PRIM_COLOR, ALL_SIDES, <1., 1., 1.>, a
            ];
        }
        llSetLinkPrimitiveParamsFast(LINK_THIS, p);
        llLinkParticleSystem(LINK_THIS, ps);
    }
}

doChat(string msg) {
    if (CHAT == 1) {
        llOwnerSay(msg);
    }
    else if (CHAT == 2) {
        llWhisper(0, msg);
    }
}

checkSun() {
    vector sun = llGetSunDirection();
    integer on = llList2Integer(llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POINT_LIGHT]), 0);
    // if current sun position differs from the actual light, change it
    if (sun.z < SUNOPTS.y && on == FALSE) {
        doLight(TRUE);
    }
    else if (sun.z >= SUNOPTS.z && on == TRUE) {
        doLight(FALSE);
    }
}

default {
    changed(integer what) {
        if (CHANGED_OWNER & what) {
            llResetScript();
        }
    }
    state_entry() {
        if (FACE == -2) {
            llOwnerSay("Face is not set in options. Light system disabled.");
        }
        else {
            if (~SHOW) {
                llSetLinkTextureAnim(SHOW, ANIM_ON | LOOP, ALL_SIDES, 4, 4, 0, 0, 20.0);
            }
            if (USESUN) {
                active = -1;
                llOwnerSay("Initially using the sun to turn the light on/off.");
                checkSun();
                llSetTimerEvent(SUNOPTS.x);
            }
            else {
                llOwnerSay("Sun disabled. Setting the light on by default.");
                active = TRUE;
                doLight(active);
            }
        }
    }
    touch_start(integer n) {
        key id = llDetectedKey(0);
        if (id != llGetOwner()) {
            if (ACCESS == 0 || (ACCESS == 1 && !llSameGroup(id))) {
                llRegionSayTo(id, 0, "No access, or restriced to group.");
                return;
            }
        }
        ++active;
        if (active == 2) {
            if (USESUN) {
                active = -1;
                doChat("Now using the sun to turn the light on/off.");
                checkSun();
                llSetTimerEvent(SUNOPTS.x);
            }
            else {
                active = 0;
            }
        }
        if (~active) {
            llSetTimerEvent(0.0);
            if (active) {
                doChat("Now light is forced on.");
            }
            else {
                doChat("Now light is forced off.");
            }
            doLight(active);
        }
    }
    timer() {
        checkSun();
    }
}
