/// A slot 7 weapon. Mechanically derived from Final Doomer's Quantum Accelerator;
/// assume that all code in this class and its related symbols is adapted from
/// the work of Yholl, used under no license.
/// Abbreviation: `CSC`
class biom_CasterCannon : biom_Weapon
{
	Default
	{
		Tag "$BIOM_CASTERCANNON_TAG";
		Obituary "$BIOM_CASTERCANNON_OB";

		Inventory.Icon 'CSCZZ0';
		Inventory.PickupMessage "$BIOM_CASTERCANNON_PKUP";

		Weapon.AmmoType 'biom_Slot67Ammo';
		Weapon.AmmoUse 40;
		Weapon.SelectionOrder SELORDER_BFG;
		Weapon.SlotNumber 7;

		biom_Weapon.DataClass 'biom_wdat_CasterCannon';
		biom_Weapon.Grade BIOM_WEAPGRADE_3;
		biom_Weapon.Family BIOM_WEAPFAM_SUPER;
	}

	States
	{
	Select:
		CSCA A 1 A_Raise;
		loop;
	Deselect:
		CSCA A 1 A_Lower;
	Ready:
	Ready.Main:
		CSCA A 1 A_WeaponReady;
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		CSCA A 27 {
			A_StartSound("biom/castercannon/charge", CHAN_AUTO);
			A_AlertMonsters(400);
		}
	Fire.Main:
		CSCA A 1 {
			A_biom_Recoil('biom_recoil_BFG');
			A_AlertMonsters();
			A_StartSound("biom/castercannon/fire", CHAN_AUTO);
			A_FireProjectile('biom_CasterCannonRayEmitter', 0.0, false);
			A_biom_CasterCannonRailAttacks();
			invoker.DepleteAmmo(false, false);
		}
		CSCA A 1 {
			A_biom_CasterCannonRailAttacks();
		}
		CSCA A 1 {
			A_biom_CasterCannonRailAttacks();
		}
	Fire.Finish:
		CSCA A 24;
		goto Ready.Main;
	Dryfire:
		CSCA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	}

	protected action void A_biom_CasterCannonRailAttacks()
	{
		A_RailAttack(
			20 * Random(8, 16),
			0,
			false,
			"", "White",
			RGF_SILENT | RGF_FULLBRIGHT | RGF_NOPIERCING,
			10,
			null,
			0, 0,
			4096,
			1,
			16.0,
			0.0,
			null,
			-4
		);

		A_RailAttack(
			0,
			4,
			false,
			"", "ffffff",
			RGF_SILENT | RGF_FULLBRIGHT,
			10,
			'biom_NoOpPuff',
			0, 0,
			1024,
			1,
			0.5,
			0.0,
			null,
			0
		);

		A_RailAttack(
			0,
			-4,
			false,
			"", "f999f9",
			RGF_SILENT | RGF_FULLBRIGHT,
			10,
			'biom_NoOpPuff',
			0, 0,
			1024,
			1,
			0.5,
			0.0,
			null,
			0
		);

		A_RailAttack(
			0,
			4,
			false,
			"", "f999f9",
			RGF_SILENT | RGF_FULLBRIGHT,
			10,
			'biom_NoOpPuff',
			0, 0,
			1024,
			1,
			0.5,
			0.0,
			null,
			-8
		);

		A_RailAttack(
			0,
			-4,
			false,
			"", "ffffff",
			RGF_SILENT | RGF_FULLBRIGHT,
			10,
			'biom_NoOpPuff',
			0, 0,
			1024,
			1,
			0.5,
			0.0,
			null,
			-8
		);
	}
}

class biom_wdat_CasterCannon : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}

class biom_CasterCannonRayEmitter : Actor
{
	Default
	{
		Projectile;

		Damage 0;
		Speed 25.0;
		Height 4.0;
		Radius 4.0;
		Species 'Player';

		+NOCLIP
		+THRUACTORS
		+THRUSPECIES
	}

	States
	{
	Death:
	Spawn:
		TNT1 A 1;
		TNT1 A 10 A_BFGSpray('BFGExtra');
		stop;
	}
}
