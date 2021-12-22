enum BIO_PlayerVisual : uint8
{
	BIO_PVIS_UNARMED,
	BIO_PVIS_CHAINSAW,
	BIO_PVIS_PISTOL,
	BIO_PVIS_SHOTGUN,
	BIO_PVIS_SSG,
	BIO_PVIS_RIFLE,
	BIO_PVIS_CHAINGUN,
	BIO_PVIS_MINIGUN,
	BIO_PVIS_SNIPER,
	BIO_PVIS_ROCKETLAUNCHER,
	BIO_PVIS_GRENADELAUNCHER,
	BIO_PVIS_SHOULDERMOUNT,
	BIO_PVIS_FLAMETHROWER,
	BIO_PVIS_PLASMARIFLE,
	BIO_PVIS_RAILGUN,
	BIO_PVIS_BFG9K,
	BIO_PVIS_BFG10K
}

class BIO_Player : DoomPlayer
{
	static const statelabel PVIS_STATES_SPAWN[] = {
		'Spawn_Unarmed',
		'Spawn_Chainsaw',
		'Spawn_Pistol',
		'Spawn_Shotgun',
		'Spawn_SSG',
		'Spawn_Rifle',
		'Spawn_Chaingun',
		'Spawn_Minigun',
		'Spawn_Sniper',
		'Spawn_RocketLauncher',
		'Spawn_GrenadeLauncher',
		'Spawn_ShoulderMount',
		'Spawn_Flamethrower',
		'Spawn_PlasmaRifle',
		'Spawn_Railgun',
		'Spawn_BFG9K',
		'Spawn_BFG10K'
	};

	static const statelabel PVIS_STATES_SEE[] = {
		'See_Unarmed',
		'See_Chainsaw',
		'See_Pistol',
		'See_Shotgun',
		'See_SSG',
		'See_Rifle',
		'See_Chaingun',
		'See_Minigun',
		'See_Sniper',
		'See_RocketLauncher',
		'See_GrenadeLauncher',
		'See_ShoulderMount',
		'See_Flamethrower',
		'See_PlasmaRifle',
		'See_Railgun',
		'See_BFG9K',
		'See_BFG10K'
	};

	static const statelabel PVIS_STATES_MISSILE[] = {
		'Missile_Unarmed',
		'Missile_Chainsaw',
		'Missile_Pistol',
		'Missile_Shotgun',
		'Missile_SSG',
		'Missile_Rifle',
		'Missile_Chaingun',
		'Missile_Minigun',
		'Missile_Sniper',
		'Missile_RocketLauncher',
		'Missile_GrenadeLauncher',
		'Missile_ShoulderMount',
		'Missile_Flamethrower',
		'Missile_PlasmaRifle',
		'Missile_Railgun',
		'Missile_BFG9K',
		'Missile_BFG10K'
	};

	static const statelabel PVIS_STATES_PAIN[] = {
		'Pain_Unarmed',
		'Pain_Chainsaw',
		'Pain_Pistol',
		'Pain_Shotgun',
		'Pain_SSG',
		'Pain_Rifle',
		'Pain_Chaingun',
		'Pain_Minigun',
		'Pain_Sniper',
		'Pain_RocketLauncher',
		'Pain_GrenadeLauncher',
		'Pain_ShoulderMount',
		'Pain_Flamethrower',
		'Pain_PlasmaRifle',
		'Pain_Railgun',
		'Pain_BFG9K',
		'Pain_BFG10K'
	};

	static const statelabel PVIS_STATES_DEATH[] = {
		'Death_Unarmed',
		'Death_Chainsaw',
		'Death_Pistol',
		'Death_Shotgun',
		'Death_SSG',
		'Death_Rifle',
		'Death_Chaingun',
		'Death_Minigun',
		'Death_Sniper',
		'Death_RocketLauncher',
		'Death_GrenadeLauncher',
		'Death_ShoulderMount',
		'Death_Flamethrower',
		'Death_PlasmaRifle',
		'Death_Railgun',
		'Death_BFG9K',
		'Death_BFG10K'
	};

