class TextureWrapper
{
	TextureID ID;
	int Width, Height;

	static TextureWrapper Create(string texname, int useType, int flags = TexMan.TRYANY)
	{
		TextureWrapper ret = new('TextureWrapper');

		ret.ID = TexMan.CheckForTexture(texname, useType, flags);
		[ret.Width, ret.Height] = TexMan.GetSize(ret.ID);

		return ret;
	}

	static TextureWrapper FromID(TextureID id)
	{
		TextureWrapper ret = new('TextureWrapper');
		ret.ID = id;
		[ret.Width, ret.Height] = TexMan.GetSize(ret.ID);

		return ret;
	}
}
