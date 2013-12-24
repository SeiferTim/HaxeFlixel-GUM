package elements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class Smoke extends FlxSprite
{

	private var COLOR_SMOKE:Array<Int>;
	
	
	
	public function new() 
	{
		COLOR_SMOKE = [0xff333333, 0xff666666, 0xff969696];
		super();	
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		alpha = 1;
		var size:Int = FlxRandom.intRanged(1, 3);
		makeGraphic(size, size, COLOR_SMOKE[FlxRandom.intRanged(0, COLOR_SMOKE.length-1)]);
		velocity.y = -3;
		velocity.x = 6 * ( -1 * FlxRandom.floatRanged(0.8, 1.2));
		
	}
	
	override public function update():Void
	{
		if (alpha > 0)
		{
			alpha -= FlxG.elapsed * 0.3;
			velocity.x *= ( -1 * FlxRandom.floatRanged(0.8, 1.2));
		}
		else
			kill();
		super.update();
		
	}
	
}