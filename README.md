# Mantis hex ergo keyboard

>![photo](./assets/photo.jpg)
>_Finished prototype with 36 keys populated_

## Contents

This repository contains Ergogen and KiCad files for the PCB design, as well as this readme with some basic information. This is a prototype, so don't expect a polished build guide at this point.

## Components

In addition to the PCB you need these components to build a working keyboard:

* 1x Pro-Micro or compatible controller
* 40x Kailh Choc hotswap sockets
* 40x Kailh Choc v1 switches
* 40x diodes (SMD or through-hole)
* 40x FK-Keycaps Hex Caps
* 1x reset switch (optional)
* Adhesive rubber feet

## Firmware

Firmware is available in my [QMK fork](https://github.com/fxkuehl/qmk_firmware/tree/mantis-v0.1/keyboards/mantis).

## Concept

A unibody ergo keyboard using hexagonal key caps, placing the hands close together and rotating them 30°. The hex grid naturally results in aggressive column stagger that is close enough to anatomically reasonable (with aggressive pinky and index finger stagger and slightly exaggerated ring finger stagger). Existing 3x5+3 layouts with 36 keys should be adaptable for this keyboard.

>![diagram](./assets/hex_keyboard_compact.svg)
>_Layout diagram of a modified Colemak-DH with minimal changes to accommodate fewer index-finger keys while preserving low same-finger bigrams. Color coding indicates angled and staggered columns in the left half and the shape of a hypothetical numpad on a layer in the right half_

The inner index-finger column only has 2 keys. As a result the index finger has 5 keys instead of the usual 6. The non-home keys are all the same distance from the home key and should all be comfortable to reach. To make up for the missing index finger key, the pinky has one extra key. The top row pinky key simulates pinky splay, which makes it easier to reach without moving the whole hand.

The hexagonal keys have a large surface area that is approximately circular. This should make it harder to hit adjacent keys accidentally. Because the columns are interleaved with corners of one column hanging into adjacent columns, the effective horizontal pitch is similar to Choc-spacing (18.5mm) despite the large surface area. On the other hand, the vertical pitch is larger than MX-spacing (21.5mm). So far this is not causing me problems while typing.

In this design, function admittedly follows form. This first prototype is meant to help evaluate usability and ergonomics. The original concept had 36 keys (modified 3x5+3). The PCB and the matrix can fit four extra keys that are added in this prototype to investigate their potential usefulness. I may drop them in future revisions. Possible future improvements I would like to pursue include tenting, per-key RGB and maybe an integrated trackpad.

The name Mantis comes from the shape of the PCB resembling a mantis head and the hexagonal keys suggesting compound eyes.

## Attribution

The mantis picture on the front of the PCB is a modified and vectorized version of [this photo](https://wordpress.org/openverse/image/07787e94-05c0-4aa9-a530-9cb8ce2a4666) by Flickr user HolleyandChris.