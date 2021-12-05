# Developer's Guide: Creating new Weapons

1. Define a new class derived from one of the following abstract classes:
	- `BIO_Weapon`
	- `BIO_DualWieldWeapon`
2. Define a grade from `BIO_GRADE_STANDARD`, `BIO_GRADE_SPECIALTY`, or `BIO_GRADE_CLASSIFIED`. In general, moving towards the latter means the weapon is objectively better.
3. If your weapon is meant to be a unique, ensure that it sets the property `BIO_Weapon.Rarity` to `BIO_RARITY_UNIQUE`. You may want to set `BIO_Weapon.UniqueBase`; this will control what type of weapon yours will regress to if it gets a bad corruption result, but it's valid to leave this as null, if no base is suitable.
4. Define your weapon's flags and affix mask. These are used to determine affix compatibility; some affixes, for instance, are only compatible with pistols (and therefore check for `BIO_WF_PISTOL`) or rely on the weapon having a magazine (and therefore check if the weapon isn't flagged with `BIO_WAM_MAGAZINESIZE`).
5. Set `Weapon.SlotNumber`. Optionally set `Weapon.SelectionOrder` using one of the `BIO_Weapon.SELORDER_` constants, and/or set `Weapon.SlotPriority` using one of the `BIO_Weapon.SLOTPRIO_` constants. 
6. Set the weapon's ammo properties: `AmmoGive`, `AmmoType`, and `AmmoUse`.
7. Define your weapon's magazine type(s). This can be a new ammo type specifically for your weapon class, or it can be one of the vanilla ammo types (`Clip`, `Shell`, `RocketAmmo`, `Cell`). If creating a new magazine ammo class, ensure it fits the definition of the `BIO_Magazine` mixin class in zscript/biomorph/weapons/base.zs.
8. Define your weapon's states.
	- `Deselect` and `Select` should be one frame with a length of 0 tics which calls `A_BIO_Deselect()` or `A_BIO_Select()` (respectively) and then stops. (These actions invoke callbacks and automatically use the weapon's switch speed variables.)
	- `Spawn` should be one frame with a length of 0 tics that does nothing, and then another frame with a length of 0 tics which calls the `A_BIO_Spawn()`. This state should then stop. (This action gets the weapon blinking in and out of a colour based on its rarity.)
9. Build your weapon's pipelines. These are the structures which control what happens when your weapon fires (what actor comes out, whether it's a projectile or hitscan, how much spread there is, etc.). This should all happen in an override of the `InitPipelines()` function. Preferably, you'll want to get a new pipeline from out of calling `BIO_WeaponPipelineBuilder.Create().Build()`, with calls to the builder's functions in between "create" and "build".
10. Create your weapon's state time groups. These serve to store the duration of your weapon's firing and reloading actions, so that they can be modified by affixes, and so that the player can be told about how long these actions take. `InitFireTimes()` and `InitReloadTimes()` should be used accordingly.
11. Remember that your weapon won't appear in loot drop tables (and can't be the input or output of upgrades) if your mod doesn't have a BIOWEAP lump. See [the relevant documentation for more information](/doc/lumps.md##BIOWEAP).
