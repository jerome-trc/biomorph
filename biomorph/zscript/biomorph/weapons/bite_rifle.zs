/// A Plasma Rifle counterpart.
class biom_BiteRifle : biom_Weapon
{
	Default
	{
		Tag "$BIOM_BITERIFLE_TAG";
		Obituary "$BIOM_BITERIFLE_OB";

		Inventory.Icon 'BTRZZ0';
		Inventory.PickupMessage "$BIOM_BITERIFLE_PKUP";

		Weapon.AmmoType 'biom_Slot67Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_PLASRIFLE;
		Weapon.SlotNumber 6;

		biom_Weapon.DataClass 'biom_wdat_BiteRifle';
		biom_Weapon.Grade BIOM_WEAPGRADE_2;
		biom_Weapon.Family BIOM_WEAPFAM_ENERGY;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		BTRS ABC 3 A_Lower;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		BTRS CBA 3;
		goto Ready.Main;
	Ready.Main:
		BTRA A 1 A_WeaponReady;
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		BTRA A 1 offset(0 + 5, 32 + 5)
		{
			invoker.owner.SpawnPlayerMissile('biom_Biter');
			invoker.DepleteAmmo(false, false);
			A_AlertMonsters();
			A_StartSound("biom/biterifle/fire/0", CHAN_WEAPON);
			A_GunFlash();
			A_biom_Recoil('biom_recoil_RapidFire');
		}
		BTRA A 1 offset(0 + 3, 32 + 3);
		BTRA A 1 offset(0 + 1, 32 + 1);
		goto Ready.Main;
	Dryfire:
		BTRA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		BTR1 A 1 bright offset(0 + 5, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		BTR1 B 1 bright offset(0 + 5, 32 + 5) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 1 bright offset(0 + 1, 32 + 3) A_Light(0);
		goto LightDone;
	}
}

class biom_wdat_BiteRifle : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}

class biom_Biter : PlasmaBall
{
	Default
	{
		DamageFunction 30;
		SeeSound "";
	}
}
