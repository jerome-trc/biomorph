/// A slot 3-super weapon. Has two chambers and two tube magazines.
///
/// Both chambers can be fired at once, after which the weapon must pump.
/// Alternatively, one chamber can be fired at a time; the weapon cannot pump
/// after only one, but must pump after both chambers are emptied.
/// Whenever the player stops firing, reloading starts automatically, but can
/// be interrupted to fire or switch weapons.
///
/// Abbreviation: `PSD` (pump shotgun, double)
class biom_DoublePumpShotgun : biom_Weapon
{
	flagdef leftChambered: dynFlags, 30;
	flagdef rightChambered: dynFlags, 31;

	protected uint magazine;

	const MAGAZINE_CAPACITY = 7 * 2;
	const NUM_PELLETS = 10;

	Default
	{
		Tag "$BIOM_DOUBLEPUMPSHOTGUN_TAG";
		Obituary "$BIOM_DOUBLEPUMPSHOTGUN_OB";

		Inventory.Icon 'PSDZZ0';
		Inventory.PickupMessage "$BIOM_DOUBLEPUMPSHOTGUN_PKUP";

		Weapon.AmmoType 'biom_Slot3Ammo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;

		biom_Weapon.DataClass 'biom_wdat_DoublePumpShotgun';
		biom_Weapon.Grade BIOM_WEAPGRADE_2;
		biom_Weapon.Family BIOM_WEAPFAM_SUPERSHOTGUN;
	}

