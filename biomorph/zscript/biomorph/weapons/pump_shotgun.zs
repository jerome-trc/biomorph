/// A slot 3 weapon. Behaves similarly to Final Doomer's Borstal Shotgun.
/// Has an 8-round magazine and starts a reload attempt as soon as the user
/// releases the trigger. If the player has spare ammo and fires one round at a
/// time, this is functionally equivalent to the vanilla Shotgun.
/// Abbreviation: `PSG`
class biom_PumpShotgun : biom_Weapon
{
	flagdef roundChambered: dynFlags, 31;

	protected uint magazine;

	const MAGAZINE_CAPACITY = 8;

	Default
	{
		Tag "$BIOM_PUMPSHOTGUN_TAG";
		Obituary "$BIOM_PUMPSHOTGUN_OB";

		Inventory.Icon 'PSGZZ0';
		Inventory.PickupMessage "$BIOM_PUMPSHOTGUN_PKUP";

		Weapon.AmmoType 'biom_Slot3Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SHOTGUN;
		Weapon.SlotNumber 3;
		Weapon.UpSound "biom/pumpshotgun/switch";

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
		PSGS ABC 3 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		PSGS CBA 3;
		goto Ready.Main;
	Ready.Main:
		PSGA A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo;
		// Baseline time (pump included): 14 tics.
		// Vanilla shotgun time to fire and pump: 44 tics.
		PSGA A 2 offset(0 + 7, 32 + 7)
		{
			A_FireBullets(4.0, 0.5, 10, 5, 'biom_BulletPuff', FBF_NONE);
			invoker.magazine -= 1;
			A_AlertMonsters();
			A_StartSound("biom/pumpshotgun/fire", CHAN_WEAPON);
			A_GunFlash();
			A_biom_Recoil('biom_recoil_Shotgun');
		}
		PSGA A 1 offset(0 + 5, 32 + 5);
		PSGA A 1 offset(0 + 2, 32 + 2);
		PSGA A 1 offset(0 + 1, 32 + 1);
		TNT1 A 0 {
			if (invoker.magazine == 0)
				return ResolveState('Ready.Main');
			else
				return ResolveState('Pump');
		}
	Pump:
		PSGA A 1;
		PSG1 C 2 {
			A_StartSound("biom/shotgunpump/back", CHAN_AUTO);
			A_biom_Recoil('biom_recoil_ShotgunPump');
			invoker.bRoundChambered = true;
		}
		PSG1 D 2;
		PSG1 C 2 A_StartSound("biom/shotgunpump/forward");
		PSGA A 1;
		PSGA A 1 A_ReFire;
		goto Reload;
	Flash:
		TNT1 A 0 A_Jump(256, 'Flash.A', 'Flash.B');
		TNT1 A 0 A_Unreachable;
	Flash.A:
		PSG1 A 2 bright offset(0 + 7, 32 + 7) A_Light(2);
		PSG1 A 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.B:
		PSG1 B 1 bright offset(0 + 7, 32 + 7) A_Light(2);
		PSG1 B 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 0 A_Light(0);
		goto LightDone;
	Dryfire:
		PSGA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Reload:
		TNT1 A 0 A_biom_CheckReload;
		// Baseline time for start + 1 shell + finish: 34 tics.
		TNT1 A 0 A_StartSound("biom/pumpshotgun/switch", CHAN_AUTO);
		PSGR AB 3;
		goto Reload.Repeat;
	Reload.Repeat:
		PSGR CD 4 A_biom_InterruptReload;
		PSGR E 5 A_biom_InterruptReload;
		PSGR F 3
		{
			A_biom_Reload(1);
			A_StartSound("biom/pumpshotgun/load");
		}
		PSGR GHI 2 A_biom_InterruptReload;
		TNT1 A 0
		{
			if (invoker.CanReload())
				return ResolveState('Reload.Repeat');
			else
				return ResolveState('Reload.Finish');
		}
	Reload.Finish:
		TNT1 A 0 A_StartSound("biom/pumpshotgun/switch");
		PSGR BA 3;
		TNT1 A 0
		{
			if (invoker.bRoundChambered)
				return ResolveState('Ready.Main');
			else
				return ResolveState('Pump');
		}
		stop; // Unreachable
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		self.magazine = biom_PumpShotgun.MAGAZINE_CAPACITY;
	}

	override void DetachFromOwner()
	{
		super.DetachFromOwner();
		self.magazine = 0;
	}

	override bool GetMagazine(in out biom_Magazine data, bool secondary) const
	{
		data.current = self.magazine;
		data.max = biom_PumpShotgun.MAGAZINE_CAPACITY;
		data.cost = 1;
		data.output = 1;
		return true;
	}

	override void FillMagazine(uint amt)
	{
		self.magazine += amt;
	}

	protected action state A_biom_InterruptReload()
	{
		if (invoker.owner.player != null &&
			invoker.owner.player.pendingWeapon != WP_NOCHANGE)
			return ResolveState('Reload.Finish');

		A_ReFire();
		return state(null);
	}
}

class biom_PumpShotgunData : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
