package elements;
import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class Tree extends FlxSprite
{
	
	private var COLOR_TRUNK:Array<Int>;
	private var COLOR_LEAF:Array<Int>;
	
	public inline static var STATUS_NORMAL:Int = 0;
	public inline static var STATUS_CUTTING:Int = 1;
	public inline static var STATUS_CUTDOWN:Int = 2;
	
	private var _status:Int;
	
	private var _w:World;
	
	public function new(W:World) 
	{
		super();
		makeGraphic(0, 0, 0x0, true);
		_w = W;
		COLOR_TRUNK = [0xff5C4425, 0xff736149, 0xff8A847D, 0xff573A14];
		COLOR_LEAF = [0xff1D401A, 0xff0E380A, 0xff30A825, 0xff42753D];
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		buildTree();
	}
	
	public function buildTree():Void
	{
		var tHeight:Int = FlxRandom.intRanged(6, 40);
		var tWidth:Int = FlxRandom.intRanged(Std.int(tHeight / 5), Std.int(tHeight / 2)+1);
		var lHeight:Int = FlxRandom.intRanged(4, tHeight - 4);
		var density:Float = FlxRandom.floatRanged(0.7,0.9);
		var canvas:BitmapData = new BitmapData((tWidth * 2) + 1, tHeight + 2, true, 0x00000000);
		var tColor:Int = COLOR_TRUNK[FlxRandom.intRanged(0, COLOR_TRUNK.length)];
		
		health = lHeight * 20;
		_status = STATUS_NORMAL;
		
		for (ay in 2...tHeight)
		{
			canvas.setPixel32(tWidth +1, ay, tColor);
		}
		
		var tMid:Int = tWidth + 1;
		
		
		for (i in 0...lHeight + 2)
		{
			for (ax in 0...Std.int(canvas.width))
			{
				//FlxG.log(Math.abs(tMid - x) + " < " + Math.abs(lHeight - i * 2));
				//if (Math.abs(tMid - x) < Math.abs((lHeight/2) - (i*2)))
				//{
					if (FlxRandom.chanceRoll(Std.int(density*100)))
					{
						canvas.setPixel32(ax, i, COLOR_LEAF[FlxRandom.intRanged(0, COLOR_LEAF.length)]);
					}
				//}
			}
		}
		makeGraphic(canvas.width, canvas.height, 0x00000000);
		pixels = canvas;
		dirty = true;
	}
	
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