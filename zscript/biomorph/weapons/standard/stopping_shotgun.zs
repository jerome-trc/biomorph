class BIO_StoppingShotgun : BIO_Weapon
{
	Default
	{
		Tag "$BIO_STOPPINGSHOTGUN_TAG";
		
		Inventory.Icon 'STSGZ0';
		Inventory.PickupMessage "$BIO_STOPPINGSHOTGUN_PKUP";
	
		Weapon.AmmoGive 8;
		Weapon.AmmoType 'Shell';
		Weapon.AmmoUse 1;
		Weapon.SelectionOrder SELORDER_SSG;
		Weapon.SlotNumber 3;
		Weapon.SlotPriority SLOTPRIO_STANDARD;
		Weapon.UpSound "bio/weap/gunswap";

		BIO_Weapon.Grade BIO_GRADE_STANDARD;
		BIO_Weapon.MagazineSize 2;
		BIO_Weapon.MagazineType 'BIO_Mag_StoppingShotgun';
		BIO_Weapon.PlayerVisual BIO_PVIS_SSG;
		BIO_Weapon.ScavengePersist true;
	}

	override void InitPipelines(in out Array<BIO_WeaponPipeline> pipelines) const
	{
		pipelines.Push(BIO_WeaponPipelineBuilder.Create()
			.Bullet('BIO_Slug') // One per barrel
			.X1D3Damage(40)
			.Spread(1.25, 1.25)
			.FireSound("bio/weap/stopsg/fire")
			.AssociateFirstFireTime()
			.Build());
	}

	override void InitFireTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Fire.Single'));
	}

	override void InitReloadTimes(in out Array<BIO_StateTimeGroup> groups) const
	{
		groups.Push(StateTimeGroupFrom('Reload'));
	}

	States
	{
	Ready:
		STSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		STSG A 0 A_BIO_Deselect;
		Loop;
	Select:
		STSG A 0 A_BIO_Select;
		Loop;
	Fire:
		TNT1 A 0
		{
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Double');
			else
				return ResolveState('Fire.Single');
		}
	AltFire:
		TNT1 A 0
		{
			invoker.bAltFire = false;
			if (BIO_CVar.MultiBarrelPrimary(Player))
				return ResolveState('Fire.Single');
			else
				return ResolveState('Fire.Double');
		}
	Fire.Single:
		TNT1 A 0 A_BIO_CheckAmmo;

		TNT1 A 0 A_AutoReload;
		Goto Ready;
	Fire.Double:
		TNT1 A 0 A_BIO_CheckAmmo(multi: 2, single: true);

		TNT1 A 0 A_AutoReload(multi: 2, single: true);
		Goto Ready;
	Reload:
		TNT1 A 0 A_JumpIf(!invoker.CanReload(), 'Ready');

		Goto Ready;
	Flash:

		Goto LightDone;
	Spawn:
		STSG Z 0;
		STSG Z 0 A_BIO_Spawn;
		Stop;
	}
}

class BIO_Mag_StoppingShotgun : Ammo { mixin BIO_Magazine; }