	static const statelabel PVIS_STATES_XDEATH[] = {
		'XDeath_Unarmed',
		'XDeath_Chainsaw',
		'XDeath_Pistol',
		'XDeath_Shotgun',
		'XDeath_SSG',
		'XDeath_Rifle',
		'XDeath_Chaingun',
		'XDeath_Minigun',
		'XDeath_Sniper',
		'XDeath_RocketLauncher',
		'XDeath_GrenadeLauncher',
		'XDeath_ShoulderMount',
		'XDeath_Flamethrower',
		'XDeath_PlasmaRifle',
		'XDeath_Railgun',
		'XDeath_BFG9K',
		'XDeath_BFG10K'
	};

	Array<BIO_Passive> Passives;
	Array<BIO_PlayerFunctor> Functors[FUNCTOR_ARRAY_LENGTH];

	uint MaxWeaponsHeld, MaxEquipmentHeld;
	property MaxWeaponsHeld: MaxWeaponsHeld;
	property MaxEquipmentHeld: MaxEquipmentHeld;

	BIO_Armor EquippedArmor;

	BIO_PlayerVisual WeaponVisual;

	Default
	{
		Species 'Player';

		Player.DisplayName "$BIO_PLAYER_DISPLAYNAME";
	
		Player.StartItem 'BIO_WeaponDrop';
		Player.StartItem 'BIO_UnequipArmor';

		Player.StartItem 'Clip', 50;
		Player.StartItem 'Shell', 0;
		Player.StartItem 'RocketAmmo', 0;
		Player.StartItem 'Cell', 0;

		Player.StartItem 'BIO_Pistol';
		Player.StartItem 'BIO_Fist';

		BIO_Player.MaxWeaponsHeld 6;
		BIO_Player.MaxEquipmentHeld 3;
	}

