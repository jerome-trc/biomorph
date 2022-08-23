// (Rat): My kingdom for some honest-to-god sum types

class BIO_WeaponModSimGene play abstract
{
	BIO_WeaponModifier Modifier;

	abstract void UpdateModifier();
	abstract class<BIO_Gene> GetType() const;

	string GetSummaryTooltip() const
	{
		let defs = GetDefaultByType(GetType());
		return String.Format("\c[White]%s\n\n%s",
			defs.GetTag(),
			StringTable.Localize(defs.Summary)
		);
	}

	string GetDescriptionTooltip(
		readOnly<BIO_Weapon> weap,
		in out BIO_GeneContext context
	) const
	{
		let gene_t = GetType();

		if (gene_t is 'BIO_ModifierGene')
		{
			let defs = GetDefaultByType((class<BIO_ModifierGene>)(gene_t));

			return String.Format(
				"\c[White]%s\n\n%s",
				defs.GetTag(),
				StringTable.Localize(Modifier.Description(context))
			);
		}
		else
		{
			return GetSummaryTooltip();
		}
	}
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were in the player's inventory at simulation start.
class BIO_WeaponModSimGeneReal : BIO_WeaponModSimGene
{
	BIO_Gene Gene;

	final override void UpdateModifier()
	{
		// Explicitly check for this case, since it should never happen
		if (Gene == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A weapon mod sim gene object has a null internal pointer."
			);
			return;
		}

		if (Gene is 'BIO_ModifierGene')
		{
			let mod_t = BIO_ModifierGene(Gene).ModType;

			if (Modifier != null && Modifier.GetClass() == mod_t)
			{
				let mod = Modifier.Copy();
				Modifier = mod;
			}
			else
			{
				Modifier = BIO_WeaponModifier(new(mod_t));
			}
		}
	}

	BIO_WeaponModSimGeneVirtual VirtualCopy(class<BIO_Gene> newType) const
	{
		let ret = new('BIO_WeaponModSimGeneVirtual');

		if (Modifier != null)
		{
			ret.Type = Modifier.GeneType();
			ret.Modifier = Modifier.Copy();
		}
		else
		{
			ret.Type = newType;
		}

		return ret;
	}

	final override class<BIO_Gene> GetType() const { return Gene.GetClass(); }
}

// When representing genes that can be moved around the simulated graph, this
// is used for genes which were slotted into the tree at simulation start,
// since those genes have no associated items.
class BIO_WeaponModSimGeneVirtual : BIO_WeaponModSimGene
{
	class<BIO_Gene> Type;

	final override void UpdateModifier()
	{
		// Explicitly check for this case, since it should never happen
		if (Type == null)
		{
			Console.Printf(
				Biomorph.LOGPFX_ERR ..
				"A weapon mod sim gene object has a null internal class."
			);
			return;
		}

		if (Type is 'BIO_ModifierGene')
		{
			let mgene_t = (class<BIO_ModifierGene>)(Type);
			let defs = GetDefaultByType(mgene_t);
			
			if (Modifier != null && defs.ModType == Modifier.GetClass())
			{
				let mod = Modifier.Copy();
				Modifier = mod;
			}
			else
			{
				Modifier = BIO_WeaponModifier(new(defs.ModType));
			}
		}
	}

	final override class<BIO_Gene> GetType() const { return Type; }
}
