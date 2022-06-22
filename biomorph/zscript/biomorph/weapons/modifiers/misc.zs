class BIO_WMod_Spread : BIO_WeaponModifier
{
	Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (context.Weap.Pipelines[i].IsMelee())
				continue;

			if (context.Weap.Pipelines[i].CombinedSpread() <= 0.01)
				continue;

			return true, "";
		}

		return false, "$BIO_WMOD_INCOMPAT_NOSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].CombinedSpread() <= 0.01)
				{
					HorizChanges.Push(0.0);
					VertChanges.Push(0.0);
					continue;
				}

				float
					h = Min(weap.Pipelines[i].HSpread, 0.3),
					v = Min(weap.Pipelines[i].VSpread, 0.3);

				HorizChanges[i] -= h;
				VertChanges[i] -= v;

				weap.Pipelines[i].HSpread -= h;
				weap.Pipelines[i].VSpread -= v;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (HorizChanges[i] <= 0.01 && VertChanges[i] <= 0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREAD_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_SPREAD_DEC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Spread';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_Spread');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}