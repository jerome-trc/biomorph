class BIO_BlackHoleDynamo : BIO_Weapon
{
	Default
	{
		+WEAPON.NOAUTOFIRE

		Tag "$BIO_BLACKHOLEDYNAMO_TAG";
		
		Inventory.Icon 'BHDNZ0';
		Inventory.PickupMessage "$BIO_BLACKHOLEDYNAMO_PKUP";
	
		Weapon.AmmoGive 80;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_BFG_CLSF;
		Weapon.SlotNumber 7;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineSize 1;
		BIO_Weapon.MagazineType 'BIO_Mag_BlackHoleDynamo';
		BIO_Weapon.ReloadCost 40;
		BIO_Weapon.PlayerVisual BIO_PVIS_BFG10K;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.FireFunctor(new('BIO_FireFunc_BHoleDyn').CustomSet(10, 90))
			.FireType('BIO_BlackHoleProj')
			.FireCount(1)
			.SingleDamage(10)
			.AssociateFirstFireTime()
			.FireSound("bio/weap/bholedyn/fire")
			.SetRestrictions(BIO_WPM_FIREFUNCTOR | BIO_WPM_FIRETYPE)
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
		BHDN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		BHDN A 0 A_BIO_Deselect;
		Stop;
	Select:
		BHDN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo(single: true);
		BHDN A 8 Bright
		{
			A_SetFireTime(0);
			A_StartSound("bio/weap/bholedyn/charge");
		}
		BHDN B 10 Bright A_SetFireTime(1);
		BHDN C 10 Bright A_SetFireTime(2);
		BHDN D 10 Bright A_SetFireTime(3);
		BHDN E 10 Bright A_SetFireTime(4);
		BHDN F 3 Bright
		{
			A_SetFireTime(5);
			A_BIO_Fire();
			A_FireSound();
			A_GunFlash();
		}
		BHDN F 3 Bright A_SetFireTime(6);
		BHDN G 6 Bright A_SetFireTime(7);
		BHDN C 4 A_SetFireTime(8);
		BHDN B 4 A_SetFireTime(9);
		BHDN A 14 A_SetFireTime(10);
		TNT1 A 0 A_ReFire;
		BHDN A 2 A_SetFireTime(11);
		TNT1 A 0 A_AutoReload(single: true);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');
		BHDN A 1 A_WeaponReady(WRF_NOFIRE);
		BHDN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(1);
		BHDN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(2);
		BHDN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(3);
		BHDN A 1 Fast Offset(0, 32 + 15) A_SetReloadTime(4);
		BHDN A 1 Offset(0, 32 + 30) A_SetReloadTime(5);
		// TODO: Reload sounds
		BHDN A 50 Offset(0, 32 + 20)
		{
			A_SetReloadTime(6);
			A_PresetRecoil('BIO_Recoil_HeavyReload');
		}
		BHDN A 1 Offset(0, 32 + 18)
		{
			A_SetReloadTime(7);
			A_PresetRecoil('BIO_Recoil_HeavyReload', invert: true);
			A_LoadMag();
		}
		BHDN A 1 Fast Offset(0, 32 + 11) A_SetReloadTime(8);
		BHDN A 1 Fast Offset(0, 32 + 7) A_SetReloadTime(9);
		BHDN A 1 Fast Offset(0, 32 + 5) A_SetReloadTime(10);
		BHDN A 1 Fast Offset(0, 32 + 3) A_SetReloadTime(11);
		BHDN A 1 Fast Offset(0, 32 + 2) A_SetReloadTime(12);
		BHDN A 1 Fast Offset(0, 32 + 1) A_SetReloadTime(13);
		Goto Ready;
	Flash:
		BHDN H 3 Bright A_Light(2);
		BHDN I 3 Bright A_Light(1);
		BHDN J 3 Bright A_Light(0);
		BHDN K 3 Bright;
		Goto LightDone;
	Spawn:
		BHDN Z 0;
		BHDN Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_FireFunc_BHoleDyn : BIO_FireFunc_Projectile
{
	int SpaghettifyDamage, SpaghettifyRadius;

	override Actor Invoke(BIO_Weapon weap, BIO_FireData fireData) const
	{
		let bhole = BIO_BlackHoleProj(super.Invoke(weap, fireData));
		if (bhole != null)
		{
			bhole.SpaghettifyDamage = SpaghettifyDamage;
			bhole.SpaghettifyRadius = SpaghettifyRadius;
		}
		return bhole;
	}

	BIO_FireFunc_BHoleDyn CustomSet(int damage, int radius)
	{
		SpaghettifyDamage = damage;
		SpaghettifyRadius = radius;
		return self;
	}

	override void GetDamageValues(in out Array<int> vals) const
	{
		vals.Push(SpaghettifyDamage);
	}

	override void SetDamageValues(in out Array<int> vals)
	{
		SpaghettifyDamage = vals[0];
	}

	override void ToString(
		in out Array<string> readout,
		readOnly<BIO_WeaponPipeline> ppl,
		readOnly<BIO_WeaponPipeline> pplDef) const
	{
		super.ToString(readout, ppl, pplDef);
		int finalDPS = Ceil(float(SpaghettifyDamage) * 1.25 * float(TICRATE)),
			finalDPS_def = Ceil(10.0 * 1.25 * float(TICRATE));
		readout.Push(String.Format(
			StringTable.Localize("$BIO_BLACKHOLEDYNAMO_STATS"),
			BIO_Utils.StatFontColor(finalDPS, finalDPS_def), finalDPS));
	}
}

class BIO_Mag_BlackHoleDynamo : Ammo { mixin BIO_Magazine; }
