# Developer's Guide: Creating new fired things

## Projectiles

1. Define a new class derived from one of the following abstract classes:
	- `BIO_FastProjectile`, if making a projectile meant to act like a bullet puff.
	- `BIO_Projectile`, if making any other type of projectile.
2. Set the properties `Tag` and `BIO_Projectile.PluralTag` or `BIO_FastProjectile.PluralTag`. These are used when displaying your weapon's stats to tell the player what their weapon is firing.
3. Define your projectile's states. The state which your projectile loops through while travelling should periodically call `A_Travel()`; how often it does so is up to you, although this should generally be as often as 3 tics or fewer.
4. When your projectile dies, call `A_ProjectileDeath()`. This does not necessarily have to be immediately after entering a death state.
5. Check the properties which come with your chosen abstract class to see if any of them are applicable to your projectile.
6. Check the list of `BIO_ProjectileMetaFlags` to see if any of them are applicable to your projectile. These are used to govern affix applicability, so don't forget them.

## Puffs

1. Define a new class derived from the abstract class `BIO_Puff`.
2. Set the properties `Tag` and `BIO_Puff.Tag`. These are used when displaying your weapon's stats to tell the player what their weapon is firing.
3. Define your puff's states. There are no special requirements here.
4. Check the list of `BIO_ProjectileMetaFlags` to see if any of them are applicable to your projectile. These are used to govern affix applicability, so don't forget them.
