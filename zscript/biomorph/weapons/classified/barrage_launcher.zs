class BIO_BarrageLauncher : BIO_Weapon
{
	Default
	{
		+WEAPON.BFG
		+WEAPON.EXPLOSIVE
		+WEAPON.NOAUTOFIRE

		Decal 'BulletChip';
		Tag "$BIO_WEAP_TAG_BARRAGELAUNCHER";
		
		Inventory.Icon 'BARRX0';
		Inventory.PickupMessage "$BIO_WEAP_PKUP_BARRAGELAUNCHER";

		Weapon.AmmoGive 20;
		Weapon.AmmoType 'RocketAmmo';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_RLAUNCHER_CLSF;
		Weapon.SlotNumber 5;
		Weapon.SlotPriority SLOTPRIO_CLASSIFIED;

		BIO_Weapon.Grade BIO_GRADE_CLASSIFIED;
		BIO_Weapon.MagazineType 'RocketAmmo';
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.BasicProjectilePipeline('BIO_Rocket', 1, 30, 180, 0.4, 0.4)
			.Splash(128, 128)
			.Build());
	}

	override void InitImplicitAffixes(in out Array<BIO_WeaponAffix> affixes) const
	{
		affixes.Push(new('BIO_Wafx_ForceRadiusDmg'));
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire', "$BIO_BURST"));
		groups.Push(StateTimeGroupFrom('AltFire', "$BIO_SEMI_AUTO"));
	}

	States
	{
	Ready:
		BARR A 1 A_WeaponReady;
		Loop;
	Deselect:
		BARR A 0 A_BIO_Deselect;
		Stop;
	Select:
		BARR A 0 A_BIO_Select;
		Stop;
	Fire:
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetFireTime(0);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(2);
		BARR D 1 Offset(0, 32 + 12) A_SetFireTime(3);
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(4);
		BARR B 2 Offset(0, 32 + 6) A_SetFireTime(5);
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetFireTime(0);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(6);
		BARR D 1 Offset(0, 32 + 12) A_SetFireTime(7);
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(8);
		BARR B 2 Offset(0, 32 + 6) A_SetFireTime(9);
		#### # 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR A 2 Offset(0, 32 + 3) A_SetFireTime(10);
		BARR B 2 Offset(0, 32 + 6)
		{
			A_SetFireTime(1);
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(11);
		BARR D 1 Offset(0, 32 + 12) A_SetFireTime(12);
		BARR C 1 Offset(0, 32 + 9) A_SetFireTime(13);
		BARR B 2 Offset(0, 32 + 6) A_SetFireTime(14);
		BARR A 10 A_SetFireTime(15);
		#### # 0 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_JumpIf(!invoker.SufficientAmmo(), 'Ready');
		BARR B 3 Offset(0, 32 + 6)
		{
			A_SetFireTime(0, 1);
			invoker.bAltFire = false;
			A_BIO_Fire();
			A_PresetRecoil('BIO_Recoil_Shotgun');
		}
		BARR C 3 Offset(0, 32 + 9) A_SetFireTime(1, 1);
		BARR D 3 Offset(0, 32 + 12) A_SetFireTime(2, 1);
		BARR C 3 Offset(0, 32 + 9) A_SetFireTime(3, 1);
		BARR B 3 Offset(0, 32 + 6) A_SetFireTime(4, 1);
		BARR A 3 Offset(0, 32 + 3) A_SetFireTime(5, 1);
		// For some reason, NOAUTOFIRE blocks holding down AltFire.
		TNT1 A 0 A_JumpIf(Player.Cmd.Buttons & BT_ALTATTACK, 'AltFire');
		Goto Ready;
	Spawn:
		BARR X 0;
		BARR X 0 A_BIO_Spawn;
		Loop;
	}
}