	States
	{
	Select:
		TNT1 A 0 A_Raise;
		loop;
	Deselect:
		PSDS ABC 3 A_Lower;
		goto Deselect.Repeat;
	Deselect.Repeat:
		TNT1 A 1 A_Lower;
		loop;
	Ready:
		PSDS CBA 3;
		goto Ready.Main;
	Ready.Main:
		PSDA A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;
	Fire:
		TNT1 A 0 A_biom_CheckAmmo(multi: 2);
		goto Fire.Double;
	AltFire:
		TNT1 A 0 A_biom_CheckAmmo;
		TNT1 A 0
		{
			if (invoker.bLeftChambered || invoker.bRightChambered)
				return ResolveState('Fire.Single');
			else
				return ResolveState('Pump');
		}
		stop; // Unreachable
	Fire.Single:
		PSDA A 2 offset(0 + 7, 32 + 7)
		{
			if (invoker.bLeftChambered)
			{
				invoker.bLeftChambered = false;
				A_biom_DoublePumpShotgunFireSingle('Flash.Left');
			}
			else
			{
				invoker.bRightChambered = false;
				A_biom_DoublePumpShotgunFireSingle('Flash.Right');
			}
		}
		PSDA A 1 offset(0 + 5, 32 + 5);
		PSDA A 1 offset(0 + 2, 32 + 2);
		PSDA A 1 offset(0 + 1, 32 + 1);
		TNT1 A 0
		{
			if (invoker.magazine == 0)
				return ResolveState('Reload');
			else if (!invoker.bRightChambered)
				return ResolveState('Pump');
			else
				return ResolveState('Ready.Main');
		}
	Fire.Double:
		PSDA A 2 offset(0 + 9, 32 + 9)
		{
			A_biom_DoublePumpShotgunFireBullets(2);
			invoker.bLeftChambered = false;
			invoker.bRightChambered = false;
			invoker.magazine -= 2;
			A_AlertMonsters();
			A_StartSound("biom/doublepumpshotgun/fire/double", CHAN_WEAPON);
			A_GunFlash('Flash.Double');
			A_biom_Recoil('biom_recoil_DoubleShotgun');
		}
		PSDA A 1 offset(0 + 6, 32 + 6);
		PSDA A 1 offset(0 + 4, 32 + 4);
		PSDA A 1 offset(0 + 2, 32 + 2);
		TNT1 A 0
		{
			if (invoker.magazine == 0)
				return ResolveState('Reload');
			else
				return ResolveState('Pump');
		}
	Pump:
		PSDA A 2;
		PSD1 D 4
		{
			A_StartSound("biom/shotgunpump/back", CHAN_AUTO);
			A_biom_Recoil('biom_recoil_ShotgunPump');
			invoker.bLeftChambered = true;
			invoker.bRightChambered = true;
		}
		PSD1 E 4;
		PSD1 D 4 A_StartSound("biom/shotgunpump/forward", CHAN_AUTO);
		PSDA A 2;
		PSDA A 1 A_ReFire;
		goto Reload;
	Flash.Left:
		PSD1 A 1 bright offset(0 + 7, 32 + 7) A_Light(2);
		PSD1 A 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.Right:
		PSD1 B 1 bright offset(0 + 7, 32 + 7) A_Light(2);
		PSD1 B 1 bright offset(0 + 7, 32 + 7) A_Light(1);
		goto Flash.Finish;
	Flash.Double:
		PSD1 C 1 bright offset(0 + 9, 32 + 9) A_Light(2);
		PSD1 C 1 bright offset(0 + 9, 32 + 9) A_Light(1);
		goto Flash.Finish;
	Flash.Finish:
		TNT1 A 0 A_Light(0);
		goto LightDone;
	Dryfire:
		PSDA A 1 offset(0, 32 + 1);
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 3) A_StartSound("biom/dryfire/ballistic");
		#### # 1 offset(0, 32 + 2);
		#### # 1 offset(0, 32 + 1);
		goto Ready.Main;
	Reload:
		TNT1 A 0 A_biom_CheckReload;
		TNT1 A 0 A_StartSound("biom/pumpshotgun/switch", CHAN_AUTO);
		PSDA A 3;
		PSDR ABC 3 A_biom_InterruptReload;
		goto Reload.Repeat;
	Reload.Repeat:
		PSDR DD 3 A_biom_InterruptReload;
		PSDR E 3
		{
			biom_Magazine mag;
			invoker.GetMagazine(mag);
			A_biom_Reload(Min(2, mag.max - mag.current));
			A_StartSound("biom/pumpshotgun/load", CHAN_AUTO);
		}
		PSDR DD 3 A_biom_InterruptReload;
		TNT1 A 0
		{
			if (invoker.CanReload())
				return ResolveState('Reload.Repeat');
			else
				return ResolveState('Reload.Finish');
		}
	Reload.Finish:
		PSDR CBA 3;
		PSDA A 3;
		TNT1 A 0
		{
			if (invoker.bRightChambered)
				return ResolveState('Ready.Main');
			else
				return ResolveState('Pump');
		}
		stop; // Unreachable
	}

	/*

	Baseline timing stats (tics):
	- Vanilla Super Shotgun: 62
	- Fire: 5
	- Pump: 17
	- Reload: 39

	*/

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		self.magazine = biom_DoublePumpShotgun.MAGAZINE_CAPACITY;
		self.bLeftChambered = true;
		self.bRightChambered = true;
	}

	override bool GetMagazine(in out biom_Magazine data, bool secondary) const
	{
		data.current = self.magazine;
		data.max = biom_DoublePumpShotgun.MAGAZINE_CAPACITY;
		data.cost = 1;
		data.output = 1;
		return true;
	}

	override void FillMagazine(uint amt)
	{
		self.magazine += amt;
	}

	protected action void A_biom_DoublePumpShotgunFireSingle(statelabel flash)
	{
		A_biom_DoublePumpShotgunFireBullets(1);
		invoker.magazine -= 1;
		A_AlertMonsters();
		A_StartSound("biom/doublepumpshotgun/fire/single", CHAN_WEAPON);
		A_GunFlash(flash);
		A_biom_Recoil('biom_recoil_Shotgun');
	}

	protected action void A_biom_DoublePumpShotgunFireBullets(uint multi)
	{
		A_FireBullets(
			12.0,
			7.5,
			biom_DoublePumpShotgun.NUM_PELLETS * multi,
			5,
			'biom_ShotPellet',
			FBF_NONE
		);
	}

	protected action state A_biom_InterruptReload()
	{
		if (invoker.owner.player != null &&
			invoker.owner.player.pendingWeapon != WP_NOCHANGE)
			return ResolveState('Reload.Finish');

		if (invoker.magazine <= 0)
			return state(null);

		if (!invoker.bRightChambered)
			return ResolveState('Pump');
		else
		{
			if (invoker.owner.player.cmd.buttons & BT_ALTATTACK)
				invoker.bAltFire = true;
			else
				invoker.bAltFire = false;

			A_ReFire();
		}

		return state(null);
	}
}

class biom_wdat_DoublePumpShotgun : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
