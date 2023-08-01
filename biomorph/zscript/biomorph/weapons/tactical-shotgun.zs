/// A slot 3 weapon. Behaves similarly to the vanilla Shotgun but is magazine-fed.
/// Balance-wise, a fast refire time is offset by the need to undergo a long reload.
/// Abbreviation: `TSG`
class biom_TacticalShotgun : biom_Weapon
{
	protected biom_wdat_TacticalShotgun data;

	flagdef roundChambered: dynFlags, 31;

	protected uint magazine;

	const MAGAZINE_CAPACITY = 7;

	Default
	{
		Tag "$BIOM_TACTICALSHOTGUN_TAG";
		Obituary "$BIOM_TACTICALSHOTGUN_OB";
		Scale 0.9;

		Inventory.Icon 'TSGZZ0';
		Inventory.PickupMessage "$BIOM_TACTICALSHOTGUN_PKUP";

		Weapon.AmmoType 'biom_Slot3Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;

		biom_Weapon.DataClass 'biom_wdat_TacticalShotgun';
		biom_Weapon.Grade BIOM_WEAPGRADE_1;
		biom_Weapon.Family BIOM_WEAPFAM_SHOTGUN;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		TSGS ABCD 2 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		TSGS DCBA 2;
		goto Ready.Main;
	Ready.Main:
		TSGA A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		// Baseline time: 8 tics.
		TSGA A 1;
		TSGA A 2 offset(0 + 7, 32 + 7)
		{
			A_StartSound("biom/tacshotgun/fire", CHAN_WEAPON);
			A_GunFlash();
			A_FireBullets(4.0, 0.5, 10, 5, 'biom_BulletPuff', FBF_NONE);
			A_biom_Recoil('biom_recoil_Shotgun');
			A_AlertMonsters();
			invoker.magazine -= 1;
			invoker.bRoundChambered = false;
		}
		TSGA A 1 offset(0 + 5, 32 + 5);
		TSGA A 1 offset(0 + 2, 32 + 2);
		TSGA A 1 offset(0 + 1, 32 + 1);
		TSGA A 2;
		TNT1 A 0 {
			if (invoker.magazine == 0)
				return ResolveState('Ready.Main');
			else
				return ResolveState('Cycle');
		}
	Cycle:
		TSG1 C 2 {
			A_StartSound("biom/shotgunpump/back");
			A_biom_Recoil('biom_recoil_ShotgunPump');
			invoker.bRoundChambered = true;
		}
		TSG1 D 2;
		TSG1 C 2 A_StartSound("biom/shotgunpump/forward");
		TSGA A 5;
		goto Ready.Main;
	Dryfire:
		TSGA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		TSG1 A 1 bright offset(0 + 3, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		TSG1 B 1 bright offset(0 + 3, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 0 A_Light(0);
		goto LightDone;
	Reload:
		TNT1 A 0 A_biom_CheckReload;
		// Baseline time: 57 tics.
		TSGR ABCDEFG 3;
		TSGR H 15;
		TSGR F 3 A_biom_Reload;
		TSGR FEDCBA 3;
		TNT1 A 0 {
			if (invoker.bRoundChambered)
				return ResolveState('Ready.Main');
			else
				return ResolveState('Cycle');
		}
		stop; // Unreachable
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		self.magazine = biom_TacticalShotgun.MAGAZINE_CAPACITY;
	}

	override void DetachFromOwner()
	{
		super.DetachFromOwner();
		self.magazine = 0;
	}

	override bool GetMagazine(in out biom_Magazine data, bool secondary) const
	{
		data.current = self.magazine;
		data.max = biom_TacticalShotgun.MAGAZINE_CAPACITY;
		data.cost = 1;
		data.output = 1;
		return true;
	}

	override void FillMagazine(uint amt)
	{
		self.magazine += amt;
	}
}

class biom_wdat_TacticalShotgun : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
