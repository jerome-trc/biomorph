class BIO_Coachgun : BIO_Weapon
{
	const DAMAGE_MIN = 10;
	const DAMAGE_MAX = 15;
	const SPREAD_HORIZ = 12.0;
	const SPREAD_VERT = 7.5;

	Default
	{
		Tag "$BIO_COACHGUN_TAG";

		Inventory.Icon 'SGN2A0';

		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.EnergyToMatter -1, 10;
		BIO_Weapon.MagazineFlags BIO_MAGF_BALLISTIC_1;
		BIO_Weapon.MagazineSize 2;
		BIO_Weapon.MagazineType 'BIO_NormalMagazine';
		BIO_Weapon.OperatingModes
			'BIO_OpMode_Coachgun_SmallMag',
			'BIO_OpMode_Coachgun_SmallMag';
		BIO_Weapon.PickupMessages
			"$BIO_COACHGUN_PKUP",
			"$BIO_COACHGUN_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_SSG;
	}

	override void SetDefaults()
	{
		ReloadTimeGroups.Push(StateTimeGroupFrom('Reload'));

		OpModes[0].Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 20)
				.RandomDamage(DAMAGE_MIN, DAMAGE_MAX)
				.Spread(SPREAD_HORIZ, SPREAD_VERT)
				.FireSound("bio/weap/coachgun/fire")
				.AmmoUseMulti(2)
				.Tag("$BIO_2BARRELS")
				.Build()
		);

		OpModes[1].Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet('BIO_ShotPellet', 10)
				.RandomDamage(DAMAGE_MIN, DAMAGE_MAX)
				.Spread(SPREAD_HORIZ, SPREAD_VERT)
				.FireSound("bio/weap/pumpshotgun/fire")
				.Tag("$BIO_1BARREL")
				.Build()
		);
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}

	States
	{
	Spawn:
		SGN2 A 0;
		#### # 0 A_BIO_Spawn;
		Stop;
	Deselect:
		SHT2 A 0 A_BIO_Deselect;
		Stop;
	Select:
		SHT2 A 0 A_BIO_Select;
		Stop;
	Ready:
		SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Fire:
		TNT1 A 0 A_BIO_Op_Primary;
		Stop;
	AltFire:
		TNT1 A 0 A_BIO_Op_Secondary;
		Stop;
	Fire.Common:
		TNT1 A 0
		{
			if (!invoker.bAltFire)
			{
				if (BIO_CVar.MultiBarrelPrimary(Player))
					return ResolveState('Fire.Double');
				else
					return ResolveState('Fire.Single');
			}
			else
			{
				if (BIO_CVar.MultiBarrelPrimary(Player))
					return ResolveState('Fire.Single');
				else
					return ResolveState('Fire.Double');
			}
		}
		Stop;
	Fire.Single:
		TNT1 A 0 A_BIO_CheckAmmo;
		SHT2 A 3 Fast A_BIO_SetFireTime(0);
		SHT2 A 1 Offset(0, 32 + 7)
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			A_BIO_Recoil('BIO_Recoil_Shotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_BIO_FireSound(CHAN_AUTO);
		}
		SHT2 A 1 Offset(0, 32 + 4) Fast A_BIO_SetFireTime(2);
		SHT2 A 1 Offset(0, 32 + 3) Fast A_BIO_SetFireTime(3);
		SHT2 A 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(4);
		SHT2 A 1 Offset(0, 32 + 1) Fast A_BIO_SetFireTime(5);
		SHT2 A 1 Fast
		{
			A_BIO_SetFireTime(6);
			// This is the only way I've found to prevent
			// last X offset from being preserved
			A_WeaponOffset(0.0, 32.0);
		}
		SHT2 A 1 Fast A_BIO_SetFireTime(7);
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_BIO_CheckAmmo;
		SHT2 A 3 Fast A_BIO_SetFireTime(0);
		SHT2 A 1 Offset(0, 32 + 13)
		{
			A_BIO_SetFireTime(1);
			A_BIO_Fire();
			A_BIO_Recoil('BIO_Recoil_DoubleShotgun');
			Player.SetPSprite(PSP_FLASH, invoker.FindState('Flash'), true);
			A_BIO_FireSound(CHAN_AUTO);
		}
		SHT2 A 1 Offset(0, 32 + 9) Fast A_BIO_SetFireTime(2);
		SHT2 A 1 Offset(0, 32 + 6) Fast A_BIO_SetFireTime(3);
		SHT2 A 1 Offset(0, 32 + 3) Fast A_BIO_SetFireTime(4);
		SHT2 A 1 Offset(0, 32 + 2) Fast A_BIO_SetFireTime(5);
		SHT2 A 1 Offset(0, 32 + 1) Fast A_BIO_SetFireTime(6);
		SHT2 A 1 Fast
		{
			A_BIO_SetFireTime(7);
			// This is the only way I've found to prevent
			// last X offset from being preserved
			A_WeaponOffset(0.0, 32.0);
		}
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Dryfire:
		SHT2 A 1 Offset(0, 32 + 1);
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 3) A_StartSound("bio/weap/dryfire/ballistic");
		#### # 1 Offset(0, 32 + 2);
		#### # 1 Offset(0, 32 + 1);
		Goto Ready;
	Flash:
		SHT2 I 4 Bright A_Light(1);
		SHT2 J 3 Bright A_Light(2);
		Goto LightDone;
	Reload:
		TNT1 A 0 A_BIO_CheckReload;
		SHT2 B 7 A_BIO_SetReloadTime(0);
		SHT2 C 7 A_BIO_SetReloadTime(1);
		SHT2 D 7
		{
			A_BIO_SetReloadTime(2);
			A_StartSound("weapons/sshoto", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG');
		}
		SHT2 E 7 A_SetTics(3);
		SHT2 F 7
		{
			A_BIO_SetReloadTime(4);
			A_BIO_LoadMag();
			A_StartSound("weapons/sshotl", CHAN_AUTO); 
		}
		SHT2 G 6 A_SetTics(5);
		SHT2 H 6
		{
			A_BIO_SetReloadTime(6);
			A_StartSound("weapons/sshotc", CHAN_AUTO);
			A_BIO_Recoil('BIO_Recoil_ReloadSSG', invert: true);
			A_ReFire();
		}
		SHT2 A 5
		{
			A_BIO_SetReloadTime(7);
			A_ReFire();
		}
		Goto Ready;
	}
}

// Operating modes /////////////////////////////////////////////////////////////

class BIO_OpMode_Coachgun_SmallMag : BIO_OpMode_SmallMag
{
	final override class<BIO_Weapon> WeaponType() const
	{
		return 'BIO_Coachgun';
	}

	final override void Init(readOnly<BIO_Weapon> weap)
	{
		FireTimeGroups.Push(weap.StateTimeGroupFrom('Fire.Single'));
	}

	final override statelabel EntryState() const
	{
		return 'Fire.Common';
	}
}
