package elements;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;


class House extends FlxSprite
{
	private var COLOR_TRUNK:Array<Int>;
	private var COLOR_PAINT:Array<Int>;
	
	private var _w:World;
	private var _paint:Int;
	private var _owned:Bool;
	private var _birthing:Bool;
	
	private var _delay:Float;
	
	public function new(W:World, X:Int, Y:Int) 
	{
		super(X, Y - 4);
		
		COLOR_TRUNK = [0xff5C4425, 0xff736149, 0xff8A847D, 0xff573A14];
		COLOR_PAINT = [0xffF2F2F2, 0xff821D1D, 0xffFCFFB0, 0xff8A1D2F];
		
		health = 0;
		_w = W;
		makeGraphic(5, 5, 0x00000000);
		pixels = new BitmapData(5, 5, true, 0x00000000);
		dirty = true;
		resetFrameBitmapDatas();
		width = 5;
		height = 5;
		x = X;
		y = Y - 5;
		_owned = false;
		_birthing = false;
		_delay = 0;
		for (i in Std.int(x - 1)...Std.int(x + 7))
		{
			if (_w.ground.points[i] > Y)
			{
				_w.ground.fillGround(i, _w.ground.points[i] - Y);
			}
			else if (_w.ground.points[i] < Y)
			{
				_w.ground.cutGround(i, Y -_w.ground.points[i]);
			}
		}
		_w.ground.groundMap.dirty = true;
		_w.ground.groundMap.resetFrameBitmapDatas();
		_paint = COLOR_PAINT[FlxRandom.intRanged(0, COLOR_TRUNK.length)];
	}
	
	public function build(Value:Int):Void
	{
		
		if (Value == 0 || health == 51) return;
		var color:Int;
		var pY:Int;
		var pX:Int;
		var jY:Int;
		var jX:Int;
		
		for (i in Std.int(health)...Std.int(health + Value))
		{
			if (i <= 25)
			{
				color = COLOR_TRUNK[FlxRandom.intRanged(0, COLOR_TRUNK.length)];
				pY = Std.int(i / 5);
				pX = Std.int(i % 5);
				if (pX == 2 && pY < 2)
					pixels.setPixel32(pX, 4 - pY, 0xff333333);
				else
					pixels.setPixel32(pX, 4 - pY, color);
			}
			else if (i <= 50)
			{
				jY = Std.int((i-26) / 5);
				jX = Std.int((i-26) % 5);
				if (!(jX == 2 && jY < 2))
					pixels.setPixel32(jX, 4 - jY, _paint);
			}
		}
		
		dirty = true;
		resetFrameBitmapDatas();
		health += Value;
		if (health > 50) health = 51;
	}
	
	
	override public function update():Void
	{
		if (_birthing)
		{
			if (_delay > 2)
			{
				// spawn some smoke
				_delay = 0;
				var s:Smoke = cast _w.lyrFX.recycle(Smoke);
				s.reset(x + width - 1, y - 3);
			}
			else
			{
				_delay += FlxG.elapsed * 4;
			}
			
			
		}
		super.update();
		
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
	
}