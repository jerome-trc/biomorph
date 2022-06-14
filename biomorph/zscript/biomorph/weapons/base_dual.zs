// Note to reader: classes are defined using `extend` blocks for code folding.

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
		CHAN_RIGHTGUN = 12,
		CHAN_LEFTGUN = 13
	}

	flagdef NoAutoPrimary: DynFlags, 29;
	flagdef NoAutoSecondary: DynFlags, 30;
	flagdef AkimboReload: DynFlags, 31;

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
	// Normally `Ready` can be left as-is in weapons based on this one.
	Ready:
		TNT1 A 1 A_DualWeaponReady();
		Loop;
	// `Fire` state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	Fire:
		TNT1 A 1
		{
			return ResolveState('Ready');
		}
	// `AltFire` state is required for the weapon to function but isn't used directly.
	// Do not redefine.
	AltFire:
		TNT1 A 1
		{
			return ResolveState('Ready');
		}
	// Normally `Select` can be left as is in weapons based on this one.
	// Redefine only if you want to significantly change selection animation.
	Select:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, 'Select.Right');
			A_Overlay(PSP_LEFTGUN, 'Select.Left');
		}
		TNT1 A 1 A_Raise(invoker.RaiseSpeed);
		Wait;
	// Normally `Deselect` can be left as-is in weapons based on this one.
	// Redefine if you want to significantly change deselection animation.
	Deselect:
		TNT1 A 0
		{
			A_Overlay(PSP_RIGHTGUN, 'Deselect.Right');
			A_Overlay(PSP_LEFTGUN, 'Deselect.Left');
		}
		TNT1 A 1 A_Lower(invoker.LowerSpeed);
		Wait;
	}

	// Parent overrides ////////////////////////////////////////////////////////

	// Setup state pointers.
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		s_Ready = FindState('Ready');
		s_ReadyRight = FindState('Ready.Right');
		s_ReadyLeft = FindState('Ready.Left');
		s_FireRight = FindState('Fire.Right');
		s_FireLeft = FindState('Fire.Left');
		s_HoldRight = FindState('Hold.Right');
		s_HoldLeft = FindState('Hold.Left');
		s_FlashRight = FindState('Flash.Right');
		s_FlashLeft = FindState('Flash.Left');
		s_ReloadRight = FindState('Reload.Right');
		s_ReloadLeft = FindState('Reload.Left');
		s_ReloadWaitRight = FindState('ReloadWait.Right');
		s_ReloadWaitLeft = FindState('ReloadWait.Left');
	}

	override void Reset()
	{
		super.Reset();

		bNoAutoPrimary = Default.bNoAutoPrimary;
		bNoAutoSecondary = Default.bNoAutoSecondary;
		bAkimboReload = Default.bAkimboReload;
	}

	// Utility /////////////////////////////////////////////////////////////////

	readOnly<BIO_DualWieldWeapon> AsConst() const { return self; }
}

