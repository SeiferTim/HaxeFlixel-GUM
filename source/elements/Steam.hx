package elements;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;

/**
 * ...
 * @author 
 */
class Steam extends FluidSystem
{

	public function new(W:World) 
	{
		super(W, FlxGradient.createGradientArray(1,10,[0x66F5F5F5, 0x66F0F0F0, 0x66C4C4C4],1,90), checkParticle, -1);
		
	}
	
	public function checkParticle(P:FluidParticle):Void
	{
		//if (FlxRandom.chanceRoll(P.age*30))
		if (FlxRandom.chanceRoll((P.age / 30) * 100))
		{
			//erasePx(_work, P.x, P.y);
			_f.remove(P);
		}
	}
	
}