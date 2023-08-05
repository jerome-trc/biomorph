// Symbolic constants which pretend to be a part of certain gzdoom.pk3 enums
// (zscript/constants.zs), for better clarity what arguments really mean.

const BFGF_NONE = 0; // EBFGSprayFlags
const CPF_NONE = 0; // ECustomPunchFlags
const DI_NONE = 0; // DI_Flags
const FBF_NONE = 0; // EFireBulletsFlags
const LAF_NONE = 0; // ELineAttackFlags
const RGF_NONE = 0; // ERailFlags
const TRF_NONE = 0; // ELineTraceFlags
const SXF_NONE = 0; // ESpawnItemFlags
const XF_NONE = 0; // EExplodeFlags

extend class biom_Utils
{
	enum TranslucencyStyle : int
	{
		TRANSLUCENCY_NORMAL = 0,
		TRANSLUCENCY_ADDITIVE = 1,
		TRANSLUCENCY_FUZZ = 2
	}
}
