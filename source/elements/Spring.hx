package elements;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Spring extends FlxSprite
{
	private var _w:World;
	private var _springType:Int;
	private var _target:FluidSystem;
	
	public static inline var TYPE_MAGMA:Int = 0;
	public static inline var TYPE_WATER:Int = 1;
	public static inline var TYPE_STEAM:Int = 2;
	
	public function new(W:World, X:Int, Y:Int, SpringType:Int = -1) 
	{
		
		super(X, Y);
		
		makeGraphic(1, 1, 0xff666666);
		
		_w = W;
		
		if (SpringType == -1)
			_springType = FlxRandom.intRanged(0, TYPE_STEAM);
		else
			_springType = SpringType;
		switch(_springType)
		{
			case TYPE_MAGMA:
				_target = _w.magma;
			case TYPE_WATER:
				_target = _w.water;
			case TYPE_STEAM:
				_target = _w.steam;
		}
	}
	
	override public function update():Void
	{
		if (alive && exists)
		{
			if (FlxRandom.chanceRoll(50))
			{
				if (_target.isEmpty(_target.fSpr.pixels, Std.int(x - 1), Std.int(y + 1)))
					_target.spawnFluid(Std.int(x - 1), Std.int(y + 1));
			}
			if (FlxRandom.chanceRoll(50))
			{
				if (_target.isEmpty(_target.fSpr.pixels, Std.int(x), Std.int(y + 1)))
					_target.spawnFluid(Std.int(x), Std.int(y + 1));
			}
			if (FlxRandom.chanceRoll(50))
			{
				if (_target.isEmpty(_target.fSpr.pixels, Std.int(x + 1), Std.int(y + 1)))
					_target.spawnFluid(Std.int(x + 1), Std.int(y + 1));
			}
		}
		super.update();
			
	}
	
	function get_springType():Int 
	{
		return _springType;
	}
	
	public var springType(get_springType, null):Int;
	
}