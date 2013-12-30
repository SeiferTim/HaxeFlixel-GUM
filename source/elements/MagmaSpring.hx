package elements;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class MagmaSpring extends FlxSprite
{
	private var _w:World;
	
	public function new(W:World, X:Int, Y:Int) 
	{
		
		super(X, Y);
		
		makeGraphic(1, 1, 0xff666666);
		
		_w = W;
		
		//trace("spring!");
	}
	
	override public function update():Void
	{
		if (alive && exists)
		{
			if (FlxRandom.chanceRoll(50))
			{
				if (_w.magma.isEmpty(_w.magma.mSpr.pixels, Std.int(x - 1), Std.int(y + 1)))
					_w.magma.spawnMagma(Std.int(x - 1), Std.int(y + 1));
			}
			if (FlxRandom.chanceRoll(50))
			{
				if (_w.magma.isEmpty(_w.magma.mSpr.pixels, Std.int(x), Std.int(y + 1)))
					_w.magma.spawnMagma(Std.int(x), Std.int(y + 1));
			}
			if (FlxRandom.chanceRoll(50))
			{
				if (_w.magma.isEmpty(_w.magma.mSpr.pixels, Std.int(x + 1), Std.int(y + 1)))
					_w.magma.spawnMagma(Std.int(x + 1), Std.int(y + 1));
			}
		}
		super.update();
			
	}
	
}