// Newly-defined actions.
extend class BIO_DualWieldWeapon
{
	// Returns true if ammo should be infinite.
	private action bool A_EDW_CheckInfiniteAmmo()
	{
		return (sv_infiniteammo || FindInventory('PowerInfiniteAmmo', true));
	}

	/*	This is meant to be called instead of `A_WeaponReady()` in the main
		`Ready` state sequence (NOT in the left/right ready sequences).
		This doesn't actually make the weapon ready for firing directly, but 
		rather makes sure everything is set up correctly and creates overlays
		if they haven't been created yet.
		It also initiates reloading.
	*/
	protected action void A_DualWeaponReady()
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
			if (invoker.bAkimboReload)
			{
				// Reload right gun
				if (reloadReadyRight) A_Reload_R();
				// At the same time reload left gun
				if (reloadReadyLeft) A_Reload_L();
			}
			// Otherwise both guns must be in their `Ready` states:
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

		/*	If player isn't pressing Reload but this flag was set by the right gun,
			proceed to reload the left gun as well.
			This is done to reload both guns in succession without having to
			press the Reload button twice.
		*/
		else if (!invoker.bAkimboReload && invoker.continueReload && reloadReadyLeft)
		{
			invoker.continueReload = false;
			A_Reload_L();
		}
		
		A_WeaponReady(WRF_NOFIRE); // Let the gun bob and be deselected
	}

	// Returns true if the gun is in its respective `Ready` state sequence
	private action bool A_CheckReady_R(bool left = false)
	{
		let psp = left ? Player.FindPSprite(PSP_LEFTGUN) : Player.FindPSprite(PSP_RIGHTGUN);
		let checkstate = left ? invoker.s_Readyleft : invoker.s_ReadyRight;
		return psp && InStateSequence(psp.CurState, checkstate);
	}

	// Left-weapon alias for `A_CheckReady_L()`.
	private action bool A_CheckReady_L()
	{
		return A_CheckReady_R(true);
	}

	/*  Returns true if:
		- The appropriate `Reload` sequence exists
		- Magazine isn't full
		- Reserve ammo isn't empty
	*/
	private action bool A_CheckReadyForReload_R(bool left = false)
	{
		if (!left)
		{
			return invoker.s_reloadRight && A_CheckReady_R() &&
				invoker.Magazine1 != invoker.Ammo1 &&
				(invoker.Magazine1.Amount < invoker.Magazine1.MaxAmount) &&
				(invoker.Ammo1.Amount >= invoker.AmmoUse1);
		}
		else
		{
			return invoker.s_reloadLeft && A_CheckReady_L() &&
				invoker.Magazine2 != invoker.Ammo2 &&
				(invoker.Magazine2.Amount < invoker.Magazine2.MaxAmount) &&
				(invoker.Ammo2.Amount >= invoker.AmmoUse2);
		}
	}

	// Left-weapon alias for `A_CheckReadyForReload_R()`.
	private action bool A_CheckReadyForReload_L()
	{
		return A_CheckReadyForReload_R(true);
	}
	
	// Returns true if the gun has enough ammo to fire.
	protected action bool A_CheckAmmo_R(bool left = false)
	{
		let ammo2check = left ? invoker.Magazine2 : invoker.Magazine1;
		// Return true if the weapon doesn't define ammo (= doesn't need it)
		if (!ammo2check) return true;
		// Otherwise get the required amount
		int reqAmt = left ? invoker.AmmoUse2 : invoker.AmmoUse1;
		// Return true if infinite ammo is active or we have enough
		return A_EDW_CheckInfiniteAmmo() || ammo2check.Amount >= reqAmt;
	}
	
	// Left-weapon alias for `A_CheckAmmo_R()`.
	protected action bool A_CheckAmmo_L()
	{
		return A_CheckAmmo_R(true);
	}
	
	/*  The actual raising is done via the regular `A_Raise()` in the regular `Select`
		state sequence. All this function does is, it checks if the main layer
		is already in the Ready state, and if so, moves the calling layer from
		`Select.Right`/`Select.Left` to `Ready.Right`/`Ready.Left`.
	*/
	protected action void A_Raise_R(bool left = false)
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

	// Left-weapon alias for `A_Raise_R()`.
	protected action void A_Raise_L()
	{
		A_Raise_R(true);
	}

	/*  Ready function for the right weapon. Will jump into the right `Fire` sequence
		or right `Reload` sequence based on buttons pressed and ammo available.
	*/
	protected action void A_WeaponReady_R()
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
			else if (invoker.MagazineType1 && invoker.Ammo1.Amount > 0)
			{
				if (invoker.bAkimboReload || A_CheckReadyForReload_L())
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
	
	/*  Ready function for the left weapon. Will jump into the left `Fire` sequence
		or left `Reload` sequence based on buttons pressed and ammo available.
	*/
	protected action void A_WeaponReady_L()
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
			else if (invoker.MagazineType2 && invoker.Ammo2.Amount > 0)
			{
				if (invoker.bAkimboReload || A_CheckReadyForReload_R())
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

	/*  Right-gun analong of `A_GunFlash()`. Does two things:
		- Draws `Flash.Right`/`Flash.Left` on `PSP_RIGHTFLASH`/`PSP_LEFTFLASH` layers
		- Makes sure the flash doesn't follow weapon bob and gets aligned
		with the gun layer the moment it's called (If you want to move the 
		flash around after that, you'll have to do it manually.)
	*/
	protected action void A_GunFlash_R(bool left = false)
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

	// Left-weapon alias for `A_GunFlash_R()`.
	protected action void A_GunFlash_L()
	{
		A_GunFlash_R(true);
	}
	
	// `A_ReFire` analog for the right gun. Increases player.Refire just like
	// `A_Refire()`, and resets it to 0 as long as neither gun is refiring.
	protected action void A_ReFire_R(bool left = false)
	{
		// Double-check player and psp:
		if (!Player) return;
		
		let psp = Player.FindPSprite(OverlayID());
		if (!psp) return;
		
		let s_fire = left ? invoker.s_FireLeft : invoker.s_FireRight; // Pointer to Fire
		let s_hold = left ? invoker.s_HoldLeft : invoker.s_Holdright; // Pointer to Hold
		int atkbutton = left ? BT_ALTATTACK : BT_ATTACK; // Check attack button is being held
		state targetState = null;
		// Check if this is being called from `Fire` or `Hold`:
		if (s_fire && (InStateSequence(psp.CurState, s_fire) ||
			InStateSequence(psp.CurState, s_hold)))
		{
			// Check if we have enough ammo and the attack button is being held:
			if (A_CheckAmmo_R(left) &&
				Player.Cmd.Buttons & atkButton &&
				player.OldButtons & atkButton)
			{
				//if so, jump to Hold (if it exists) or to Fire
				targetState = s_hold ? s_hold : s_fire;
			}
		}

		// If target state was set, increase `Player.Refire` and set the state:
		if (targetState) 
		{
			player.Refire++;
			player.SetPSprite(OverlayID(),targetState);
		}

		// If we're not refiring...
		else
		{
			// If the OTHER weapon is in its Ready sequence, reset player.Refire:
			if (A_CheckReady_R(left))
				player.Refire = 0;
		}
	}

	// Left-weapon alias for `A_ReFire_R()`.
	protected action void A_ReFire_L()
	{
		A_ReFire_R(true);
	}
	
	// This jumps to the reload state provided magazine isn't full
 	// and reserve ammo isn't empty.
	protected action void A_Reload_R(bool left = false)
	{
		if (!A_CheckReadyForReload_R(left)) return;

		// If `bAkimboReload` isn't set,
		// set the other gun into the `ReloadWait` state sequence:
		if (!invoker.bAkimboReload)
		{
			int otherGun = left ? PSP_RIGHTGUN : PSP_LEFTGUN;
			state waitState = left ? invoker.s_ReloadWaitRight : invoker.s_ReloadWaitLeft;
			
			if (waitState)
			{
				player.SetPSprite(otherGun,waitState);
				invoker.continueReload = true;
			}
		}

		// Set the current layer to the `Reload` state sequence:
		let targetState = left ? invoker.s_ReloadLeft : invoker.s_ReloadRight;
		int gunLayer = left ? PSP_LEFTGUN : PSP_RIGHTGUN;
		player.SetPSprite(gunLayer, targetState);
	}

	protected action void A_Reload_L()
	{
		A_Reload_R(true);
	}
	
	protected action void A_LoadMag_R(uint amt = 0)
	{
		A_BIO_LoadMag(amt, false);
	}

	protected action void A_LoadMag_L(uint amt = 0)
	{
		A_BIO_LoadMag(amt, true);
	}
}
