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
		biom_Weapon.Grade BIOM_WEAPGRADE_1;
	}

	States
	{
	Ready:
		H2HC A 1 A_WeaponReady;
		loop;
	Deselect:
		H2HC A 1 A_Lower;
		loop;
	Select:
		H2HC A 1 A_Raise;
		loop;
	Fire:
		TNT1 A 0 A_JumpIf(invoker.bRightHand, 'Rake.Right');
		goto Rake.Left;
	Rake.Left:
		H2HC B 4 { invoker.bRightHand = true; }
		H2HC C 1 A_biom_Recoil('biom_recoil_Rake');
		H2HC D 2 {
			A_biom_UnarmedAttack();
			A_AlertMonsters();
		}
		H2HC E 1 A_biom_UnarmedAttack;
		H2HC F 1 A_biom_UnarmedAttack;
		H2HC G 2 A_biom_UnarmedAttack;
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
		H2HC L 2 {
			A_biom_UnarmedAttack();
			A_AlertMonsters();
		}
		H2HC M 1 A_biom_UnarmedAttack;
		H2HC N 1 A_biom_UnarmedAttack;
		H2HC O 2 A_biom_UnarmedAttack;
		H2HC P 3;
		H2HC Q 4;
		TNT1 A 4;
		H2HC A 1 offset(0, 44);
		H2HC A 1 offset(0, 36);
		H2HC A 1 offset(0, 34);
		H2HC A 1 offset(0, 32);
		goto Ready;
	}

	protected action void A_biom_UnarmedAttack()
	{
		int damage = Random(20, 22);

		if (invoker.owner.FindInventory('PowerStrength') != null)
			damage *= 4;

		A_FireBullets(
			16, -8,
			-1,
			damage,
			'biom_BulletPuff',
			FBF_EXPLICITANGLE | FBF_NORANDOM,
			100
		);
	}
}

class biom_wdat_Unarmed : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}
