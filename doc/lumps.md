# Developer's Guide: Lump Specifications

## `BIOWEAP`

This is a JSON lump for setting characteristics about weapons which aren't suited to their class definitions. The top level item in this lump must be an object; its contents can be:

- An array with the key "`upgrades`". This array can contain objects, each of which must have three fields:
	- "`input`", a string with the name of a weapon class. The player must have this weapon to perform the upgrade.
	- "`output`", a string with the name of a different weapon class. The player receives this weapon if they perform the upgrade.
	- "`cost`", a number (integral only) representing how many Weapon Upgrade Kits the player will need to consume in order to perform the upgrade. 
- An object with the key "`loot`". This object can contain arrays with the following keys:
	- "`melee`"
	- "`pistols`"
	- "`shotguns`"
	- "`autoguns`"
	- "`launchers`"
	- "`energy`"
	- "`super`"  
	Each of these arrays can contain strings corresponding to weapon class names; these classes will be added to the loot table of the weapon category to which the array corresponds, automatically sorted by the weapon's grade. For example, putting the name of a weapon class `MyWeapon` into an "`autoguns`" array will result in Chaingunner Zombies possibly dropping that weapon alongside its other possible weapon drops, but only if the players have collectively found or crafted at least weapon of the same grade as `MyWeapon`.

## `BIOPERK`

Coming soon.
