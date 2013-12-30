package elements;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;

class DwarfShroom extends FlxSprite
{

	private var COLOR_TRUNK:Array<Int>;
	private var COLOR_LEAF:Array<Int>;
	
	public inline static var STATUS_NORMAL:Int = 0;
	public inline static var STATUS_CUTTING:Int = 1;
	public inline static var STATUS_CUTDOWN:Int = 2;
	public inline static var STATUS_GROWING:Int = 3;
	
	private var _status:Int = 0;
	private var _age:Int = 0;
	private var _rect:FlxRect;
	private var _w:World;
	
	public function new(W:World) 
	{
		super();
		
		_w = W;
		COLOR_TRUNK = [0xffFFED9E, 0xffF0E09C];
		COLOR_LEAF = [0xffDE1B1B, 0xffDE1B1B, 0xffDE1B1B, 0xffDE1B1B, 0xffffffff];
		_age = 0;
		//buildShroom();
	}
	
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		_age = 0;
		buildShroom();
	}
	
	public function buildShroom():Void
	{
		var tHeight:Int = 4;
		var tWidth:Int = 3;
		var canvas:BitmapData = new BitmapData(tWidth, tHeight, true, 0x0);
		_rect = new FlxRect(x, y, tWidth, tHeight);
		_status = STATUS_GROWING;
		canvas.setPixel32(1, 3, COLOR_TRUNK[FlxRandom.intRanged(0, COLOR_TRUNK.length - 1)]);
		pixels = canvas.clone();
		canvas.dispose();
		dirty = true;
		resetFrameBitmapDatas();
	}
	
	public function Grow():Void
	{
		pixels.setPixel32(0, 0, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(1, 0, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(2, 0, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(0, 1, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(1, 1, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(2, 1, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length - 1)]);
		pixels.setPixel32(1, 2, COLOR_TRUNK[FlxRandom.intRanged(0, COLOR_TRUNK.length - 1)]);
		dirty = true;
		resetFrameBitmapDatas();
		_status = STATUS_NORMAL;
	}
	
	override public function update():Void 
	{
		if (_status == STATUS_GROWING)
		{
			_age += FlxRandom.intRanged(0, 1);
			if (FlxRandom.chanceRoll(_age))
			{
				Grow();
			}
		}
		super.update();
	}
	
	function get_rect():FlxRect 
	{
		return _rect;
	}
	
	public var rect(get_rect, null):FlxRect;
	
	
	
	function get_status():Int 
	{
		return _status;
	}
	
	function set_status(value:Int):Int 
	{
		return _status = value;
	}
	
	public var status(get_status, set_status):Int;
}