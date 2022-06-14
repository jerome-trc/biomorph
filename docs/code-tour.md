# Guided Code Tour

Mostly for jogging my own memory.

## RNG Tables

The following table IDs are used by Biomorph for calls to `Random()` family functions:
- `BIO_Loot`, for the implementation of `BIO_LootTable`. Also used to determine if a `Clip` item, when replaced, will be accompanied by a random pistol.
- `BIO_WMod`, for rolling the effects of mutagens on weapons, and generating weapon mod node graphs.

## Colour Coding

- Red means something is worse than its norm.
- Yellow is for informative text, as per the default translation of the output of `Actor::A_Print()`.
- Green means something is better than its norm. Also represents infinity/invulnerability, as per Doom 2's vanilla invulnerability sphere.
- Cyan is the de facto thematic colour for the mod. Sometimes it gets mixed with light blue, aqua, and light green in gradients. It represents mutation, and is used in text to signal that something is different from its norm. 
- `\c[LightBlue]` is used for user input-related information, e.g. a key prompt.
- Purple represents chaos and entropy.
