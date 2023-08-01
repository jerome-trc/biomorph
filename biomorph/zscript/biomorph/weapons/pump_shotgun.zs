/// A slot 3 weapon. Behaves functionally identically to vanilla Doom's shotgun.
/// Abbreviation: `870`
class biom_PumpShotgun : biom_Weapon
{
	protected biom_PumpShotgunData data;

	Default
	{
		Tag "$BIOM_PUMPSHOTGUN_TAG";
		Obituary "$BIOM_PUMPSHOTGUN_OB";

		Inventory.Icon '870AZ0';
		Inventory.PickupMessage "$BIOM_PUMPSHOTGUN_PKUP";

		Weapon.AmmoType 'biom_Slot3Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;

		biom_Weapon.DataClass 'biom_PumpShotgunData';
		biom_Weapon.Grade BIOM_WEAPGRADE_1;
		biom_Weapon.Family BIOM_WEAPFAM_SHOTGUN;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		870S ABCDE 2 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		870S EDCBA 2;
		goto Ready.Main;
	Ready.Main:
		870A A 1 A_WeaponReady;
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		// Baseline time: 7 ticks.
		870A A 1;
		870A A 2 offset(0 + 7, 32 + 7)
		{
			A_FireBullets(4.0, 0.5, 10, 5, 'biom_BulletPuff', FBF_NONE);
			invoker.DepleteAmmo(false, false);
			A_AlertMonsters();
			A_StartSound("biom/pumpshotgun/fire", CHAN_WEAPON);
			A_GunFlash();
			A_biom_Recoil('biom_recoil_Shotgun');
		}
		870A A 1 offset(0 + 5, 32 + 5);
		870A A 1 offset(0 + 2, 32 + 2);
		870A A 1 offset(0 + 1, 32 + 1);
		870A A 2;
		goto Cycle;
	Cycle:
		// Baseline time: 40 ticks (4 faster than vanilla Shotgun).
		870A B 2 A_StartSound("biom/pumpshotgun/pumpback");
		870A C 1;
		870A D 3;
		870A E 4;
		870A FGHI 4;
		870A HGF 2;
		870A E 2 A_StartSound("biom/pumpshotgun/pumpforward");
		870A DCA 2;
		goto Ready.Main;
	Flash:
		870F A 2 bright offset(0 + 7, 32 + 7) A_Light(2);
		TNT1 A 1 bright offset(0 + 5, 32 + 5) A_Light(1);
		goto LightDone;
	Dryfire:
		870A A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	}
}

class biom_PumpShotgunData : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
