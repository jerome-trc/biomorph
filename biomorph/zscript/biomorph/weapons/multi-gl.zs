/// A slot 5 weapon. Behaves functionally identically to the vanilla Rocket Launcher,
/// except projectiles bounce once, at which point they become affected by gravity.
/// Abbreviation: `MGL`
class biom_MultiGL : biom_Weapon
{
	Default
	{
		Tag "$BIOM_MULTIGL_TAG";
		Obituary "$BIOM_MULTIGL_OB";

		Inventory.Icon 'MGLZZ0';
		Inventory.PickupMessage "$BIOM_MULTIGL_PKUP";

		Weapon.AmmoType 'biom_Slot5Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER;
		Weapon.SlotNumber 5;

		biom_Weapon.DataClass 'biom_wdat_MultiGL';
		biom_Weapon.Family BIOM_WEAPFAM_LAUNCHER;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		MGLS ABC 3 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 0 A_Lower;
		loop;
	Ready:
		MGLS CBA 3;
		goto Ready.Main;
	Ready.Main:
		MGLA A 1 A_WeaponReady;
		loop;
	Fire:
	AltFire:
		TNT1 A 0 A_biom_CheckAmmo;
		MGL1 A 3 offset(0 + 7, 32 + 7)
		{
			let proj = SpawnPlayerMissile('biom_Grenade40mm');

			if (proj != null && invoker.bAltFire)
			{
				proj.bBounceOnCeilings = true;
				proj.bBounceOnFloors = true;
				proj.bBounceOnWalls = true;
			}

			invoker.DepleteAmmo(false, false);
			A_AlertMonsters();
			A_StartSound("biom/multigl/fire", CHAN_WEAPON);
			A_biom_Recoil('biom_recoil_Heavy');
		}
		MGL1 B 3 offset(0 + 5, 32 + 5);
		MGL1 C 3 offset(0 + 2, 32 + 2);
		MGLA A 3 offset(0 + 1, 32 + 1);
		MGLA A 8;
		goto Ready.Main;
	Dryfire:
		MGLA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	}

	protected action void A_biom_MultiGLFire()
	{

	}

	/*

	Baseline timing stats (tics):
	- Vanilla Rocket Launcher: 20
	- Fire: 20

	*/
}

class biom_wdat_MultiGL : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
