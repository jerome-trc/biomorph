class BIO_MicroVulcan : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MICROVULCAN_TAG";

		Inventory.Icon 'MGUNB0';

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.GraphQuality 8;
		BIO_Weapon.MagazineType 'Clip';
		BIO_Weapon.PickupMessages
			"$BIO_MICROVULCAN_PKUP",
			"$BIO_MICROVULCAN_SCAV";
		BIO_Weapon.ScavengePersist false;
		BIO_Weapon.SpawnCategory BIO_WSCAT_CHAINGUN;
	}

	States
	{
	Spawn:
		MGUN B 0;
		MGUN B 0 A_BIO_Spawn;
		Stop;
	Deselect:
		CHGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		CHGG A 0 A_BIO_Select;
		Stop;
	Ready:
		CHGG A 1 A_WeaponReady;
		Loop;
	Fire:
		CHGG A 0 A_BIO_CheckAmmo;
		CHGG A 4
		{
			A_BIO_SetFireTime(0);
			A_Microvulcan_Fire();
		}
		CHGG B 4
		{
			A_BIO_SetFireTime(1);
			A_Microvulcan_Fire();
		}
		CHGG B 0 A_ReFire;
		TNT1 A 0 A_BIO_AutoReload;
		Goto Ready;
	Flash:
		CHGF A 5 Bright
		{
			A_BIO_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 5 Bright
		{
			A_BIO_SetFireTime(1, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		CHGG A 1 A_WeaponReady(WRF_NOFIRE);
		CHGG A 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(1);
		CHGG A 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(2);
		CHGG A 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(3);
		CHGG A 1 Fast Offset(0, 32 + 15) A_BIO_SetReloadTime(4);
		CHGG A 1 Offset(0, 32 + 30) A_BIO_SetReloadTime(5);
		CHGG A 40 Offset(0, 32 + 30) A_BIO_SetReloadTime(6);
		CHGG A 1 Offset(0, 32 + 15)
		{
			A_BIO_SetReloadTime(7);
			A_BIO_LoadMag();
		}
		CHGG A 1 Fast Offset(0, 32 + 11) A_BIO_SetReloadTime(8);
		CHGG A 1 Fast Offset(0, 32 + 7) A_BIO_SetReloadTime(9);
		CHGG A 1 Fast Offset(0, 32 + 5) A_BIO_SetReloadTime(10);
		CHGG A 1 Fast Offset(0, 32 + 3) A_BIO_SetReloadTime(11);
		CHGG A 1 Fast Offset(0, 32 + 2) A_BIO_SetReloadTime(12);
		CHGG A 1 Fast Offset(0, 32 + 1) A_BIO_SetReloadTime(13);
		Goto Ready;
	}

	protected action void A_Microvulcan_Fire()
	{
		A_BIO_Fire();
		Player.SetSafeFlash(invoker, ResolveState('Flash'),
			ResolveState('Fire') + 1 ==
			Player.GetPSprite(PSP_WEAPON).CurState ? 0 : 1);
		A_BIO_FireSound(CHAN_AUTO);
		A_BIO_Recoil('BIO_Recoil_Autogun');
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Bullet()
				.RandomDamage(14, 16)
				.Spread(4.0, 2.0)
				.FireSound("bio/weap/microvulcan/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire'));
	}
}
