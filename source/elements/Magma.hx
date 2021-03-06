package elements;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;

class Magma extends FluidSystem
{

	//FlxGradient.createGradientArray(1, 10, [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700])
	public function new(W:World) 
	{
		super(W, [0xffc41204,0xfffc4e0c,0xfffc9a04,0xff3c1204,0xff7c2604,0xff541a04,0xff541a04,0xff541a04],checkParticle);
	}
	
	public function checkParticle(P:FluidParticle):Void
	{
		if (FlxRandom.chanceRoll(Math.floor(P.ageSinceLastMove * CountEmpties(_fSpr.pixels, P.x, P.y))))
		{
			//trace('stone!');
			//erasePx(_work, P.x, P.y);
			_w.ground.drawStone(P.x, P.y);
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
				if (FlxRandom.chanceRoll(1))
				{
					//erasePx(_fSpr.pixels, P.x, P.y);
					_w.MakeCave(P.x, P.y, World.CORIENT_P);
					
				}
			}
			
			
		}
		
			
	}
	
}