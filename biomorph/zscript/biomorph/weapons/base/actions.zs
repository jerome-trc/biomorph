extend class BIO_Weapon
{
	protected action void A_BIO_Fire(uint pipeline = 0)
	{
		invoker.Pipelines[pipeline].Invoke(invoker, pipeline);
	}

	protected action void A_BIO_FireSound(
		int channel = CHAN_WEAPON,
		int flags = CHANF_DEFAULT,
		double volume = 1.0,
		double attenuation = ATTN_NORM,
		uint pipeline = 0
	)
	{
		A_StartSound(
			invoker.Pipelines[pipeline].FireSound,
			channel,
			flags,
			volume,
			attenuation
		);
	}

	protected action bool A_BIO_DepleteAmmo(uint pipeline = 0)
	{
		let ppl = invoker.Pipelines[pipeline];

		if (ppl.Flags & BIO_WPF_PRIMARYAMMO)
		{
			if (!invoker.DepleteAmmo(false, true, invoker.AmmoUse1 * ppl.AmmoUseMulti))
				return false;
		}

		if (ppl.Flags & BIO_WPF_SECONDARYAMMO)
		{
			if (!invoker.DepleteAmmo(true, true, invoker.AmmoUse2 * ppl.AmmoUseMulti))
				return false;
		}

		return true;
	}

	// If no argument is given, try to reload as much of the magazine as 
	// possible. Otherwise, try to reload the given amount of rounds.
	action void A_BIO_LoadMag(uint amt = 0, bool secondary = false)
	{
		class<Ammo> res_t = null;

		BIO_Magazine mag = null;
		int cost = -1, output = -1, magsize = -1, reserve = -1;

		if (!secondary)
		{
			res_t = invoker.AmmoType1;
			mag = invoker.Magazine1;
			magsize = invoker.MagazineSize1;
			cost = invoker.ReloadCost1;
			output = invoker.ReloadOutput1;
		}
		else
		{
			res_t = invoker.AmmoType2;
			mag = invoker.Magazine2;
			magsize = invoker.MagazineSize2;
			cost = invoker.ReloadCost2;
			output = invoker.ReloadOutput2;
		}

		if (mag == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_WARN ..
				"%s tried to illegally load a null magazine.",
				invoker.GetClassName()
			);
			return;
		}

		if (mag.GetAmount() >= magsize)
			return;

		// e.g., pistols
		if (res_t == null)
		{
			mag.SetAmount(magsize);
			return;
		}
		else
		{
			reserve = CountInv(res_t);
		}

		int toLoad = -1, toDraw = -1;

		if (amt > 0)
		{
			toLoad = amt * output;
		}
		else
		{
			toLoad = magsize - mag.GetAmount();
			toLoad = int(Floor(float(toLoad) / float(output)));
		}

		toDraw = Min(toLoad * cost, reserve);
		toLoad = Min(toLoad, toDraw) * output;

		for (uint i = 0; i < invoker.Affixes.Size(); i++)
			invoker.Affixes[i].OnMagLoad(invoker, secondary, toDraw, toLoad);

		TakeInventory(res_t, toDraw);
		mag.Add(toLoad);
	}

	// Conventionally called on a `TNT1 A 0` state at the
	// very beginning of a fire/altfire state.
	protected action state A_BIO_CheckAmmo(
		bool secondary = false,
		statelabel fallback = 'Ready',
		statelabel reload = 'Reload',
		statelabel dryfire = 'Dryfire',
		int multi = 1,
		bool single = false
	)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
		{
			state dfs = ResolveState(dryfire);
			
			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}

		let cv = BIO_CVar.AutoReloadPre(Player);
		bool s = single || invoker.ShotsPerMagazine(secondary) == 1;

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && s))
		{
			return ResolveState(reload);
		}
		else
		{
			state dfs = ResolveState(dryfire);

			if (dfs != null)
				return dfs;
			else
				return ResolveState(fallback);
		}
	}

	// To be called at the end of a fire/altfire state.
	protected action state A_BIO_AutoReload(
		bool secondary = false,
		statelabel reload = 'Reload',
		int multi = 1,
		bool single = false
	)
	{
		if (invoker.SufficientAmmo(secondary, multi))
			return state(null);

		if (!invoker.CanReload())
			return state(null);

		let cv = BIO_CVar.AutoReloadPost(Player);
		bool s = single || invoker.ShotsPerMagazine(secondary) == 1;

		if (cv == BIO_CV_AUTOREL_ALWAYS || (cv == BIO_CV_AUTOREL_SINGLE && s))
			return ResolveState(reload);
		else
			return state(null);
	}

	// Call on a `TNT1 A 0` state before a `Reload` state sequence begins.
	protected action state A_BIO_CheckReload(
		bool secondary = false,
		statelabel fallback = 'Ready'
	)
	{
		if (invoker.CanReload(secondary))
			return state(null);
		else
			return ResolveState(fallback);
	}

	/*	Call from the weapon's `Spawn` state, after two frames of the weapon's 
		pickup sprite (each 0 tics long). Puts the weapon into a new loop with
		appropriate behaviour for its status (e.g., blinking cyan if mutated).
	*/
	protected action state A_BIO_Spawn()
	{
		if (invoker.Unique)
			return ResolveState('Spawn.Unique');
		else if (invoker.IsMutated())
			return ResolveState('Spawn.Mutated');
		else
			return ResolveState('Spawn.Normal');
	}

	/*	Call from the weapon's Deselect state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		lowering loop.
	*/
	protected action state A_BIO_Deselect()
	{
		invoker.OnDeselect();
		return ResolveState('Deselect.Loop');
	}

	/*	Call from the weapon's Select state, during one frame of the weapon's
		ready sprite (0 tics long). Runs a callback and puts the weapon in a 
		raising loop.
	*/
	protected action state A_BIO_Select()
	{
		invoker.OnSelect();
		return ResolveState('Select.Loop');
	}

	protected action void A_BIO_GroundHit()
	{
		if (Abs(invoker.Vel.Z) <= 0.01 && !invoker.bHitGround)
		{
			invoker.A_StartSound(invoker.GroundHitSound);
			invoker.A_ScaleVelocity(0.5);
			invoker.bSpecial = true;
			invoker.bThruActors = false;
			invoker.bHitGround = true;
		}
	}

	protected action void A_BIO_SetFireTime(
		uint index,
		uint group = 0,
		int modifier = 0
	)
	{
		A_SetTics(
			Max(modifier + invoker.FireTimeGroups[group].Times[index], 0)
		);
	}

	protected action void A_BIO_SetReloadTime(
		uint index,
		uint group = 0,
		int modifier = 0
	)
	{
		A_SetTics(
			Max(modifier + invoker.ReloadTimeGroups[group].Times[index], 0)
		);
	}

	protected action void A_BIO_Recoil(class<BIO_RecoilThinker> recoil_t,
		float scale = 1.0, bool invert = false)
	{
		BIO_RecoilThinker.Create(recoil_t, BIO_Weapon(invoker), scale, invert);
	}

	// Shunt the wielder in the opposite direction from the one they're facing.
	protected action void A_BIO_Pushback(float xVelMult, float zVelMult)
	{
		// Don't apply any if the wielding player isn't on the ground
		if (invoker.Owner.Pos.Z > invoker.Owner.FloorZ)
			return;

		A_ChangeVelocity(
			Cos(invoker.Pitch) * -xVelMult, 0.0,
			Sin(invoker.Pitch) * zVelMult, CVF_RELATIVE
		);
	}

	protected action void A_BIO_Raise() { A_Raise(invoker.RaiseSpeed); }
	protected action void A_BIO_Lower() { A_Lower(invoker.LowerSpeed); }

	protected action state A_BIO_WeaponSpecial()
	{
		if (invoker.SpecialFunc == null ||
			invoker.Owner.FindInventory('BIO_WeaponSpecialCooldown') != null)
			return state(null);

		invoker.Owner.GiveInventory('BIO_WeaponSpecialCooldown', 1);
		return invoker.SpecialFunc.Invoke(invoker);
	}
}
