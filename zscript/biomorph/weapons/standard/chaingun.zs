class BIO_Chaingun : BIO_Weapon replaces Chaingun
{
	Default
	{
		Obituary "$OB_MPCHAINGUN";
		Tag "$TAG_CHAINGUN";

		Inventory.Icon 'MGUNA0';
		Inventory.PickupMessage "$BIO_CHAINGUN_PKUP";

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 40;
		BIO_Weapon.MagazineType 'BIO_MAG_Chaingun';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_Bullet', 1, 5, 15, 4.0, 2.0)
			.FireSound("weapons/chngun")
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
		CHGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		CHGG A 0 A_BIO_Deselect;
		Stop;
	Select:
		CHGG A 0 A_BIO_Select;
		Stop;
	Fire:
		CHGG A 0 A_AutoReload;
		CHGG A 4
		{
			A_SetFireTime(0);
			A_ChaingunFire();
		}
		CHGG B 4
		{
			A_SetFireTime(1);
			A_ChaingunFire();
		}
		CHGG B 0 A_ReFire;
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		CHGG A 1 A_WeaponReady(WRF_NOFIRE);
		CHGG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		CHGG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		CHGG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		CHGG A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		CHGG A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		CHGG A 40 Offset(0, 32 + 30) A_SetReloadTime(6);
		CHGG A 1 Offset(0, 32 + 15)
		{
			A_SetReloadTime(7);
			A_LoadMag();
		}
		CHGG A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		CHGG A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		CHGG A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		CHGG A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		CHGG A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		CHGG A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		CHGF A 5 Bright
		{
			A_SetFireTime(0, modifier: 1);
			A_Light(1);
		}
		Goto LightDone;
		CHGF B 5 Bright
		{
			A_SetFireTime(1, modifier: 1);
			A_Light(2);
		}
		Goto LightDone;
	Spawn:
		MGUN A 0;
		MGUN A 0 A_BIO_Spawn;
		Stop;
	}

	protected action void A_ChaingunFire()
	{
		A_BIO_Fire();
		Player.SetSafeFlash(invoker, ResolveState('Flash'),
			ResolveState('Fire') + 1 ==
			Player.GetPSprite(PSP_WEAPON).CurState ? 0 : 1);
		A_FireSound();
		A_PresetRecoil('BIO_Recoil_Autogun');
	}
}

class BIO_MAG_Chaingun : Ammo { mixin BIO_Magazine; }
