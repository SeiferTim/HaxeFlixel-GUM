package elements;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;

class DwarfHouse extends FlxSprite
{

	private var COLOR_WALL:Array<Int>;
	
	private var _w:World;
	private var _paint:Int;
	private var _owned:Bool;
	private var _birthing:Bool;
	private var _delay:Float;
	private var _rect:FlxRect;
	
	public function new(W:World, X:Int, Y:Int) 
	{
		super(X, Y);
		health = 0;
		_w = W;
		makeGraphic(5, 5, 0x0);
		pixels = new BitmapData(5, 5, true, 0x0);
		dirty = true;
		resetFrameBitmapDatas();
		width = 5;
		height = 5;
		x = X - 3;
		y = Y - 3;
		_rect = new FlxRect(x, y, width, height);
		_owned = false;
		_birthing = false;
		_delay = 0;
		COLOR_WALL = FlxGradient.createGradientArray(10, 10, [0xFFBA8C00, 0xFFF5E16E]);
		_paint = COLOR_WALL[FlxRandom.intRanged(0, COLOR_WALL.length-1)];
		for (i in Std.int(x - 1)...Std.int(x + width + 1))
		{
			for (j in Std.int(y - 1)...Std.int(y + height + 1))
			{
				_w.MakeCave(i, j, World.CORIENT_P);
			}
		}
	}
	
	public function build(Value:Int):Void
	{
		if (Value == 0 || health == 26) return;
		var color:Int;
		var pY:Int;
		var pX:Int;
		
		for (i in Std.int(health)...Std.int(health + Value))
		{
			if (i <= 25)
			{
				color = COLOR_WALL[FlxRandom.intRanged(0, COLOR_WALL.length-1)];
				pX = i % 5;
				pY = Std.int(i / 5);
				if (pX >= 1 && pX <= 3 && pY < 2)
					pixels.setPixel32(pX, 4 - pY, 0xff333333);
				else
					pixels.setPixel32(pX, 4 - pY, color);
			}
		}
		
		dirty = true;
		resetFrameBitmapDatas();
		health += Value;
		if (health > 25) health = 26;
	}
	
	function get_owned():Bool 
	{
		return _owned;
	}
	
	function set_owned(value:Bool):Bool 
	{
		return _owned = value;
	}
	
	public var owned(get_owned, set_owned):Bool;
	
	function get_birthing():Bool 
	{
		return _birthing;
	}
	
	function set_birthing(value:Bool):Bool 
	{
		return _birthing = value;
	}
	
	public var birthing(get_birthing, set_birthing):Bool;
	
	function get_rect():FlxRect 
	{
		return _rect;
	}
	
	public var rect(get_rect, null):FlxRect;
	
}