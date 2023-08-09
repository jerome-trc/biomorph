/// Abbreviation: `H2H`
class biom_Unarmed : biom_Weapon
{
	flagdef rightHand: DynFlags, 31;

	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIOM_UNARMED_TAG";
		Obituary "$BIOM_UNARMED_OB";

		Inventory.Icon 'H2HCZ0';

		Weapon.SelectionOrder SELORDER_FIST;
		Weapon.SlotNumber 1;

		biom_Weapon.DataClass 'biom_wdat_Unarmed';
	}

	States
	{
	Ready:
		H2HC A 1 A_WeaponReady;
		loop;
	Deselect:
		H2HC A 1 A_Lower(12);
		loop;
	Select:
		H2HC A 1 A_Raise(12);
		loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.bRightHand, 'Rake.Right');
		goto Rake.Left;
	Rake.Left:
		H2HC B 4 { invoker.bRightHand = true; }
		H2HC C 1 A_biom_Recoil('biom_recoil_Rake');
		H2HC D 2 A_biom_UnarmedAttackStart;
		H2HC E 1 A_biom_UnarmedHitscan;
		H2HC F 1 A_biom_UnarmedHitscan;
		H2HC G 2 A_biom_UnarmedHitscan;
		H2HC H 3;
		H2HC I 4;
		TNT1 A 4;
		H2HC A 1 offset(0, 44);
		H2HC A 1 offset(0, 36);
		H2HC A 1 offset(0, 34);
		H2HC A 1 offset(0, 32);
		goto Ready;
	Rake.Right:
		H2HC J 4 { invoker.bRightHand = false; }
		H2HC K 1 A_biom_Recoil('biom_recoil_Rake');
		H2HC L 2 A_biom_UnarmedAttackStart;
		H2HC M 1 A_biom_UnarmedHitscan;
		H2HC N 1 A_biom_UnarmedHitscan;
		H2HC O 2 A_biom_UnarmedHitscan;
		H2HC P 3;
		H2HC Q 4;
		TNT1 A 4;
		H2HC A 1 offset(0, 44);
		H2HC A 1 offset(0, 36);
		H2HC A 1 offset(0, 34);
		H2HC A 1 offset(0, 32);
		goto Ready;
	}

	protected action void A_biom_UnarmedAttackStart()
	{
		if (A_biom_UnarmedHitscan() == null)
			A_SprayDecal("biom_ClawMark", offset: (0, 0, 48.0));

		A_AlertMonsters();
		A_StartSound("biom/whoosh", CHAN_WEAPON);
	}

	/// Returns the actor hit by the attack (may be null).
	protected action Actor A_biom_UnarmedHitscan()
	{
		int damage = Random(20, 22);

		if (self.FindInventory('PowerStrength') != null)
			damage *= 4;

		double ang = self.angle + Random2[Punch]() * (5.625 / 256);
		double range = 64 + MELEEDELTA;
		double pitch = self.AimLineAttack(ang, range, null, 0.0, ALF_CHECK3D);
		FTranslatedLineTarget tgt;

		self.LineAttack(
			ang,
			range,
			pitch,
			damage,
			'Melee',
			'biom_ClawRake',
			LAF_ISMELEEATTACK,
			tgt
		);

		if (tgt.lineTarget != null)
			self.A_StartSound("baron/melee", CHAN_WEAPON);

		return tgt.lineTarget;
	}
}

class biom_wdat_Unarmed : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}

class biom_ClawRake : biom_Bullet
{
	Default
	{
		AttackSound "biom/unarmed/wallhit";
		Decal '';
	}
}
