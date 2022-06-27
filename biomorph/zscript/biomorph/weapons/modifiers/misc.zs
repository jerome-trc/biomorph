class BIO_WMod_Kickback : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return context.Weap.Pipelines.Size() > 0, "$BIO_WMOD_INCOMPAT_NOPIPELINES";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		weap.Kickback += (weap.Default.Kickback * 2);
		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		return String.Format(
			StringTable.Localize("$BIO_WMOD_KICKBACK_DESC"),
			context.NodeCount * 200
		);
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_KICKBACK_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_Kickback';
	}
}

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

class BIO_WMod_SpreadNarrow : BIO_WeaponModifier
{
	Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].HSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALHSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].HSpread < 0.02)
				{
					HorizChanges.Push(0.0);
					VertChanges.Push(0.0);
					continue;
				}

				float h = weap.Pipelines[i].HSpread / 2.0;

				HorizChanges[i] -= h;
				VertChanges[i] += h;

				weap.Pipelines[i].HSpread -= h;
				weap.Pipelines[i].VSpread += h;
			}
		}

		return "";
	}

	final override string Description(BIO_GeneContext context) const
	{
		string ret = "";

		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
		{
			if (HorizChanges[i] >= -0.01 && VertChanges[i] <= 0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADNARROW_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_SPREAD_DEC | BIO_WMODF_SPREAD_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SpreadNarrow';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_SpreadNarrow');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}

class BIO_WMod_SpreadWiden : BIO_WeaponModifier
{
	Array<float> HorizChanges, VertChanges;

	final override bool, string Compatible(BIO_GeneContext context) const
	{
		for (uint i = 0; i < context.Weap.Pipelines.Size(); i++)
			if (context.Weap.Pipelines[i].VSpread >= 0.02)
				return true, "";

		return false, "$BIO_WMOD_INCOMPAT_TRIVIALVSPREAD";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext context) const
	{
		HorizChanges.Clear(); HorizChanges.Resize(weap.Pipelines.Size());
		VertChanges.Clear(); VertChanges.Resize(weap.Pipelines.Size());

		for (uint i = 0; i < weap.Pipelines.Size(); i++)
		{
			for (uint j = 0; j < context.NodeCount; j++)
			{
				if (weap.Pipelines[i].VSpread < 0.02)
				{
					HorizChanges.Push(0.0);
					VertChanges.Push(0.0);
					continue;
				}

				float v = weap.Pipelines[i].VSpread / 2.0;

				HorizChanges[i] += v;
				VertChanges[i] -= v;

				weap.Pipelines[i].HSpread += v;
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
			if (HorizChanges[i] <= 0.01 && VertChanges[i] >= -0.01)
				continue;

			string qual = "";

			if (context.Weap.Pipelines.Size() > 1)
				qual = " " .. context.Weap.Pipelines[i].GetTagAsQualifier();

			ret.AppendFormat(
				StringTable.Localize("$BIO_WMOD_SPREADWIDEN_DESC"), qual,
				HorizChanges[i], VertChanges[i]
			);
			ret = ret .. "\n";
		}

		ret.DeleteLastCharacter();
		return ret;
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_SPREAD_DEC | BIO_WMODF_SPREAD_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SpreadWiden';
	}

	final override BIO_WeaponModifier Copy() const
	{
		let ret = new('BIO_WMod_SpreadWiden');
		ret.HorizChanges.Copy(HorizChanges);
		ret.VertChanges.Copy(VertChanges);
		return ret;
	}
}

class BIO_WMod_SwitchSpeed : BIO_WeaponModifier
{
	final override bool, string Compatible(BIO_GeneContext context) const
	{
		return
			context.Weap.RaiseSpeed < BIO_Weapon.SWITCHSPEED_MAX &&
			context.Weap.LowerSpeed < BIO_Weapon.SWITCHSPEED_MAX,
			"$BIO_WMOD_INCOMPAT_SWITCHSPEEDMAX";
	}

	final override string Apply(BIO_Weapon weap, BIO_GeneContext _) const
	{
		weap.RaiseSpeed = weap.LowerSpeed = BIO_Weapon.SWITCHSPEED_MAX;
		return "";
	}

	final override string Description(BIO_GeneContext _) const
	{
		return Summary();
	}

	final override BIO_WeaponModFlags Flags() const
	{
		return BIO_WMODF_SWITCHSPEED_INC;
	}

	final override class<BIO_ModifierGene> GeneType() const
	{
		return 'BIO_MGene_SwitchSpeed';
	}
}