	States
	{
	// Spawn
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_SPAWN[invoker.WeaponVisual]);
		Goto Spawn_Rifle;
	Spawn_Unarmed:
		BMUA AABB 5;
		Goto Spawn;
	Spawn_Chainsaw:
		BMCS AABB 5;
		Goto Spawn;
	Spawn_Pistol:
		BMPS AABB 5;
		Goto Spawn;
	Spawn_Shotgun:
		BMSG AABB 5;
		Goto Spawn;
	Spawn_SSG:
		BMSS AABB 5;
		Goto Spawn;
	Spawn_Rifle:
		BMRF AABB 5;
		Goto Spawn;
	Spawn_Chaingun:
		BMCG AABB 5;
		Goto Spawn;
	Spawn_Minigun:
		BMMG AABB 5;
		Goto Spawn;
	Spawn_Sniper:
		BMSR AABB 5;
		Goto Spawn;
	Spawn_RocketLauncher:
		BMRL AABB 5;
		Goto Spawn;
	Spawn_GrenadeLauncher:
		BMGL AABB 5;
		Goto Spawn;
	Spawn_ShoulderMount:
		BMSM AABB 5;
		Goto Spawn;
	Spawn_Flamethrower:
		BMFT AABB 5;
		Goto Spawn;
	Spawn_PlasmaRifle:
		BMPR AABB 5;
		Goto Spawn;
	Spawn_Railgun:
		BMRG AABB 5;
		Goto Spawn;
	Spawn_BFG9K:
		BM9K AABB 5;
		Goto Spawn;
	Spawn_BFG10K:
		BM10 AABB 5;
		Goto Spawn;
	// See
	See:
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_SEE[invoker.WeaponVisual]);
		Goto See_Rifle;
	See_Unarmed:
		BMUA ABCD 6;
		Goto See;
	See_Chainsaw:
		BMCS ABCD 8;
		Goto See;
	See_Pistol:
		BMPS ABCD 6;
		Goto See;
	See_Shotgun:
		BMSG ABCD 6;
		Goto See;
	See_SSG:
		BMSS ABCD 6;
		Goto See;
	See_Rifle:
		BMRF ABCD 6;
		Goto See;
	See_Chaingun:
		BMCG ABCD 6;
		Goto See;
	See_Minigun:
		BMMG ABCD 6;
		Goto See;
	See_Sniper:
		BMSR ABCD 6;
		Goto See;
	See_RocketLauncher:
		BMRL ABCD 6;
		Goto See;
	See_GrenadeLauncher:
		BMGL ABCD 6;
		Goto See;
	See_ShoulderMount:
		BMSM ABCD 6;
		Goto See;
	See_Flamethrower:
		BMFT ABCD 6;
		Goto See;
	See_PlasmaRifle:
		BMPR ABCD 6;
		Goto See;
	See_Railgun:
		BMRG ABCD 6;
		Goto See;
	See_BFG9K:
		BM9K ABCD 6;
		Goto See;
	See_BFG10K:
		BM10 ABCD 6;
		Goto See;
	// Missile
	Missile:
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_MISSILE[invoker.WeaponVisual]);
		Goto Missile_Rifle;
	Missile_Unarmed:
		BMUA A 10;
		BMUA AE 5;
		BMUA A 10;
		BMUA EFEF 5;
		Goto Spawn;
	Missile_Chainsaw: // Is this even possible?
		TNT1 A 0;
		Goto Melee_Chainsaw;
	Missile_Pistol:
		BMPS E 2;
		BMPS F 5 Bright;
		BMPS E 3;
		Goto Spawn;
	Missile_Shotgun:
		BMSG E 5 Fast;
		BMSG F 3 Bright;
		BMSG E 3;
		Goto Spawn;
	Missile_SSG:
		BMSS E 5;
		BMSS F 3 Bright;
		BMSS E 3;
		BMSS A 3;
		Goto Spawn;
	Missile_Rifle:
		BMRF E 2;
		BMRF F 8 Bright;
		BMRF E 4;
		Goto Spawn;
	Missile_Chaingun:
		BMCG X 5;
		BMCG E 1;
		BMCG FE 3 Bright;
		BMCG F 1;
		Goto Spawn;
	Missile_Minigun:
		BMMG G 1 Bright;
		BMMG F 1;
		Goto Spawn;
	Missile_Sniper:
		BMSR EFE 10;
		Goto Spawn;
	Missile_RocketLauncher:
		BMRL E 10;
		BMRL F 10 Bright;
		BMRL E 10;
		Goto Spawn;
	Missile_GrenadeLauncher:
		BMGL E 10;
		BMGL F 3;
		BMGL F 7 Bright;
		Goto Spawn;
	Missile_ShoulderMount:
		BMSM E 5;
		BMSM F 8 Bright;
		BMSM E 20;
		Goto Spawn;
	Missile_Flamethrower:
		BMFT E 5;
		BMFT F 3 Bright;
		BMFT E 1;
		Goto Spawn;
	Missile_PlasmaRifle:
		BMPR E 5;
		BMPR F 4 Bright;
		BMPR E 4;
		Goto Spawn;
	Missile_Railgun:
		BMRG E 10;
		BMRG F 8 Bright;
		BMRG E 8;
		Goto Spawn;
	Missile_BFG9K:
		BM9K E 20;
		BM9K F 10 Bright;
		BM9K F 10 Bright;
		BM9K E 20;
		Goto Spawn;
	Missile_BFG10K:
		BM10 E 10;
		BM10 E 30;
		BM10 F 5 Bright;
		BM10 E 5;
		Goto Spawn;
	// Melee
	Melee:
		TNT1 A 0
		{
			switch (invoker.WeaponVisual)
			{
			default:
			case BIO_PVIS_UNARMED:
				return ResolveState('Melee_Unarmed');
			case BIO_PVIS_CHAINSAW:
				return ResolveState('Melee_Chainsaw');
			}
		}
		Goto Melee_Unarmed;
	Melee_Unarmed:
		BMUA E 1;
		BMUA F 2;
		BMUA E 2;
		BMUA A 1;
		Goto Missile;
	Melee_Chainsaw:
		BMCS E 1;
		BMCS F 9;
		Goto Missile;
	// Pain
	Pain:
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_PAIN[invoker.WeaponVisual]);
		Goto Pain_Rifle;
	Pain_Unarmed:
		BMUA G 4;
		BMUA G 4 A_Pain;
		Goto Spawn;
	Pain_Chainsaw:
		BMCS G 4;
		BMCS G 4 A_Pain;
		Goto Spawn;
	Pain_Pistol:
		BMPS G 4;
		BMPS G 4 A_Pain;
		Goto Spawn;
	Pain_Shotgun:
		BMSG G 4;
		BMSG G 4 A_Pain;
		Goto Spawn;
	Pain_SSG:
		BMSS G 4;
		BMSS G 4 A_Pain;
		Goto Spawn;
	Pain_Rifle:
		BMRF G 4;
		BMRF G 4 A_Pain;
		Goto Spawn;
	Pain_Chaingun:
		BMCG G 4;
		BMCG G 4 A_Pain;
		Goto Spawn;
	Pain_Minigun:
		BMMG H 4;
		BMMG H 4 A_Pain;
		Goto Spawn;
	Pain_Sniper:
		BMSR G 4;
		BMSR G 4 A_Pain;
		Goto Spawn;
	Pain_RocketLauncher:
		BMRL G 4;
		BMRL G 4 A_Pain;
		Goto Spawn;
	Pain_GrenadeLauncher:
		BMGL G 4;
		BMGL G 4 A_Pain;
		Goto Spawn;
	Pain_ShoulderMount:
		BMSM G 4;
		BMSM G 4 A_Pain;
		Goto Spawn;
	Pain_Flamethrower:
		BMFT G 4;
		BMFT G 4 A_Pain;
		Goto Spawn;
	Pain_PlasmaRifle:
		BMPR G 4;
		BMPR G 4 A_Pain;
		Goto Spawn;
	Pain_Railgun:
		BMRG G 4;
		BMRG G 4 A_Pain;
		Goto Spawn;
	Pain_BFG9K:
		BM9K G 4;
		BM9K G 4 A_Pain;
		Goto Spawn;
	Pain_BFG10K:
		BM10 G 4;
		BM10 G 4 A_Pain;
		Goto Spawn;
	// Death
	Death:
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_DEATH[invoker.WeaponVisual]);
		Goto Death_Rifle;
	Death_Unarmed:
		BMUA H 3;
		BMUA I 3 A_PlayerScream;
		BMUA J 3 A_NoBlocking;
		BMUA KLM 5;
		BMUA N -1;
		Stop;
	Death_Chainsaw:
		BMCS H 3;
		BMCS I 3 A_Scream;
		BMCS J 5 A_NoBlocking;
		BMCS KLM 5;
		BMCS N -1;
		Stop;
	Death_Pistol:
		BMPS H 3;
		BMPS I 3 A_PlayerScream;
		BMPS J 3 A_NoBlocking;
		BMPS KLM 5;
		BMPS N -1;
		Stop;
	Death_Shotgun:
		BMSG H 3;
		BMSG I 3 A_PlayerScream;
		BMSG J 3 A_NoBlocking;
		BMSG KLM 5;
		BMSG N -1;
		Stop;
	Death_SSG:
		BMSS H 3;
		BMSS I 3 A_Scream;
		BMSS J 3 A_NoBlocking;
		BMSS KLM 5;
		BMSS N -1;
		Stop;
	Death_Rifle:
		BMRF H 3;
		BMRF I 3 A_PlayerScream;
		BMRF J 3 A_NoBlocking;
		BMRF KLM 5;
		BMRF N -1;
		Stop;
	Death_Chaingun:
		BMCG H 3;
		BMCG I 3 A_PlayerScream;
		BMCG J 3 A_NoBlocking;
		BMCG KLM 5;
		BMCG N -1; 
		Stop;
	Death_Minigun:
		BMMG I 3;
		BMMG J 3 A_Scream;
		BMMG K 3 A_NoBlocking;
		BMMG LMN 5;
		BMMG O -1;
		Stop;
	Death_Sniper:
		BMSR H 3;
		BMSR I 3 A_Scream;
		BMSR J 3 A_NoBlocking;
		BMSR KLM 3;
		BMSR N -1;
		Stop;
	Death_RocketLauncher:
		BMRL H 3;
		BMRL I 3 A_Scream;
		BMRL J 3 A_NoBlocking;
		BMRL KLM 5;
		BMRL N -1;
		Stop;
	Death_GrenadeLauncher:
		BMGL H 3;
		BMGL I 3 A_Scream;
		BMGL J 5 A_NoBlocking;
		BMGL KLM 5;
		BMGL N -1;
		Stop;
	Death_ShoulderMount:
		BMSM H 3;
		BMSM I 3 A_Scream;
		BMSM J 5 A_NoBlocking;
		BMSM KLM 5;
		BMSM N -1;
		Stop;
	Death_Flamethrower:
		BMFT H 3;
		BMFT I 3 A_Scream;
		BMFT J 5 A_NoBlocking;
		BMFT KLM 5;
		BMFT N -1;
		Stop;
	Death_PlasmaRifle:
		BMPR H 3;
		BMPR I 3 A_Scream;
		BMPR J 3 A_NoBlocking;
		BMPR KLM 5;
		BMPR N -1;
		Stop;
	Death_Railgun:
		BMRG H 3;
		BMRG I 3 A_Scream;
		BMRG J 5 A_NoBlocking;
		BMRG KLM 5;
		BMRG N -1;
		Stop;
	Death_BFG9K:
		BM9K H 3;
		BM9K I 3 A_Scream;
		BM9K J 3 A_NoBlocking;
		BM9K KLM 5;
		BM9K N -1;
		Stop;
	Death_BFG10K:
		BM10 H 3;
		BM10 I 3 A_Scream;
		BM10 J 5 A_NoBlocking;
		BM10 KLM 5;
		BM10 N -1;
		Stop;
	// XDeath
	XDeath:
		TNT1 A 0 A_Jump(256, invoker.PVIS_STATES_XDEATH[invoker.WeaponVisual]);
		Goto XDeath_Rifle;
	XDeath_Unarmed:
		BMUA O 5;
		BMUA P 5 A_XScream;
		BMUA Q 5 A_NoBlocking;
		BMUA RSTUV 5;
		BMUA W -1;
		Stop;
	XDeath_Chainsaw:
		BMCS O 5;
		BMCS P 5 A_XScream;
		BMCS Q 5 A_NoBlocking;
		BMCS RSTUV 5;
		BMCS W -1; 
		Stop;
	XDeath_Pistol:
		BMPS O 5;
		BMPS P 5 A_XScream;
		BMPS Q 5 A_NoBlocking;
		BMPS RSTUV 5;
		BMPS W -1;
		Stop;
	XDeath_Shotgun:
		BMSG O 5;
		BMSG P 5 A_XScream;
		BMSG Q 5 A_NoBlocking;
		BMSG RSTUV 5;
		BMSG W -1;
		Stop;
	XDeath_SSG:
		BMSS O 5;
		BMSS P 5 A_XScream;
		BMSS Q 5 A_NoBlocking;
		BMSS RSTUV 5;
		BMSS W -1;
		Stop;
	XDeath_Rifle:
		BMRF O 5;
		BMRF P 5 A_XScream;
		BMRF Q 5 A_NoBlocking;
		BMRF RSTUV 5;
		BMRF W -1;
		Stop;
	XDeath_Chaingun:
		BMCG O 5;
		BMCG P 5 A_XScream;
		BMCG Q 5 A_NoBlocking;
		BMCG RSTUV 5;
		BMCG W -1;
		Stop;
	XDeath_Minigun:
		BMMG P 5;
		BMMG Q 5 A_XScream;
		BMMG R 5 A_NoBlocking;
		BMMG STUVW 5;
		BMMG X -1;
		Stop;
	XDeath_Sniper:
		BMSR O 5;
		BMSR P 5 A_XScream;
		BMSR Q 5 A_NoBlocking;
		BMSR RSTUVW 5;
		BMSR X -1;
		Stop;
	XDeath_RocketLauncher:
		BMRL O 5;
		BMRL P 5 A_XScream;
		BMRL Q 5 A_NoBlocking;
		BMRL RSTUV 5;
		BMRL W -1;
		Stop;
	XDeath_GrenadeLauncher:
		BMGL O 5;
		BMGL P 5 A_XScream;
		BMGL Q 5 A_NoBlocking;
		BMGL RSTUV 5;
		BMGL W -1;
		Stop;
	XDeath_ShoulderMount:
		BMSM O 5;
		BMSM P 5 A_XScream;
		BMSM Q 5 A_NoBlocking;
		BMSM RSTUV 5;
		BMSM W -1;
		Stop;
	XDeath_Flamethrower:
		BMFT O 5;
		BMFT P 5 A_XScream;
		BMFT Q 5 A_NoBlocking;
		BMFT RSTUV 5;
		BMFT W -1;
		Stop;
	XDeath_PlasmaRifle:
		BMPR O 5;
		BMPR P 5 A_XScream;
		BMPR Q 5 A_NoBlocking;
		BMPR RSTUV 5;
		BMPR W -1;
		Stop;
	XDeath_Railgun:
		BMRG O 5;
		BMRG P 5 A_XScream;
		BMRG Q 5 A_NoBlocking;
		BMRG RSTUV 5;
		BMRG W -1;
		Stop;
	XDeath_BFG9K:
		BM9K O 5;
		BM9K P 5 A_XScream;
		BM9K Q 5 A_NoBlocking;
		BM9K RSTU 5;
		BM9K V -1;
		Stop;
	XDeath_BFG10K:
		BM10 O 5;
		BM10 P 5 A_XScream;
		BM10 Q 5 A_NoBlocking;
		BM10 RSTUV 5;
		BM10 W -1;
		Stop;
	}

	// Parent overrides ========================================================

	final override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, name dmgType)
	{
		int ret = super.TakeSpecialDamage(inflictor, source, damage, dmgType);

		for (uint i = 0; i < Functors[FANDX_DAMAGETAKEN].Size(); i++)
		{
			BIO_DamageTakenFunctor(Functors[FANDX_DAMAGETAKEN][i]).OnDamageTaken(
				self, inflictor, source, damage, dmgType);
		}

		if (EquippedArmor != null)
		{
			if (CountInv('BasicArmor') < 1)
			{
				UnequipArmor(true);
			}
			// TODO: Armor break sound
		}

		return ret;
	}

	// Getters =================================================================

	bool IsWearingArmor() const { return EquippedArmor != null; }

	uint HeldWeaponCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Weapon' && !(i is 'BIO_Fist')) ret++; 

		return ret;
	}

	uint HeldEquipmentCount() const
	{
		uint ret = 0;

		for (Inventory i = Inv; i != null; i = i.Inv)
			if (i is 'BIO_Equipment') ret += i.Amount;
		
		return ret;
	}

	bool IsFullOnWeapons() const { return HeldWeaponCount() >= MaxWeaponsHeld; }
	bool IsFullOnEquipment() const { return HeldEquipmentCount() >= MaxEquipmentHeld; }

	// Setters =================================================================

	void WorldLoaded(bool isSaveGame, bool isReopen)
	{
		for (uint i = 0; i < Functors[FANDX_TRANSITION].Size(); i++)
		{
			BIO_TransitionFunctor(Functors[FANDX_TRANSITION][i])
				.WorldLoaded(self, isSaveGame, isReopen);
		}
	}

	void OnKill(Actor killed, Actor inflictor)
	{
		let bioWeapon = BIO_Weapon(Player.ReadyWeapon);
		if (bioWeapon != null) bioWeapon.OnKill(killed, inflictor);

		for (uint i = 0; i < Functors[FANDX_KILL].Size(); i++)
		{
			BIO_KillFunctor(Functors[FANDX_KILL][i])
				.OnKill(self, inflictor, killed);
		}
	}

	void Equip(BIO_Equipment equippable)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.OnEquip(self, equippable);
		}

		equippable.OnEquip();

		if (equippable is 'BIO_Armor')
		{
			EquippedArmor = BIO_Armor(equippable);
			EquippedArmor.Equipped = true;
			let armor_t = (Class<BIO_Armor>)(equippable.GetClass());
			GiveInventory(GetDefaultByType(armor_t).StatClass, 1);
		}
	}

	void UnequipArmor(bool broken)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.OnUnequip(self, EquippedArmor, broken);
		}

		EquippedArmor.OnUnequip(broken);
		EquippedArmor.Equipped = false;
		EquippedArmor = null;
		TakeInventory('BasicArmor', BIO_Armor.INFINITE_ARMOR);
		FindInventory('BasicArmor').MaxAmount = 1;
	}

	// Used to apply armor's affixes to BasicArmor, as well as
	// opening it up to modification by passives.
	void PreArmorApply(BIO_ArmorStats armor)
	{
		for (uint i = 0; i < Functors[FANDX_EQUIPMENT].Size(); i++)
		{
			BIO_EquipmentFunctor(Functors[FANDX_EQUIPMENT][i])
				.PreArmorApply(self, EquippedArmor, armor);
		}

		EquippedArmor.PreArmorApply(self, armor);
	}

	void OnHealthPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnHealthPickup(self, item);
		}
	}

	void OnAmmoPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnAmmoPickup(self, item);
		}
	}

	void OnBackpackPickup(BIO_Backpack bkpk)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnBackpackPickup(self, bkpk);
		}
	}

	void OnPowerupPickup(Inventory item)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnPowerupPickup(self, item);
		}
	}

	void OnMapPickup(Allmap map)
	{
		for (uint i = 0; i < Functors[FANDX_ITEMPKUP].Size(); i++)
		{
			BIO_ItemPickupFunctor(Functors[FANDX_ITEMPKUP][i])
				.OnMapPickup(self, map);
		}
	}

	void OnPowerupAttach(Powerup power)
	{
		for (uint i = 0; i < Functors[FANDX_POWERUP].Size(); i++)
		{
			BIO_PowerupFunctor(Functors[FANDX_POWERUP][i])
				.OnPowerupAttach(self, power);
		}
	}

	void OnPowerupDetach(Powerup power)
	{
		for (uint i = 0; i < Functors[FANDX_POWERUP].Size(); i++)
		{
			BIO_PowerupFunctor(Functors[FANDX_POWERUP][i])
				.OnPowerupDetach(self, power);
		}
	}

	// Passive/functor manipulation ============================================

	void PushPassive(Class<BIO_Passive> pasv_t, uint count = 1)
	{
		for (uint i = 0; i < Passives.Size(); i++)
		{
			if (Passives[i].GetClass() == pasv_t)
			{
				Passives[i].Count += count;
				Passives[i].Apply(self);
				return;
			}
		}

		uint e = Passives.Push(BIO_Passive(new(pasv_t)));
		Passives[e].Count = count;
		Passives[e].Apply(self);
	}

	void PopPassive(Class<BIO_Passive> pasv_t, uint count = 1)
	{
		bool all = count <= 0;

		for (uint i = 0; i < Passives.Size(); i++)
		{
			if (Passives[i].GetClass() != pasv_t) continue;

			if (Passives[i].Count < count)
			{
				Console.Printf(Biomorph.LOGPFX_WARN ..
					"Tried to pop passive %s off player %s %d times, but can only do %d.",
					pasv_t.GetClassName(), GetTag(), count, Passives[i].Count);
			}

			Passives[i].Remove(self);
			Passives[i].Count -= (all ? Passives[i].Count : count);
			if (Passives[i].Count <= 0) Passives.Delete(i);
			return;
		}

		Console.Printf(Biomorph.LOGPFX_ERR ..
			"Attempted to pop %d times %s, but found none on player %s.",
			count, pasv_t.GetClassName(), GetTag());
	}

	enum FunctorArrayIndex : uint
	{
		FANDX_DAMAGETAKEN,
		FANDX_EQUIPMENT,
		FANDX_ITEMPKUP,
		FANDX_KILL,
		FANDX_POWERUP,
		FANDX_TRANSITION,
		FANDX_WEAPON,
		FUNCTOR_ARRAY_LENGTH
	}

	void PushFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		uint ndx = uint.MAX;

		if (func_t is 'BIO_DamageTakenFunctor')
			ndx = FANDX_DAMAGETAKEN;
		else if (func_t is 'BIO_EquipmentFunctor')
			ndx = FANDX_EQUIPMENT;
		else if (func_t is 'BIO_ItemPickupFunctor')
			ndx = FANDX_ITEMPKUP;
		else if (func_t is 'BIO_KillFunctor')
			ndx = FANDX_KILL;
		else if (func_t is 'BIO_PowerupFunctor')
			ndx = FANDX_POWERUP;
		else if (func_t is 'BIO_TransitionFunctor')
			ndx = FANDX_TRANSITION;
		else if (func_t is 'BIO_WeaponFunctor')
			ndx = FANDX_WEAPON;
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to push player pawn functor of invalid type %s onto player %s",
				func_t.GetClassName(), GetTag());
			return;
		}

		for (uint i = 0; i < Functors[ndx].Size(); i++)
		{
			if (Functors[ndx][i].GetClass() == func_t)
			{
				Functors[ndx][i].Count += count;
				return;
			}
		}

		uint e = Functors[ndx].Push(BIO_PlayerFunctor(new(func_t)));
		Functors[ndx][e].Count = count;
	}

	void PopFunctor(Class<BIO_PlayerFunctor> func_t, uint count = 1)
	{
		uint ndx = uint.MAX;

		if (func_t is 'BIO_DamageTakenFunctor')
			ndx = FANDX_DAMAGETAKEN;
		else if (func_t is 'BIO_EquipmentFunctor')
			ndx = FANDX_EQUIPMENT;
		else if (func_t is 'BIO_ItemPickupFunctor')
			ndx = FANDX_ITEMPKUP;
		else if (func_t is 'BIO_KillFunctor')
			ndx = FANDX_KILL;
		else if (func_t is 'BIO_PowerupFunctor')
			ndx = FANDX_POWERUP;
		else if (func_t is 'BIO_TransitionFunctor')
			ndx = FANDX_TRANSITION;
		else if (func_t is 'BIO_WeaponFunctor')
			ndx = FANDX_WEAPON;
		else
		{
			Console.Printf(Biomorph.LOGPFX_ERR ..	
				"Tried to pop player pawn functor of invalid type %s off player %s",
				func_t.GetClassName(), GetTag());
			return;
		}

		{
			bool all = count <= 0;

			for (uint i = 0; i < Functors[ndx].Size(); i++)
			{
				if (Functors[ndx][i].GetClass() != func_t) continue;
				
				if (Functors[ndx][i].Count < count)
				{
					Console.Printf(Biomorph.LOGPFX_WARN ..
						"Tried to pop functor %s off player %s %d times, but can only do %d.",
						func_t.GetClassName(), GetTag(), count, Functors[ndx][i].Count);
				}

				Functors[ndx][i].Count -= (all ? Functors[ndx][i].Count : count);
				if (Functors[ndx][i].Count <= 0) Functors[ndx].Delete(i);
				return;
			}
		}
	}
}
