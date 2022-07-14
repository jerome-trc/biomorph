class BIO_ArcCaster : BIO_Weapon
{
	protected uint8 FireSprite;

	const FIRE_SPRITE_B = 0;
	const FIRE_SPRITE_C = 1;
	const FIRE_SPRITE_D = 2;
	const FIRE_SPRITE_E = 3;

	Default
	{
		Tag "$BIO_ARCCASTER_TAG";
		
		Inventory.Icon 'ARCAZ0';
		Inventory.PickupMessage "$BIO_ARCCASTER_PKUP";

		Weapon.AmmoGive 40;
		Weapon.AmmoType 'Cell';
		Weapon.AmmoUse 1;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority SLOTPRIO_HIGH;
		Weapon.ReadySound "bio/weap/arccaster/ready";

		BIO_Weapon.GraphQuality 6;
		BIO_Weapon.MagazineType 'Cell';
		BIO_Weapon.PickupMessages
			"$BIO_ARCCASTER_PKUP",
			"$BIO_ARCCASTER_SCAV";
		BIO_Weapon.SpawnCategory BIO_WSCAT_PLASRIFLE;
		BIO_Weapon.Summary "$BIO_ARCCASTER_SUMM";
	}

	States
	{
	Spawn:
		ARCA Z 0;
		ARCA Z 0 A_BIO_Spawn;
		Stop;
	Ready:
		ARCA A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWZOOM);
		Loop;
	Deselect:
		ARCA A 0 A_BIO_Deselect;
		Stop;
	Select:
		ARCA A 0 A_BIO_Select;
		Stop;
	Fire:
		TNT1 A 0 A_BIO_CheckAmmo;
		TNT1 A 0
		{
			switch (invoker.FireSprite)
			{
			default:
			case FIRE_SPRITE_B: return state(null);
			case FIRE_SPRITE_C: return ResolveState('Fire.C');
			case FIRE_SPRITE_D: return ResolveState('Fire.D');
			case FIRE_SPRITE_E: return ResolveState('Fire.E');
			}
		}
	Fire.B:
		ARCA B 2 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			A_BIO_FireSound(CHAN_AUTO);
			invoker.FireSprite = FIRE_SPRITE_C;
		}
		Goto Ready;
	Fire.C:
		ARCA C 2 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			invoker.FireSprite = FIRE_SPRITE_D;
		}
		Goto Ready;
	Fire.D:
		ARCA D 2 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			invoker.FireSprite = FIRE_SPRITE_E;
		}
		Goto Ready;
	Fire.E:
		ARCA E 2 Bright
		{
			A_BIO_SetFireTime(0);
			A_BIO_Fire();
			A_GunFlash();
			invoker.FireSprite = FIRE_SPRITE_B;
		}
		Goto Ready;
	Flash:
		TNT1 A 2
		{
			A_BIO_SetFireTime(0);
			A_Light(Random(3, 7));
		}
		Goto LightDone;
	}

	override void SetDefaults()
	{
		Pipelines.Push(
			BIO_WeaponPipelineBuilder.Create()
				.Rail('BIO_ElectricPuff',
					color2: "LightSteelBlue", flags: RGF_FULLBRIGHT, maxDiff: 30.0,
					range: 512.0, duration: 1, sparsity: 0.1, driftSpeed: 0.0
				)
				.X1D8Damage(4)
				.Spread(3.0, 3.0)
				.FireSound("bio/weap/arccaster/fire")
				.Build()
		);

		FireTimeGroups.Push(StateTimeGroupFrom('Fire.B'));
	}

	override uint ModCost(uint base) const
	{
		return super.ModCost(base) * 2;
	}
}
