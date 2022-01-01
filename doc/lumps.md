# Developer's Guide: Lump Specifications

## `BIOWEAP`

This is a JSON lump for setting characteristics about weapons which aren't suited to their class definitions. The top level item in this lump must be an object. Its supported contents are as follows.

#### `upgrades` (array)

This array can contain only objects. Each of these objects must have the following three fields:

##### `input`

If this is a class name string, that class is the input of the recipe (the weapon the player must be holding to attempt the upgrade).
If it's a special placeholder token in the format `$GRADE_CATEGORY`, where `GRADE` is one of `STANDARD`, `SPECIALTY`, or `CLASSIFIED`, and `CATEGORY` is one of the categories listed in [upgrades_auto](#upgrades_auto-object).
If it's an array, then each input is given its own recipe.

##### `output`

If this is a class name string, that class is the output of the recipe (the weapon the player is given if they carry out the upgrade).
This also supports the same placeholder token syntax as `input`; it can also take an array,
wherein each output is given its own recipe.

##### `cost`

This represents how many upgrade mutagens the player will need to consume in order to perform the upgrade. This can be either a number or a string; the number will be interpreted as-is, but strings are resolved to symbolic constants if possible. The allowed constants are as follows:

- `"STANDARD_TO_STANDARD"`
- `"STANDARD_TO_SPECIALTY"`
- `"SPECIALTY_TO_SPECIALTY"`
- `"SPECIALTY_TO_CLASSIFIED"`
- `"CLASSIFIED_TO_CLASSIFIED"`

Note that the set of recipes generated is the square cross of the given input and output classes. This means that if three inputs and three outputs are given, nine recipes will be generated (one for each possible combination of input and output), all of the same cost.

Each weapon upgrade recipe object also supports the following optional fields:

- "`reversible`" (**optional**); a boolean. If this is present and set to `true`, an extra upgrade recipe will be generated which has the same cost but with the input and output weapon classes flipped. This affects recipes with multiple defined input/outputs; the reverse of each part of the square cross will be generated too.

#### `upgrades_auto` (object)

This object can contain arrays with the following keys:

- "`melee`"
- "`pistol`"
- "`shotgun`"
- "`ssg`" or "`supershotgun`"
- "`rifle`"
- "`autogun`"
- "`launcher`"
- "`energy`"
- "`super`"  

Each of these arrays can contain strings corresponding to weapon class names. For every category, reversible weapon upgrade recipes will be generated between weapons in each grade, and one-way weapon upgrade recipes will be generated between weapons in a grade and weapons in the grade above (assuming that a higher grade exists).

#### `loot` (object)

This object can contain arrays with the same keys as `upgrades_auto`.

Each of these arrays can contain strings corresponding to weapon class names; these classes will be added to the loot table of the weapon category to which the array corresponds, automatically sorted by the weapon's grade. For example, putting the name of a weapon class `MyWeapon` into an "`autoguns`" array will result in Chaingunner Zombies possibly dropping that weapon alongside its other possible weapon drops, but only if the players have collectively found or crafted a weapon of at least the same grade as `MyWeapon`.

## `BIOPERK`

Coming soon.
