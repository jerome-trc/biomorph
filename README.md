# Biomorph

Gameplay mod for GZDoom intended to introduce variety into player arsenals through randomness mixed with choices.

Inspirations and relevant prior art:
- [Final Doomer](https://forum.zdoom.org/viewtopic.php?t=55061) (by Yholl, Sgt. Shivers, et al.)
- [DoomRL Arsenal](https://forum.zdoom.org/viewtopic.php?f=43&t=37044) (by Yholl et al.)
- [DoomRL Arsenal Extended](https://forum.zdoom.org/viewtopic.php?t=70549) (by Cutmanmike et al.)
- [LegenDoom](https://forum.zdoom.org/viewtopic.php?t=51035) (by Yholl et al.)
- [Custom Gun](https://forum.zdoom.org/viewtopic.php?f=43&t=54303) (by Mikk-)
- [Gun Bonsai](https://forum.zdoom.org/viewtopic.php?t=76080) (by ToxicFrog et al.)

Biomorph is early in development; expect its features and graphical/audio presentation to change rapidly.

A complete list of attributions and third-party licensing information can be found [here](/ATTRIB.md).

Any part of Biomorph not covered by an attribution in the document linked above is:
- provided under the MIT License if it is "source code"; that is, one of the (G)ZDoom domain-specific languages, Action Code Script (ACS), Eternity Definition Files (EDF), or Eternity Engine's Aeon/AngelScript. See the [attached document](/LICENSE) or [here](https://choosealicense.com/licenses/mit/).
- provided under the Creative Commons Attribution-ShareAlike 4.0 International License, if it is not "source code". To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

## Contents

- The main mod, under `/biomorph`.
- Blender files used to generate sprites.
- `/pawn-patch` to prevent crashes on WADs which would otherwise override the player class, such as Valiant.
- A compatibility layer for [Corruption Cards](https://forum.zdoom.org/viewtopic.php?f=43&t=67939), adding bespoke gameplay integration, under `/ccards`.
- An add-on with special content for the [DoomRL Arsenal Monster Pack](https://forum.zdoom.org/viewtopic.php?f=43&t=37044), under `/drlm`.
