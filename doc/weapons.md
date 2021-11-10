# Developer's Guide: Creating new Weapons

1. Define a new class derived from one of the following abstract classes:
	- `BIO_Weapon`
	- `BIO_DualWieldWeapon`
	- `BIO_MeleeWeapon` (applicable to, for example, guns with bayonets)
	- `BIO_DualMeleeWeapon` (applicable to weapons with a gun in one hand and a melee weapon in the other)
2. Define a grade from `BIO_GRADE_STANDARD`, `BIO_GRADE_SPECIALTY`, or `BIO_GRADE_CLASSIFIED`. In general, moving towards the latter means the gun is objectively better.
3. If your weapon is meant to be a unique, ensure that it sets the property `BIO_Weapon.Rarity` to `BIO_RARITY_UNIQUE`. You may want to set `BIO_Weapon.UniqueBase`; this will control what type of weapon yours will regress to if it gets a bad corruption result, but it's valid to leave this as null, if no base is suitable.
4. Define your weapon's affix masks. These govern what affixes should not be allowed to do to your weapon. Enabling a bit in one of these masks enables represents enabling that restriction. For most weapons (with a primary attack and no secondary attack), it is acceptable to set the property `BIO_Weapon.AffixMasks` to `BIO_WAM_NONE, BIO_WAM_ALL, BIO_WAM_NONE`.
5. Set `Weapon.SlotNumber`. Optionally set `Weapon.SelectionOrder` using one of the `BIO_Weapon.SELORDER_` constants, and/or set `Weapon.SlotPriority` using one of the `BIO_Weapon.SLOTPRIO` constants. 
6. Set the weapon's ammo properties: `AmmoGive`, `AmmoType`, and `AmmoUse`.
7. Define your weapon's core stats: fire type, fire count, damage range, and spread.
8. Define your weapon's magazine type(s). This can be a new ammo type specifically for your weapon class, or it can be one of the vanilla ammo types (`Clip`, `Shell`, `RocketAmmo`, `Cell`). If creating a new magazine ammo class, ensure it fits the definition of the `BIO_Magazine` mixin class in zscript/biomorph/weapons/base.zs.
9. Define your weapon's states.
	- `Deselect` and `Select` should be one frame with a length of 0 tics which calls `A_BIO_Deselect()` or `A_BIO_Select()` (respectively) and then stops. (These actions invoke callbacks and automatically use the weapon's switch speed variables.)
	- `Spawn` should be one frame with a length of 0 tics that does nothing, and then another frame with a length of 0 tics which calls the `A_BIO_Spawn()`. This state should then stop. (This action gets the weapon blinking in and out of a colour based on its rarity.)
10. If your weapon has modifiable fire rate or reload speed:
	- Override `GetFireTimes()`, `SetFireTimes()`, `GetReloadTimes()`, and `SetReloadTimes()`.
	- You may also want to override `GetFireTimeMinimums()` or `GetReloadTimeMinimums()` if you want certain frame tic lengths to be allowed to go down to 0.
	- Override `ResetStats()` to set these tic times back to their defaults.
	- Remember that `Flash` states may need `A_SetTics()` calls to look good if the state that they're meant to overlay changes its tic length.
	- **Tip:** when using `A_SetTics()` in an action function or anonymous function, call it before making any other calls for best results.
11. You will almost certainly want to override `StatsToString()`, since otherwise your weapon won't tell the player anything about itself. Useful functions for making this quick are `GenericFireDataReadout()`, `GenericSpreadReadout()`, `GenericFireTimeReadout()`, and `GenericReloadTimeReadout()`.
12. Optionally add the flags `WEAPON.BFG` or `WEAPON.EXPLOSIVE` to signal to bots how to use your weapon.
