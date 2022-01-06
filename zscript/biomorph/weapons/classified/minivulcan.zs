class BIO_Minivulcan : BIO_Weapon
{
	Default
	{
		Tag "$BIO_MINIVULCAN_TAG";

		Inventory.Icon 'VULCZ0';
		Inventory.PickupMessage "$BIO_MINIVULCAN_PKUP";

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
			.BasicBulletPipeline('BIO_Bullet', 1, 30, 36, 3.5, 1.5)
			.FireSound("bio/weap/minivulc/fire")
			.AssociateFireTime(1)
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
		VULC A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		VULC A 0 A_BIO_Deselect;
		Stop;
	Select:
		VULC A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
	WindUp:
		VULC BCD 1;
		VULC EFGH 1;
	Wound:
		VULC E 1 Bright
		{
			if (!invoker.SufficientAmmo()) return ResolveState('WindDown');
			A_GunFlash('Flash.I');
			A_BIO_Fire();
			A_PresetRecoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_FireSound(CHAN_WEAPON);
			return state(null);
		}
		VULC F 1 Bright A_GunFlash('Flash.J');
		VULC G 1 Bright
		{
			if (!invoker.SufficientAmmo()) return ResolveState('WindDown');
			A_GunFlash('Flash.K');
			A_BIO_Fire();
			A_PresetRecoil(Random(0, 1) ? 'BIO_Recoil_Autogun' : 'BIO_Recoil_RapidFire');
			A_FireSound(CHAN_7);
			return state(null);
		}
		VULC H 1 Bright A_GunFlash('Flash.L');
		TNT1 A 0 A_JumpIf(!(Player.Cmd.Buttons & BT_ATTACK), 'WindDown');
		Loop;
	WindDown:
		VULC EFGH 1;
		VULC ABCD 1;
		Goto Ready;
	Flash:
		TNT1 A 0;
		Goto LightDone;
	Flash.I:
		VULC I 1 Bright A_Light(1);
		Goto LightDone;
	Flash.J:
		VULC J 1 Bright A_Light(2);
		Goto LightDone;
	Flash.K:
		VULC K 1 Bright A_Light(1);
		Goto LightDone;
	Flash.L:
		VULC L 1 Bright A_Light(2);
		Goto LightDone;
	Spawn:
		VULC Z 0;
		VULC Z 0 A_BIO_Spawn;
		Loop;
	}
}
