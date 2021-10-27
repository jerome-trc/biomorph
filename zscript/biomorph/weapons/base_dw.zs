/*  Adapted from the Easy Dual Wield library by Jekyll Grim Payne.
	https://github.com/jekyllgrim/Easy-Dual-Wield

	MIT License

	Copyright (c) 2021 Agent_Ash aka Jekyll Grim Payne

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/
class BIO_DualWieldWeapon : BIO_Weapon abstract
{
	// Aliases for gun overlays.
	enum FireLayers
	{
		PSP_RIGHTGUN = 5,
		PSP_LEFTGUN = 6,
		PSP_RIGHTFLASH = 100,
		PSP_LEFTFLASH = 101
	}

	enum SoundChannels
	{
		CHAN_RIGHTGUN	= 12,
		CHAN_LEFTGUN = 13
	}

	protected state s_Ready,
		s_ReadyRight, s_ReadyLeft,
		s_FireRight, s_FireLeft,
		s_HoldRight, s_HoldLeft,
		s_FlashRight, s_FlashLeft,
		s_ReloadRight, s_ReloadLeft,
		s_ReloadWaitRight, s_ReloadWaitLeft;

	protected bool ContinueReload;

	States
	{
	// Normally Ready can be left as is in weapons based on this one
	Ready:
		TNT1 A 1 A_DualWeaponReady();
		Loop;
	// Fire state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	Fire:
		TNT1 A 1
		{
			return ResolveState("Ready");
		}
	// AltFire state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	AltFire:
		TNT1 A 1
		{
			return ResolveState("Ready");
		}
	// Normally Select can be left as is in weapons based on this one.
	// Redefine only if you want to significantly change selection animation
	Select:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, "Select.Right");
			A_Overlay(PSP_LEFTGUN, "Select.Left");
		}
		TNT1 A 1 A_Raise(invoker.RaiseSpeed);
		Wait;
	// Normally Deselect can be left as is in weapons based on this one.
	// Redefine if you want to significantly change deselection animation
	Deselect:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, "Deselect.Right");
			A_Overlay(PSP_LEFTGUN, "Deselect.Left");
		}
		TNT1 A 1 A_Lower(invoker.LowerSpeed);
		Wait;
	}

	// Setup state pointers.
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		s_Ready = FindState("Ready");
		s_ReadyRight = FindState("Ready.Right");
		s_ReadyLeft = FindState("Ready.Left");
		s_FireRight = FindState("Fire.Right");
		s_FireLeft = FindState("Fire.Left");
		s_HoldRight = FindState("Hold.Right");
		s_HoldLeft = FindState("Hold.Left");
		s_FlashRight = FindState("Flash.Right");
		s_FlashLeft = FindState("Flash.Left");
		s_ReloadRight = FindState("Reload.Right");
		s_ReloadLeft = FindState("Reload.Left");
		s_ReloadWaitRight = FindState("ReloadWait.Right");
		s_ReloadWaitLeft = FindState("ReloadWait.Left");
	}

	// Returns true if ammo should be infinite.
	action bool A_EDW_CheckInfiniteAmmo()
	{
		return (sv_infiniteammo || FindInventory("PowerInfiniteAmmo",true) );
	}
	
	/*	This is meant to be called instead of A_WeaponReady() in the main
		Ready state sequence (NOT in the left/right ready sequences).
		This doesn't actually make the weapon ready for firing directly, but 
		rather	makes sure everything is set up correctly and creates overlays
		if they haven't been created yet.
		It also initiates reloading.
	*/
	action void A_DualWeaponReady()
	{
		// Create gun overlays (once) if they're not drawn for some reason:
		A_Overlay(PSP_RIGHTGUN, "Ready.Right", nooverride:true);
		A_Overlay(PSP_LEFTGUN, "Ready.Left", nooverride:true);		
		
		bool readyRight = A_CheckReady_R();
		bool readyLeft = A_CheckReady_L();
		bool reloadReadyRight = A_CheckReadyForReload_R();
		bool reloadReadyLeft = A_CheckReadyForReload_L();
		
		// Disable "rage face" if neither weapon is firing:
		if (readyRight && readyLeft)
			Player.AttackDown = false;
		
		// Handle pressing Reload button
		if (Player.Cmd.Buttons & BT_RELOAD)
		{
			// Check if guns can be reloaded independently:
			if (invoker.BIOFlags & BIO_WF_AKIMBORELOAD)
			{
				// Reload right gun
				if (reloadReadyRight) A_Reload_R();
				// At the same time reload left gun
				if (reloadReadyLeft) A_Reload_L();
			}

			// Otherwise both guns must be in their Ready states:
			else if (readyRight && readyLeft)
			{
				// Only reload right:
				if (reloadReadyRight)
					A_Reload_R();
				// Otherwise only reload left:
				else
					A_Reload_L();
			}
		}

		/*	If player isn't pressing Reload but this bool was set by the right gun,
			proceed to reload the left gun as well.
			This is done to reload both guns in succession without having to
			press the Reload button twice.
		*/
		else if (!invoker.BIOFlags & BIO_WF_AKIMBORELOAD &&
			invoker.continueReload && reloadReadyLeft)
		{
			invoker.continueReload = false;
			A_Reload_L();
		}
		
		A_WeaponReady(WRF_NOFIRE); // Let the gun bob and be deselected
	}
	
	// Returns true if the gun is in its respective Ready state sequence
	action bool A_CheckReady_R(bool left = false)
	{
		let psp = left ? Player.FindPSprite(PSP_LEFTGUN) : Player.FindPSprite(PSP_RIGHTGUN);
		let checkstate = left ? invoker.s_Readyleft : invoker.s_ReadyRight;
		return (psp && InStateSequence(psp.CurState, checkstate));
	}

	// Left-weapon alias for A_CheckReady_L().
	action bool A_CheckReady_L()
	{
		return A_CheckReady_R(true);
	}
	
	/*  Returns true if:
		- The appropriate Reload sequence exists
		- Magazine isn't full
		- Reserve ammo isn't empty
	*/
	action bool A_CheckReadyForReload_R(bool left = false)
	{
		if (!left)
		{
			return invoker.s_reloadRight && A_CheckReady_R() &&
				invoker.Magazine1 != invoker.ammo1 &&
				(invoker.Magazine1.amount < invoker.Magazine1.maxamount) &&
				(invoker.ammo1.amount >= invoker.ammouse1);
		}
		else
		{
			return invoker.s_reloadLeft && A_CheckReady_L() &&
				invoker.Magazine2 != invoker.ammo2 &&
				(invoker.Magazine2.amount < invoker.Magazine2.maxamount) &&
				(invoker.ammo2.amount >= invoker.ammouse2);
		}
	}

	// Left-weapon alias for A_CheckReadyForReload_R().
	action bool A_CheckReadyForReload_L()
	{
		return A_CheckReadyForReload_R(true);
	}
	
	// Returns true if the gun has enough ammo to fire.
	action bool A_CheckAmmo_R(bool left = false)
	{
		let ammo2check = left ? invoker.Magazine2 : invoker.Magazine1;
		// Return true if the weapon doesn't define ammo (= doesn't need it)
		if (!ammo2check) return true;
		// Otherwise get the required amount
		int reqAmt = left ? invoker.AmmoUse2 : invoker.AmmoUse1;
		// Return true if infinite ammo is active or we have enough
		return A_EDW_CheckInfiniteAmmo() || ammo2check.Amount >= reqAmt;
	}
	
	// Left-weapon alias for A_CheckAmmo_R().
	action bool A_CheckAmmo_L()
	{
		return A_CheckAmmo_R(true);
	}
	
	/*  The actual raising is done via the regular A_Raise in the regular Select
		state sequence. All this function does is, it checks if the main layer
		is already in the Ready state, and if so, moves the calling layer from
		Select.Right/Select.Left to Ready.Right/Ready.Left.
	*/
	action void A_Raise_R(bool left = false)
	{
		if (!player)
			return;
		let psp = player.FindPSprite(PSP_WEAPON);
		if (!psp)
			return;
		let targetState = left ? invoker.s_readyLeft : invoker.s_readyRight;
		if (InStateSequence(psp.curstate,invoker.s_ready))
		{
			player.SetPsprite(OverlayID(),targetState);
		}
	}

	// Left-weapon alias for A_Raise_R().
	action void A_Raise_L()
	{
		A_Raise_R(true);
	}
	
	/*  Ready function for the right weapon. Will jump into the right Fire
		sequence or right Reload sequence based on buttons pressed and ammo available.
	*/
	action void A_WeaponReady_R()
	{
		if (!Player) return;
		// Enable bobbing:
		A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		state targetState = null;
		bool pressingFire = Player.Cmd.Buttons & BT_ATTACK;		
		if (pressingFire)
		{
			if (A_CheckAmmo_R())
			{
				targetState = invoker.s_fireRight;
				invoker.continueReload = false;
			}
			else if (invoker.MagazineType1 && invoker.Ammo1.amount > 0)
			{
				if (invoker.BIOFlags & BIO_WF_AKIMBORELOAD || A_CheckReadyForReload_L())
				{
					A_Reload_R();
					return;
				}
			}			
		}

		// If we're going to fire/reload, disable bobbing:
		if (targetState) 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, false);
			Player.SetPSprite(OverlayID(),targetState);
		}
		// Otherwise re-enable bobbing:
		else 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		}
	}
	
	/*  Ready function for the left weapon. Will jump into the left Fire sequence or
		left Reload sequence based on buttons pressed and ammo available.
	*/
	action void A_WeaponReady_L()
	{
		if (!Player) return;			
		A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);

		state targetState = null;
		bool pressingFire = Player.Cmd.Buttons & BT_ALTATTACK;		
		if (pressingFire)
		{
			if (A_CheckAmmo_L())
			{
				targetState = invoker.s_FireLeft;
				invoker.continueReload = false;
			}
			else if (invoker.MagazineType2 && invoker.Ammo2.amount > 0)
			{
				if (invoker.BIOFlags & BIO_WF_AKIMBORELOAD || A_CheckReadyForReload_R())
				{
					A_Reload_L();
					return;
				}					
			}			
		}	

		if (targetState) 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, false);
			Player.SetPsprite(OverlayID(), targetState);
		}
		else 
		{
			A_OverlayFlags(OverlayID(), PSPF_ADDBOB, true);
		}
	}
	
	/*  Right-gun analong of A_GunFlash. Does two things:
		- Draws Flash.Right/Flash.Left on PSP_RIGHTFLASH/PSP_LEFTFLASH layers
		- Makes sure the flash doesn't follow weapon bob and gets aligned
		with the gun layer the moment it's called (If you want to move the 
		flash around after that, you'll have to do it manually.)
	*/
	action void A_GunFlash_R(bool left = false)
	{
		if (!player)
			return;
		let psp = Player.FindPSprite(OverlayID());
		if (!psp)
			return;
		int layer = left ? PSP_LEFTFLASH : PSP_RIGHTFLASH;
		state flashstate = left ? invoker.s_flashLeft : invoker.s_flashRight;
		if (!flashstate)
			return;
		Player.SetPsprite(layer,flashstate);
		A_OverlayFlags(layer,PSPF_ADDBOB,false);
		A_OverlayOffset(layer,psp.x,psp.y);
		
	}

	// Left-weapon alias for A_GunFlash_R().
	action void A_GunFlash_L()
	{
		A_GunFlash_R(true);
	}
	
	/*  A_ReFire analog for the right gun. Increases player.Refire just like
		A_Refire(), and resets it to 0 as long as neither gun is refiring.
	*/
	action void A_ReFire_R(bool left = false)
	{
		// Double-check player and psp:
		if (!Player) return;
		
		let psp = Player.FindPSprite(OverlayID());
		if (!psp) return;
		
		let s_fire = left ? invoker.s_FireLeft : invoker.s_FireRight; // Pointer to Fire
		let s_hold = left ? invoker.s_HoldLeft : invoker.s_Holdright; // Pointer to Hold
		int atkbutton = left ? BT_ALTATTACK : BT_ATTACK; // Check attack button is being held
		state targetState = null;
		// Check if this is being called from Fire or Hold:
		if (s_fire && (InStateSequence(psp.CurState, s_fire) ||
			InStateSequence(psp.CurState, s_hold)))
		{
			//Check if we have enough ammo and the attack button is being held:
			if (A_CheckAmmo_R(left) &&
				Player.Cmd.Buttons & atkButton &&
				player.OldButtons & atkButton)
			{
				//if so, jump to Hold (if it exists) or to Fire
				targetState = s_hold ? s_hold : s_fire;
			}
		}

		// If target state was set, increase player.refire and set the state:
		if (targetState) 
		{
			player.refire++;
			player.SetPsprite(OverlayID(),targetState);
		}

		// If we're not refiring...
		else
		{
			// If the OTHER weapon is in its Ready sequence, reset player.Refire:
			if (A_CheckReady_R(left))
				player.Refire = 0;
		}
	}

	// Left-weapon alias for A_ReFire_R().
	action void A_ReFire_L()
	{
		A_ReFire_R(true);
	}
	
	/*	This jumps to the reload state provided magazine isn't full
		and reserve ammo isn't empty.
	*/
	action void A_Reload_R(bool left = false)
	{
		if (!A_CheckReadyForReload_R(left)) return;

		// If WMF_AKIMBORELOAD isn't set, set the other gun into ReloadWait state sequence:
		if (!invoker.BIOFlags & BIO_WF_AKIMBORELOAD)
		{
			int otherGun = left ? PSP_RIGHTGUN : PSP_LEFTGUN;
			state waitState = left ? invoker.s_ReloadWaitRight : invoker.s_ReloadWaitLeft;
			
			if (waitState)
			{
				player.SetPSprite(otherGun,waitState);
				invoker.continueReload = true;
			}
		}

		// Set the current layer to the Reload state sequence:
		let targetState = left ? invoker.s_ReloadLeft : invoker.s_ReloadRight;
		int gunLayer = left ? PSP_LEFTGUN : PSP_RIGHTGUN;
		player.SetPSprite(gunLayer, targetState);
	}

	action void A_Reload_L()
	{
		A_Reload_R(true);
	}
	
	action void A_LoadMag_R(uint amt = 0)
	{
		A_LoadMag(amt, false);
	}

	action void A_LoadMag_L(uint amt = 0)
	{
		A_LoadMag(amt, true);
	}

	// Attacks =================================================================

	/*  To make sure the correct ammo is consumed for each attack,
		we need to manually set invoker.bAltFire to false to consume
		primary ammo, and to true to consume secondary ammo.
		I made a bunch of simple wrappers for the generic attack
		functions.
		If you need to use a custom attack function, you'll have to set
		bAltFire manually. A_SetFireMode below can be used for that.
	*/
	
	// Call this before custom attack functions to define which gun is firing
	action void A_SetFireMode(bool secondary = false) 
	{
		invoker.bAltFire = secondary;
	}
	
	/*
		These are very simple wrappers that set bAltFire to false for 
		right gun and true for left gun to make sure the correct ammo 
		is consumed.
	*/

	// Wraps A_FireBullets.
	action void A_FireBullets_R(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t = "BulletPuff", int flags = 1,
		double range = 0, Class<Actor> missile = null, double spawnHeight = 32,
		double spawnOffs_xy = 0)
	{
		invoker.bAltFire = false;
		A_FireBullets(spread_xy, spread_z, numBullets, bulletDmg, puff_t, flags, range ,missile, spawnHeight, spawnOffs_xy);
	}	

	action void A_FireBullets_L(double spread_xy, double spread_z, int numBullets,
		int bulletDmg, Class<Actor> puff_t = "BulletPuff", int flags = 1,
		double range = 0, Class<Actor> missile = null, double spawnHeight = 32,
		double spawnOffs_xy = 0)
	{
		invoker.bAltFire = true;
		A_FireBullets(spread_xy, spread_z, numBullets, bulletDmg, puff_t, flags, range ,missile, spawnHeight, spawnOffs_xy);
	}

	// Wraps A_FireProjectile.
	action Actor A_FireProjectile_R(Class<Actor> missiletype, double angle = 0,
		bool useAmmo = true, double spawnOffs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		invoker.bAltFire = false;
		return A_FireProjectile(missiletype, angle, useAmmo, spawnOffs_xy, spawnHeight, flags, pitch);
	}

	action Actor A_FireProjectile_L(Class<Actor> missiletype, double angle = 0,
		bool useAmmo = true, double spawnOffs_xy = 0, double spawnHeight = 0,
		int flags = 0, double pitch = 0)
	{
		invoker.bAltFire = true;
		return A_FireProjectile(missiletype, angle, useAmmo, spawnOffs_xy, spawnHeight, flags, pitch);
	}

	// Wraps A_CustomPunch.
	action void A_CustomPunch_R(int damage, bool noRandom = false,
		int flags = CPF_USEAMMO, Class<Actor> puff_t = "BulletPuff",
		double range = 0, double lifesteal = 0, int lifestealMax = 0,
		Class<BasicArmorBonus> armorBonus_t = "ArmorBonus", sound meleeSound = 0,
		sound MissSound = "")
	{
		invoker.bAltFire = false;
		A_CustomPunch(damage, noRandom, flags, puff_t, range, lifesteal, lifestealMax, armorBonus_t, meleeSound, MissSound);
	}

	action void A_CustomPunch_L(int damage, bool noRandom = false,
		int flags = CPF_USEAMMO, Class<Actor> puff_t = "BulletPuff",
		double range = 0, double lifesteal = 0, int lifestealMax = 0,
		Class<BasicArmorBonus> armorBonus_t = "ArmorBonus", sound meleeSound = 0,
		sound MissSound = "")
	{
		invoker.bAltFire = true;
		A_CustomPunch(damage, noRandom, flags, puff_t, range, lifesteal, lifestealMax, armorBonus_t, meleeSound, MissSound);
	}

	// Wraps A_RailAttack.
	action void A_RailAttack_R(int damage, int spawnOffs_xy = 0,
		bool useAmmo = true, Color color1 = 0, Color color2 = 0, int flags = 0,
		double maxDiff = 0, Class<Actor> puff_t = "BulletPuff",
		double spread_xy = 0, double spread_z = 0, double range = 0,
		int duration = 0, double sparsity = 1.0, double driftSpeed = 1.0,
		Class<Actor> spawn_t = "none", double spawnOffs_z = 0,
		int spiralOffs = 270, int limit = 0)
	{
		invoker.bAltFire = false;
		A_RailAttack(damage, spawnOffs_xy, useAmmo, color1, color2, flags, maxDiff,
			puff_t, spread_xy, spread_z, range, duration, sparsity, driftSpeed,
			spawn_t, spawnOffs_z, spiralOffs, limit);
	}

	action void A_RailAttack_L(int damage, int spawnOffs_xy = 0,
		bool useAmmo = true, Color color1 = 0, Color color2 = 0, int flags = 0,
		double maxDiff = 0, Class<Actor> puff_t = "BulletPuff",
		double spread_xy = 0, double spread_z = 0, double range = 0,
		int duration = 0, double sparsity = 1.0, double driftSpeed = 1.0,
		Class<Actor> spawn_t = "none", double spawnOffs_z = 0,
		int spiralOffs = 270, int limit = 0)
	{
		invoker.bAltFire = true;
		A_RailAttack(damage, spawnOffs_xy, useAmmo, color1, color2, flags, maxDiff,
			puff_t, spread_xy, spread_z, range, duration, sparsity, driftSpeed,
			spawn_t, spawnOffs_z, spiralOffs, limit);
	}
}
