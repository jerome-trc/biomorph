class BIO_ProximityLauncher : BIO_Weapon
{
	Default
	{
		Tag "$BIO_PROXIMITYLAUNCHER_TAG";
		
		Inventory.Icon 'PRXLZ0';
		Inventory.PickupMessage "$BIO_PROXIMITYLAUNCHER_PKUP";
	
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.KickBack 200;
		Weapon.SelectionOrder SELORDER_RLAUNCHER_SPEC;
		Weapon.SlotNumber 5;
		Weapon.SlotPriority SLOTPRIO_SPECIALTY;

		BIO_Weapon.Grade BIO_GRADE_SPECIALTY;
		BIO_Weapon.MagazineSize 3;
		BIO_Weapon.MagazineType 'BIO_Mag_ProximityLauncher';
		BIO_Weapon.PlayerVisual BIO_PVIS_GRENADELAUNCHER;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Projectile('BIO_ProxMineProj', 1)
			.SingleDamage(0)
			.Splash(176, 176)
			.FireSound("bio/weap/proxlauncher/fire")
			.CustomReadout(StringTable.Localize("$BIO_PROXLAUNCHER_DETONATE"))
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire'));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Reload'));
	}

	States
	{
	Ready:
		PRXL A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PRXL A 0 A_BIO_Deselect;
		Stop;
	Select:
		PRXL A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_AutoReload;
		PRXL B 4 Bright
		{
			A_SetFireTime(0);
			A_BIO_Fire();
			A_FireSound();
			A_PresetRecoil('BIO_Recoil_RocketLauncher');
		}
		PRXL C 5 A_SetFireTime(1);
		PRXL D 5 A_SetFireTime(2);
		PRXL E 4 A_SetFireTime(3);
		PRXL A 24 A_SetFireTime(4);
		PRXL A 1 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0
		{
			let iter = ThinkerIterator.Create('BIO_ProxMine');

			while (true)
			{
				let mine = BIO_ProxMine(iter.Next());
				if (mine == null) break;
				if (mine.Target != invoker.Owner) continue;
				mine.TouchOff = true;
			}
		}
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		PRXL A 1 A_WeaponReady(WRF_NOFIRE);
		PRXL A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		PRXL A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		PRXL A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		PRXL A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		PRXL A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		PRXL A 45 Offset(0, 32 + 30) 
		{
			A_SetReloadTime(6);
			A_PresetRecoil('BIO_Recoil_HeavyReload');
		}
		PRXL A 1 Offset(0, 32 + 18)
		{
			A_SetReloadTime(7);
			A_LoadMag();
			A_PresetRecoil('BIO_Recoil_HeavyReload', invert: true);
		}
		PRXL A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		PRXL A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		PRXL A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		PRXL A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		PRXL A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		PRXL A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Spawn:
		PRXL Z 0;
		PRXL Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_Mag_ProximityLauncher : Ammo { mixin BIO_Magazine; }

class BIO_ProxMineProj : BIO_Projectile
{
	Default
	{
		-NOGRAVITY
		-SLIDESONWALLS
		+CANBOUNCEWATER
		+NOTARGET

		BounceType 'Doom';
		BounceFactor BIO_ProxMine.BOUNCE_FACTOR;
		WallBounceFactor BIO_ProxMine.BOUNCE_FACTOR;

		Height 8;
		Radius 10;
		Scale 0.9;
		Speed 40;
		Tag "$BIO_PROXMINE_TAG";

		BIO_Projectile.PluralTag "$BIO_PROXMINE_TAG_PLURAL";
		BIO_Projectile.Splash 176, 176;
	}

	States
	{
	Spawn:
		PROX A 0;
		PROX A 1 A_CheckFloor('Planted');
		Loop;
	Planted:
		PROX A 1 A_StartSound("bio/proj/proximity/hit", CHAN_AUTO);
		PROX A 0
		{
			let mine = BIO_ProxMine(A_SpawnProjectile('BIO_ProxMine',
				flags: CMF_TRACKOWNER));

			if (mine != null)
			{
				mine.SplashDamage = invoker.SplashDamage;
				mine.SplashRadius = invoker.SplashRadius;
			}
		}
		Stop;
	Death:
		PRXD A 2 Bright
		{
			A_Stop();
			bNoGravity = true;
			A_SetTranslucent(0.5, 1);
			A_ProjectileDeath();
			A_StartSound("weapons/rocklx", CHAN_AUTO, attenuation: 0.8);
		}
		PRXD BCDEFGHIJKLMNOPQRSTU 2 Bright;
		Stop;
	}
}

class BIO_ProxMine : Actor
{
	const BOUNCE_FACTOR = 0.5;

	bool TouchOff;
	int SplashDamage, SplashRadius;

	Default
	{
		-NOGRAVITY
		-SLIDESONWALLS
		+CANBOUNCEWATER
		+MOVEWITHSECTOR
		+NOTARGET
		+THRUGHOST

		Projectile;

		BounceType 'Doom';
		BounceFactor BIO_ProxMine.BOUNCE_FACTOR;
		WallBounceFactor BIO_ProxMine.BOUNCE_FACTOR;

		Damage (0);
		Height 8;
		Radius 10;
		Scale 0.9;
		Speed 0;
	}

	final override void BeginPlay()
	{
		super.BeginPlay();
		SplashDamage = SplashRadius = 176;
	}

	States
	{
	Spawn:
		PROX A 0;
		PROX AA 5 A_JumpIf(invoker.TouchOff, 'Death');
		PROX A 5
		{
			if (invoker.TouchOff)
				return ResolveState('Death');

			// Die if owning player dies
			if (Target != null && Target.Health < 0)
				return ResolveState('Death');

			let bli = BlockThingsIterator.Create(invoker, 15.0);
			while (bli.Next())
			{
				if (bli.Thing.bIsMonster && bli.Thing.Species != 'Player')
					return ResolveState('Death');
			}

			return state(null);
		}
		Loop;
	Death:
		PROX A 2 A_StartSound("bio/proj/proximity/beep", CHAN_AUTO);
		PROX BC 4;
		PRXD A 2 Bright
		{
			A_Stop();
			bNoGravity = true;
			A_SetTranslucent(0.5, 1);
			A_Explode(invoker.SplashDamage, invoker.SplashRadius, XF_HURTSOURCE);
			A_StartSound("weapons/rocklx", CHAN_AUTO, attenuation: 0.8);
		}
		PRXD BCDEFGHIJKLMNOPQRSTU 2 Bright;
		Stop;
	}
}