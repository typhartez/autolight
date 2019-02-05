// LinksetAutoLight 1.2 - manages light points of linked prims
// Typhaine Artez (@sacrarium24.ru) - 2017/11/30
// 1.2 2018/01/15 - manages several link names/faces
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Put the script in the root prim (or the one acting as a switch), then change options below
// to fit your needs.
//
// When it's touched, the light changes of state, switching between off, on, or automatic if
// sun isn't disabled in options.

////////////////////////////////////////////////////////////////////////////////////////////////
// Options

// extended version, works on several parts of a linkset, with different options for each
list MODFACES = [//];
    // prim name, face, show/hide, point light source, use particles, fullbright, glow
    // ex:
    // "!light", ALL_SIDES, FALSE, TRUE, FALSE, TRUE, 0.2
];
// Point Light settings
list POINTLIGHT = [
    <1.0, 1.0, 0.5>,    // light color vector
    0.8,                // intensity
    10.0,               // radius
    0.5                 // falloff
];
// if this list is non empty, it will be used as a particle system when the light is on
list PARTICLES = [];
// sun options (set to ZERO_VECTOR to disable)
vector SUNOPTS = <
    10.0,   // check interval in seconds
    -0.2,   // sun height from which light should be turned on
    0.12    // sun height from which light should be turned off
>;
// chat options when changing state: 0=no chat, 1=owner only, 2=all
integer CHAT = 1;
// access option for touching: 0=owner only, 1=group, 2=all
integer ACCESS=0;

////////////////////////////////////////////////////////////////////////////////////////////////
// Don't change anything under this line

list lights;
integer active = -1;

doLight(integer on) {
    float alpha = llList2Float([0.0, 1.0], on);
    list parts = [];
    if (on) parts = PARTICLES;

    integer link;
    integer i;
    list rules;
    list params;
    integer face;
    float glow;
    integer n = llGetListLength(lights);
    while (~(--n)) {
        link = llList2Integer(lights, n);
        i = llListFindList(MODFACES, [llGetLinkName(link)]);
@nextFace;
        if (~i) {
            params += [ PRIM_LINK_TARGET, link ];
            // prim name, face, show/hide, point light source, use particles, fullbright, glow
            rules = llList2List(MODFACES, i, i+6);
            face = llList2Integer(rules, 1);
            // show/hide
            if (llList2Integer(rules, 2)) params += [
                PRIM_COLOR, face, llList2Vector(llGetLinkPrimitiveParams(link, [PRIM_COLOR]), 0), alpha
            ];
            // point light source
            if (llList2Integer(rules, 3)) params += [ PRIM_POINT_LIGHT, on ] + POINTLIGHT;
            // use particles
            if (PARTICLES != [] && llList2Integer(rules, 4)) llLinkParticleSystem(link, parts);
            // fullbright
            if (llList2Integer(rules, 5)) params += [ PRIM_FULLBRIGHT, face, on ];
            // glow
            glow = llList2Float(rules, 6);
            if (glow) params += [ PRIM_GLOW, face, llList2Float([0.0, glow], on) ];

            if (llList2String(MODFACES, i+7) == llGetLinkName(link)) {
                i += 7;
                jump nextFace;
            }
        }
    }
    if (llGetListLength(params)) {
        llSetLinkPrimitiveParamsFast(LINK_THIS, params);
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
    if (llGetListLength(lights)) {
        vector sun = llGetSunDirection();
        integer on = llList2Integer(llGetLinkPrimitiveParams(llList2Integer(lights, 0), [PRIM_POINT_LIGHT]), 0);
        // if current sun position differs from the actual light, change it
        if (sun.z < SUNOPTS.y && on == FALSE) {
            doLight(TRUE);
        }
        else if (sun.z >= SUNOPTS.z && on == TRUE) {
            doLight(FALSE);
        }
    }
}


default {
    changed(integer what) {
        if ((CHANGED_OWNER|CHANGED_LINK) & what) {
            llResetScript();
        }
    }
    state_entry() {
        if (MODFACES == []) {
            llOwnerSay("Options not set in script. Open and modify to activate.");
        }
        else {
            list names = llList2ListStrided(MODFACES, 0, -1, 7);
            list p;
            integer n = llGetNumberOfPrims();
            while (n > 0) {
                if (~llListFindList(names, llGetLinkName(n))) {
                    lights += n;
                }
                --n;
            }
            if (SUNOPTS != ZERO_VECTOR) {
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
                llRegionSayTo(id, 0, "No access, or restricted to group.");
                return;
            }
        }
        ++active;
        if (active == 2) {
            if (SUNOPTS != ZERO_VECTOR) {
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
            if (active) doChat("Now light is forced on.");
            else doChat("Now light is forced off.");
            doLight(active);
        }
    }
    timer() {
        checkSun();
    }
}
