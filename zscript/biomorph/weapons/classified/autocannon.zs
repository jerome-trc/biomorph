class BIO_Autocannon : BIO_Weapon
{
	Default
	{
		Tag "$BIO_AUTOCANNON_TAG";

		Inventory.Icon 'ACANZ0';
		Inventory.PickupMessage "$BIO_AUTOCANNON_PKUP";

		Weapon.AmmoType 'Clip';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_CHAINGUN_CLSF;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;
		
		BIO_Weapon.AffixMask BIO_WAM_FIRETIME | BIO_WAM_MAGAZINELESS;
		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineType 'Clip';
		BIO_Weapon.PlayerVisual BIO_PVIS_MINIGUN;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicBulletPipeline('BIO_Bullet', 1, 10, 30, 3.5, 1.5)
			.FireSound("bio/weap/autocannon/fire")
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFromRange('WindUp', 'Wound', "$BIO_WINDUP"));
		groups.Push(StateTimeGroupFrom('Wound', "$BIO_PER_2_ROUNDS"));
		groups.Push(StateTimeGroupFrom('WindDown', "$BIO_WINDDOWN"));
	}

	States
	{
	Ready:
		ACAN A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		ACAN A 0 A_BIO_Deselect;
		Stop;
	Select:
		ACAN A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	WindUp:
		ACAN BCD 1;
		ACAN EFGH 1;
	Wound:
		ACAN E 1 Bright
		{
			if (!invoker.SufficientAmmo()) return ResolveState('WindDown');
			A_GunFlash('Flash.I');
			A_BIO_Fire();
			A_PresetRecoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_FireSound(CHAN_WEAPON);
			return state(null);
		}
		ACAN F 1 Bright A_GunFlash('Flash.J');
		ACAN G 1 Bright
		{
			if (!invoker.SufficientAmmo()) return ResolveState('WindDown');
			A_GunFlash('Flash.K');
			A_BIO_Fire();
			A_PresetRecoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_FireSound(CHAN_7);
			return state(null);
		}
		ACAN H 1 Bright A_GunFlash('Flash.L');
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'WindDown');
		Loop;
	WindDown:
		ACAN EFGH 1;
		ACAN ABCD 1;
		Goto Ready;
	Flash:
		TNT1 A 0;
		Goto LightDone;
	Flash.I:
		ACAN I 1 Bright A_Light(1);
		Goto LightDone;
	Flash.J:
		ACAN J 1 Bright A_Light(2);
		Goto LightDone;
	Flash.K:
		ACAN K 1 Bright A_Light(1);
		Goto LightDone;
	Flash.L:
		ACAN L 1 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		ACAN X 0;
		ACAN X 0 A_BIO_Spawn;
		Loop;
	}
}
