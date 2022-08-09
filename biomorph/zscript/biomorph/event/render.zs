
struct BIO_RenderContext
{
	RenderEvent Event;
	BIOLE_ProjScreen Projector;
	BIOLE_Viewport Viewport;
}

// Overlay rendering and related members.
extend class BIO_EventHandler
{
	private transient CVar RenderMode;
	private BIOLE_ProjScreen ScreenProjector;

	private void RenderPrepare()
	{
		RenderMode = CVar.GetCVar("vid_rendermode", Players[ConsolePlayer]);

		switch (RenderMode.GetInt())
		{
		default:
			ScreenProjector = new('BIOLE_GLScreen');
			break;
		case 0:
		case 1:
			ScreenProjector = new('BIOLE_SWScreen');
			break;
		}
	}

	final override void RenderOverlay(RenderEvent event)
	{
		ScreenProjector.CacheResolution();
		ScreenProjector.CacheFOV(Players[ConsolePlayer].FOV);
		ScreenProjector.OrientForRenderOverlay(event);
		ScreenProjector.BeginProjection();

		let weap = BIO_Weapon(Players[ConsolePlayer].ReadyWeapon);

		if (weap == null)
			return;

		BIO_RenderContext context;
		context.Event = event;
		context.Projector = ScreenProjector;
		context.Viewport.FromHUD();
		weap.RenderOverlay(context);
	}
}
