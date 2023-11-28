/// An unarmed, magical punch which comes out quickly, has a relatively slow post-fire
/// recovery period, and applies a 3-second stun to non-boss enemies.
/// Abbreviation: `EPN`
class biom_ElecPunch : biom_MeleeWeapon
{
	Default
	{
		+WEAPON.MELEEWEAPON

		Tag "$BIOM_ELECPUNCH_TAG";
		Obituary "$BIOM_ELECPUNCH_OB";

		Inventory.Icon 'EPNZZ0';
		Inventory.PickupMessage "$BIOM_ELECPUNCH_PKUP";

		Weapon.SelectionOrder SELORDER_CHAINSAW;
		Weapon.SlotNumber 1;

		biom_Weapon.DataClass 'biom_wdat_ElecPunch';
		biom_Weapon.Family BIOM_WEAPFAM_MELEE;
	}

	States
	{
	Select:
		EPNA A 1 A_Raise(12);
		loop;
	Deselect:
	Deselect.Repeat:
		EPNA A 1 A_Lower(12);
		loop;
	Ready:
	Ready.Main:
		EPNA A 1
		{
			let playSound = true;

			switch (Random(0, TICRATE * 3))
			{
			case 0:
			{
				A_GunFlash('Ready.Overlay.B', GFF_NOEXTCHANGE);
				break;
			}
			case 1:
			{
				A_GunFlash('Ready.Overlay.C', GFF_NOEXTCHANGE);
				break;
			}
			case 2:
			{
				A_GunFlash('Ready.Overlay.D', GFF_NOEXTCHANGE);
				break;
			}
			default:
			{
				playSound = false;
				break;
			}
			}

			if (playSound)
				A_StartSound("biom/elecpunch/idle", volume: 0.25);

			A_WeaponReady();
		}
		loop;
	Ready.Overlay.B:
		EPNA B 1;
		goto LightDone;
	Ready.Overlay.C:
		EPNA C 1;
		goto LightDone;
	Ready.Overlay.D:
		EPNA D 1;
		goto LightDone;
	Fire:
		EPN1 A 1
		{
			A_AlertMonsters();
			A_biom_Recoil('biom_recoil_Rake');
			A_StartSound("biom/whoosh", CHAN_WEAPON);
		}
		EPN1 C 2;
		EPN1 E 15
		{
			double ang = self.angle + Random2[Punch]() * (5.625 / 256);
			double range = 64 + MELEEDELTA;
			double pitch = self.AimLineAttack(ang, range, null, 0.0, ALF_CHECK3D);
			FTranslatedLineTarget tgt;

			self.LineAttack(
				ang,
				range,
				pitch,
				1,
				'Melee',
				'biom_ElecPunchPuff',
				LAF_ISMELEEATTACK,
				tgt
			);

			if (tgt.lineTarget == null)
				return;

			if (!tgt.lineTarget.bBoss && !tgt.lineTarget.bNoPain)
				let _ = biom_ElecPunchDebuff.Create(tgt.lineTarget);
			else
				tgt.lineTarget.TriggerPainChance('biom_NullDamage', true);
		}
		EPN1 DCBA 3;
		goto Ready.Main;
	}

	override int, int UnarmedDamageBonus() const
	{
		return 18, 4;
	}
}

class biom_wdat_ElecPunch : biom_WeaponData
{
	final override void Reset()
	{
		// ???
	}
}

class biom_ElecPunchDebuff : Thinker
{
	private Actor target;
	private uint lifetime;

	static biom_ElecPunchDebuff Create(Actor target)
	{
		let ret = new('biom_ElecPunchDebuff');
		ret.target = target;
		return ret;
	}

	final override void Tick()
	{
		super.Tick();

		if (self.bDestroyed)
			return;

		self.lifetime += 1;

		if (self.lifetime >= (TICRATE * 3) ||
			self.target == null ||
			self.target.health <= 0)
		{
			self.Destroy();
		}
		else
		{
			self.target.TriggerPainChance('biom_NullDamage', true);

			if ((Level.mapTime % 25) == 0)
				self.target.A_StartSound("biom/elecpunch/hit", CHAN_AUTO);
		}
	}
}
