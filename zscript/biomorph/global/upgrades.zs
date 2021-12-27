class BIO_WeaponUpgrade
{
	Class<BIO_Weapon> Input, Output;
	uint Cost;
}

extend class BIO_GlobalData
{
	const WEAP_UPGRADE_COST_STD_TO_STD = 1;
	const WEAP_UPGRADE_COST_SPEC_TO_SPEC = 2;
	const WEAP_UPGRADE_COST_CLSF_TO_CLSF = 3;

	const WEAP_UPGRADE_COST_STD_TO_SPEC = 3;
	const WEAP_UPGRADE_COST_SPEC_TO_CLSF = 7;
	const WEAP_UPGRADE_COST_STD_TO_CLSF =
		WEAP_UPGRADE_COST_STD_TO_SPEC + WEAP_UPGRADE_COST_SPEC_TO_CLSF;

	static const string UPGRADE_COST_CONSTANT_NAMES[] = {
		"STANDARD_TO_SPECIALTY",
		"SPECIALTY_TO_CLASSIFIED",
		"STANDARD_TO_CLASSIFIED",
		"STANDARD_TO_STANDARD",
		"SPECIALTY_TO_SPECIALTY",
		"CLASSIFIED_TO_CLASSIFIED"
	};

	static const uint UPGRADE_COST_CONSTANTS[] = {
		WEAP_UPGRADE_COST_STD_TO_SPEC,
		WEAP_UPGRADE_COST_SPEC_TO_CLSF,
		WEAP_UPGRADE_COST_STD_TO_CLSF,
		WEAP_UPGRADE_COST_STD_TO_STD,
		WEAP_UPGRADE_COST_SPEC_TO_SPEC,
		WEAP_UPGRADE_COST_CLSF_TO_CLSF
	};

	private Array<BIO_WeaponUpgrade> WeaponUpgrades;

	void PossibleWeaponUpgrades(in out Array<BIO_WeaponUpgrade> options,
		Class<BIO_Weapon> input_t) const
	{
		for (uint i = 0; i < WeaponUpgrades.Size(); i++)
		{
			if (WeaponUpgrades[i].Input != input_t) continue;

			options.Push(WeaponUpgrades[i]);
		}
	}
	
	// Initialisation: auto-generation =========================================

	private void ReadWeaponAutoUpgradeJSON(
		BIO_JsonObject autoups, int lump, BIO_WeaponCategory cat,
		in out Array<Class<BIO_Weapon> > standard,
		in out Array<Class<BIO_Weapon> > specialty,
		in out Array<Class<BIO_Weapon> > classified)
	{
		let arrJSON = BIO_Utils.TryGetJsonArray(autoups.get(
			BIO_Weapon.CATEGORY_IDS[cat]), errMsg: false);
		if (arrJSON == null) return;

		string errpfx = String.Format(Biomorph.LOGPFX_ERR .. LMPNAME_WEAPONS ..
			" lump %d, `upgrades_auto.%s`; ", lump, BIO_Weapon.CATEGORY_IDS[cat]);

		for (uint j = 0; j < arrJSON.arr.Size(); j++)
		{
			let t = (Class<BIO_Weapon>)
				(BIO_Utils.TryGetJsonClassName(arrJSON.arr[j]));

			if (t == null)
			{
				Console.Printf(errpfx .. "invalid weapon class at element %d.", j);
				continue;
			}

			if (t.IsAbstract())
			{
				Console.Printf(errpfx .. "abstract weapon class at element %d.", j);
				continue;
			}

			if (t == 'BIO_Fist')
			{
				Console.Printf(errpfx ..
					"`BIO_Fist` cannot have weapon upgrade recipes auto-generated "
					"(element %d).", j);
				continue;
			}

			switch (GetDefaultByType(t).Grade)
			{
			case BIO_GRADE_STANDARD:
				standard.Push(t);
				break;
			case BIO_GRADE_SPECIALTY:
				specialty.Push(t);
				break;
			case BIO_GRADE_CLASSIFIED:
				classified.Push(t);
				break;
			default: continue;
			}
		}
	}

	private void AutogenWeaponUpgradeRecipes(
		in out Array<Class<BIO_Weapon> > standard,
		in out Array<Class<BIO_Weapon> > specialty,
		in out Array<Class<BIO_Weapon> > classified)
	{
		for (uint j = 0; j < standard.Size(); j++)
		{
			for (uint k = 0; k < standard.Size(); k++)
			{
				if (standard[j] == standard[k]) continue;

				uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
				WeaponUpgrades[e].Input = standard[j];
				WeaponUpgrades[e].Output = standard[k];
				WeaponUpgrades[e].Cost = WEAP_UPGRADE_COST_STD_TO_STD;
			}

			for (uint k = 0; k < specialty.Size(); k++)
			{
				uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
				WeaponUpgrades[e].Input = standard[j];
				WeaponUpgrades[e].Output = specialty[k];
				WeaponUpgrades[e].Cost = WEAP_UPGRADE_COST_STD_TO_SPEC;
			}
		}

		for (uint j = 0; j < specialty.Size(); j++)
		{
			for (uint k = 0; k < specialty.Size(); k++)
			{
				if (specialty[j] == specialty[k]) continue;

				uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
				WeaponUpgrades[e].Input = specialty[j];
				WeaponUpgrades[e].Output = specialty[k];
				WeaponUpgrades[e].Cost = WEAP_UPGRADE_COST_SPEC_TO_SPEC;
			}

			for (uint k = 0; k < classified.Size(); k++)
			{
				uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
				WeaponUpgrades[e].Input = specialty[j];
				WeaponUpgrades[e].Output = classified[k];
				WeaponUpgrades[e].Cost = WEAP_UPGRADE_COST_SPEC_TO_CLSF;
			}
		}

		for (uint j = 0; j < classified.Size(); j++)
		{
			for (uint k = 0; k < classified.Size(); k++)
			{
				if (classified[j] == classified[k]) continue;

				uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
				WeaponUpgrades[e].Input = classified[j];
				WeaponUpgrades[e].Output = classified[k];
				WeaponUpgrades[e].Cost = WEAP_UPGRADE_COST_CLSF_TO_CLSF;
			}
		}
	}

	// Initialisation: Parsing JSON upgrade definitions ========================

	private static bool ReadWeaponUpgradeInput(
		in out Array<Class<BIO_Weapon> > inputs,
		Class<BIO_Weapon> input_t, string errpfx)
	{
		if (input_t == null)
		{
			Console.Printf(errpfx .. "invalid input class given.");
			return false;
		}

		if (input_t.IsAbstract())
		{
			Console.Printf(errpfx .. "abstract input class given: %s",
				input_t.GetClassName());
			return false;
		}

		if (input_t == 'BIO_Fist')
		{
			Console.Printf(errpfx .. "`BIO_Fist` cannot be an upgrade input.");
			return false;
		}

		inputs.Push(input_t);
		return true;
	}

	private static bool ReadWeaponUpgradeInputs(
		in out Array<Class<BIO_Weapon> > inputs,
		BIO_JsonArray inputArr, string errpfx)
	{
		if (inputArr.size() < 1)
		{
			Console.Printf(errpfx .. "input array is empty.");
			return false;
		}

		for (uint i = 0; i < inputArr.size(); i++)
		{
			let input_t = BIO_Utils.TryGetJsonClassName(inputArr.get(i));
			ReadWeaponUpgradeInput(inputs, (Class<BIO_Weapon>)(input_t), errpfx);
		}

		return true;
	}

	private static bool ReadWeaponUpgradeOutput(
		in out Array<Class<BIO_Weapon> > outputs,
		Class<BIO_Weapon> output_t, string errpfx)
	{
		if (output_t == null)
		{
			Console.Printf(errpfx .. "invalid output class given.");
			return false;
		}

		if (output_t.IsAbstract())
		{
			Console.Printf(errpfx .. "abstract output class given: %s",
				output_t.GetClassName());
			return false;
		}

		if (output_t == 'BIO_Fist')
		{
			Console.Printf(errpfx .. "`BIO_Fist` cannot be an upgrade output.");
			return false;
		}

		outputs.Push(output_t);
		return true;
	}

	private static bool ReadWeaponUpgradeOutputs(
		in out Array<Class<BIO_Weapon> > outputs,
		BIO_JsonArray outputArr, string errpfx)
	{
		if (outputArr.size() < 1)
		{
			Console.Printf(errpfx .. "output array is empty.");
			return false;
		}

		for (uint i = 0; i < outputArr.size(); i++)
		{
			let output_t = BIO_Utils.TryGetJsonClassName(outputArr.get(i));
			ReadWeaponUpgradeOutput(outputs, (Class<BIO_Weapon>)(output_t), errpfx);
		}

		return true;
	}

	private static uint ResolveUpgradeCostConstant(string str, string errpfx)
	{
		for (uint i = 0; i < BIO_GlobalData.UPGRADE_COST_CONSTANT_NAMES.Size(); i++)
		{
			if (str ~== BIO_GlobalData.UPGRADE_COST_CONSTANT_NAMES[i])
				return BIO_GlobalData.UPGRADE_COST_CONSTANTS[i];
		}

		Console.Printf(errpfx .. "unrecognized upgrade cost constant: " .. str);
		return uint.MAX;
	}

	private void ReadWeaponUpgradeJSON(BIO_JsonArray upgrades, int lump)
	{
		let wupItemDefs = GetDefaultByType('BIO_Muta_Upgrade');

		for (uint i = 0; i < upgrades.size(); i++)
		{
			string errpfx = String.Format(Biomorph.LOGPFX_ERR ..
				LMPNAME_WEAPONS .. " lump %d, upgrade object %d; ", lump, i);

			let upgrade = BIO_Utils.TryGetJsonObject(upgrades.get(i));
			if (upgrade == null)
			{
				Console.Printf(errpfx .. "skipping it.");
				continue;
			}

			Array<Class<BIO_Weapon> > inputs, outputs;
			uint cost = 0;
			bool reversible = false, valid = true;

			Array<string> keys;
			keys.Move(upgrade.getKeys().keys);
			
			for (uint j = 0; j < keys.Size(); j++)
			{
				if (keys[j] ~== "input")
				{
					Class<BIO_Weapon> input_t = (Class<BIO_Weapon>)
						(BIO_Utils.TryGetJsonClassName(upgrade.get("input"),
						errMsg: false));

					let inputArr = BIO_Utils.TryGetJsonArray(
						upgrade.get("input"), errMsg: false);

					if (input_t != null)
					{
						if (!ReadWeaponUpgradeInput(inputs, input_t, errpfx))
						{
							valid = false;
							break;
						}
					}
					else if (inputArr != null)
					{
						if (!ReadWeaponUpgradeInputs(inputs, inputArr, errpfx))
						{
							valid = false;
							break;
						}
					}
					else
					{
						Console.Printf(errpfx ..
							"`input` must be an array or class name.");
						valid = false;
						break;
					}
				}
				else if (keys[j] ~== "output")
				{
					Class<BIO_Weapon> output_t = (Class<BIO_Weapon>)
						(BIO_Utils.TryGetJsonClassName(upgrade.get("output"),
						errMsg: false));

					let outputArr = BIO_Utils.TryGetJsonArray(
						upgrade.get("output"), errMsg: false);

					if (output_t != null)
					{
						if (!ReadWeaponUpgradeOutput(outputs, output_t, errpfx))
						{
							valid = false;
							break;
						}
					}
					else if (outputArr != null)
					{
						if (!ReadWeaponUpgradeOutputs(outputs, outputArr, errpfx))
						{
							valid = false;
							break;
						}
					}
					else
					{
						Console.Printf(errpfx ..
							"`output` must be an array or class name.");
						valid = false;
						break;
					}
				}
				else if (keys[j] ~== "cost")
				{
					let costInt = BIO_Utils.TryGetJsonInt(
						upgrade.get("cost"), errMsg: false);
					let costStr = BIO_Utils.StringFromJson(
						upgrade.get("cost"), errMsg: false);

					if (costStr.Length() > 0)
						cost = ResolveUpgradeCostConstant(costStr, errpfx);
					else if (costInt != null)
						cost = uint(costInt.i);
					else
					{
						Console.Printf(errpfx .. "`cost` must be a string or integer.");
						continue;
					}

					if (cost > wupItemDefs.MaxAmount)
					{
						Console.Printf(errpfx ..
							"upgrade cost is invalid (must be between 0 and %d inclusive).",
							wupItemDefs.MaxAmount);
						continue;
					}
				}
				else if (keys[j] ~== "reversible")
				{
					let reversibleJSON = BIO_Utils.TryGetJsonBool(
						upgrade.get("reversible"), errMsg: false);

					if (reversibleJSON != null) reversible = reversibleJSON.b;
				}
				else
				{
					Console.Printf(errpfx .. "invalid field: %s", keys[j]);
				}
			}

			if (!valid) continue;

			// Validate that no fields were outright missing

			if (inputs.Size() == 0)
			{
				Console.Printf(errpfx .. "no input(s) given.");
				continue;
			}
			else if (outputs.Size() == 0)
			{
				Console.Printf(errpfx .. "no output(s) given.");
				continue;
			}
			else if (cost == 0)
			{
				Console.Printf(errpfx .. "no cost given.");
				continue;
			}

			// Generate recipes

			for (uint j = 0; j < inputs.Size(); j++)
			{
				for (uint k = 0; k < outputs.Size(); k++)
				{
					if (inputs[j] == outputs[k]) continue;

					uint e = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
					WeaponUpgrades[e].Input = inputs[j];
					WeaponUpgrades[e].Output = outputs[k];
					WeaponUpgrades[e].Cost = cost;

					if (!reversible) continue;

					uint er = WeaponUpgrades.Push(new('BIO_WeaponUpgrade'));
					WeaponUpgrades[er].Input = outputs[k];
					WeaponUpgrades[er].Output = inputs[j];
					WeaponUpgrades[er].Cost = cost;
				}
			}
		}
	}
}
