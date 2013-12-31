package elements;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;

class Water extends FluidSystem
{
//FlxGradient.createGradientArray(1,10,[0x990051FF, 0x99A6C2FF, 0x99BEF5F7],1,90)
	public function new(W:World) 
	{
		super(W, [0x99265cff,0x993d6dff,0x991f55ff], checkParticle);
	}
	
	public function checkParticle(P:FluidParticle):Void
	{
		if (CheckPos(_w.magma.fSpr.pixels, P.x, P.y))
		{
			//erasePx(_w.magma.fSpr.pixels, P.x, P.y);
			//erasePx(fSpr.pixels, P.x, P.y);
			_w.ground.drawStone(P.x, P.y);
			_w.magma.killAtPos(P.x, P.y);
			_w.steam.spawnFluid(P.x, P.y);
			_f.remove(P);
		}
		
		if (FlxRandom.chanceRoll(Math.floor(P.ageSinceLastMove * CountEmpties(_fSpr.pixels, P.x, P.y))))
		{
			//erasePx(_work, P.x, P.y);
			_f.remove(P);
		}
		else
		{
			var dirChoice:Array<Int> = new Array<Int>();
			if (_w.isSolid(P.x, P.y + 1))
				dirChoice.push(D);
			if (_w.isSolid(P.x - 1, P.y))
				dirChoice.push(L);
			if (_w.isSolid(P.x+1, P.y))
				dirChoice.push(R);
			if (dirChoice.length > 0)
			{
				if (FlxRandom.chanceRoll(.1 * (5-P.ageSinceLastMove)))
				{
					_w.MakeCave(P.x, P.y, World.CORIENT_P);
					
				}
			}
		}
		
			
	}
	
}