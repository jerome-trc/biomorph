/// A singleton of this type holds loot tables, since these do not need to be
/// written to save games but must always be present (disallowing `transient`).
class biom_Static : StaticEventHandler
{
	/// Used by `biom_EventHandler::CheckReplacement`.
	private Dictionary replacements;

	final override void OnRegister()
	{
		if (developer >= 1)
		{
			Console.PrintF(
				Biomorph.LOGPFX_DEBUG ..
				"Registering static event handler..."
			);
		}

		self.replacements = Dictionary.Create();

		if (biom_Utils.LegenDoom())
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Populating LegenDoom Lite loot table..."
				);
			}

			self.PopulateLegenDoomLoot();
		}

		name valiantCG_tn = 'ValiantChaingun';

		if ((class<Weapon>)(valiantCG_tn) != null)
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Preparing Valiant replacement classes..."
				);
			}

			self.replacements.Insert("ValiantPistol", "biom_wpk_Slot2");
			self.replacements.Insert("ValiantShotgun", "biom_wpks_Shotgun");
			self.replacements.Insert("ValiantChaingun", "biom_wpks_Chaingun");
			self.replacements.Insert("ValiantSSG", "biom_wpks_SuperShotgun");
		}
	}

	class<Actor> GetReplacement(name type)
	{
		let tn = self.replacements.At(type);

		if (tn.Length() != 0)
			return (class<Actor>)(tn);

		return null;
	}

	private void PopulateLegenDoomLoot()
	{
		if (biom_Utils.DoomRLMonsterPack())
		{
			if (developer >= 1)
			{
				Console.PrintF(
					Biomorph.LOGPFX_DEBUG ..
					"Populating legendary loot table for the DoomRL Monster Pack..."
				);
			}
		}
	}
}
