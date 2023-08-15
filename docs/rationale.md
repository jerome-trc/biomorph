# Rationale

This is a living document intended to rationalize Biomorph's existence, as well as all of its underlying design decisions.

## Why Biomorph?

Biomorph exists to occupy an as-of-yet unfilled niche: a GZDoom weapon overhaul mod which

1. is balanced to accommodate any level made for Doom or Doom II - no exceptions - but without being so plainly overpowered as to eliminate the fun of the game;
2. is satisfying to use at a baseline but also offers high replay value through a degree of randomness tempered by player control;
3. is designed with the "pistol start" (i.e. per-level inventory reset) playstyle as a first class citizen in such a way as to not clash with requirement 2.

In terms of prior art:
- [DoomRL Arsenal](https://forum.zdoom.org/viewtopic.php?f=43&t=37044) (by Yholl et al.) is precluded by requirements 1 and 2.
- [LegenDoom](https://forum.zdoom.org/viewtopic.php?t=51035) (by Yholl et al.) is precluded by requirement 2.
- [Custom Gun](https://forum.zdoom.org/viewtopic.php?f=43&t=54303) (by Mikk-) is precluded by requirement 2 and makes the player so strong as to fail requirement 1 (and also is unfinished and unmaintained).
- [Gun Bonsai](https://forum.zdoom.org/viewtopic.php?t=76080) (by ToxicFrog et al.) also puts the odds too far in the player's favour to meet requirement 1.

Mind that Biomorph was created largely to answer the shortcomings of this prior art while bringing along the best parts of them. If you see a gameplay design or implementation that appears similar to something in a project listed above, it likely was very deliberately derived wholly or in part.
