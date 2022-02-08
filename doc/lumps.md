# Developer's Guide: Lump Specifications

## `BIOWEAP`

This is a JSON lump for setting characteristics about weapons which aren't suited to their class definitions. The top-level item in this lump must be an object. Its supported contents are as follows.

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

You can also append `_X2` or `_X3` to any of these names to get the same cost but multiplied by 2 or 3 respectively. Note that the set of recipes generated is the square cross of the given input and output classes. This means that if three inputs and three outputs are given, nine recipes will be generated (one for each possible combination of input and output), all of the same cost.

Each weapon upgrade recipe object also supports the following optional fields:

- "`reversible`"; a boolean. If this is present and set to `true`, an extra upgrade recipe will be generated which has the same cost but with the input and output weapon classes flipped. This affects recipes with multiple defined input/outputs; the reverse of each part of the square cross will be generated too.

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

This is a JSON lump for defining the perk node graph. The top-level item in this lump must be an object. Its supported contents are as follows.

#### `perks` (object)

This object can contain only a selection of three arrays: `minor`, `major`, and `keystone`. Each of these arrays can only contain objects - each defining a perk - and each object must contain the following fields:

##### `uuid`

This is a string which uniquely identifies this perk node amongst all others. A node will not be parsed at all if its UUID overlaps with another, or is set to `"bio_start"`.

##### `class`

This is a string referring to the name of a class inheriting from `BIO_Perk`; this perk is applied once if the player commits to the perk.

##### `x` and `y`

These represent the node's position on the graph; note that both are stored as integers internally.

##### `tag`

This is a string which becomes the name shown to the player in the perk menu's tooltip. Whatever is here gets passed through localisation after being parsed.

##### `desc`

This is a string which becomes the description of the perk's effects shown to the player in the perk menu's tooltip. Whatever is here gets passed 
through localisation after being parsed.

##### `flavor`

This is a string which gets appended to the description of the perk's tooltip description in a different colour, and should be used for, as the name suggests, flavour text. Whatever is here gets passed through localisation after being parsed.

##### `icon`

This is a string corresponding to a sprite's name (e.g. `"BON1A0"`) or a path in the virtual filesystem leading to a graphic (e.g. `"graphics/perk/healthbonus_x2"`). This texture is drawn on the perk's node in the menu.

##### `neighbors`

This is an array containing UUIDs of other nodes. Every UUID given here will create a two-way connection between the defined node and the node belonging to that UUID. If you want to connect the node to the start point, add `"bio_start"` to the array. If you want the node to be accessible forever, regardless of what other perks the player has activated, leave this field undefined.

As you probably expect, it's illegal for a node to add its own UUID to its neighbours array.

##### `free_access`

This is an optional boolean field; if set to true, the node will always be accessible, regardless of the state of the rest of the graph.

#### `templates` (array)

As an alternative to defining perks using the fields above, one can also predefine perk node templates. A template needs to have a unique `id` field that sets it apart from all other templates, and must also have a `class`. You can then define a node in the `perks` array, assign it a template using the `"template"` key, and then give it a UUID, position, and neighbour array.
