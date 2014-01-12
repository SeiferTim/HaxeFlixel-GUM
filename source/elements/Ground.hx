package elements;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;

class Ground
{
	private var COLOR_SNOW:Array<Int>;
	private var COLOR_STONE:Array<Int>;
	private var COLOR_DIRT:Array<Int>;
	private var COLOR_MID:Array<Int>;
	private var COLOR_DARK:Array<Int>;
	private var COLOR_GRASS:Array<Int>;
	//private var COLOR_STONE:Array<Int>;
	
	private var _groundMap:FlxSprite;
	private var _points:Array<Int>;
	
	private var _gs:PlayState;
	private var _highest:Int;
	private var _lowest:Int;
	
	
	public function new(GS:PlayState) 
	{
		_gs = GS;
		COLOR_SNOW = FlxGradient.createGradientArray(10, 10, [0xFFe4e0f7, 0xffebe9e6, 0xffeeedea, 0xfff2f6f6], 1, 90);
		COLOR_DIRT = FlxGradient.createGradientArray(20, 10, [0xFFA89467, 0xFF8A723E, 0xFF8C7F46, 0xFF8C7543], 1, 90);
		COLOR_MID = FlxGradient.createGradientArray(20, 20, [0xFF4F3710, 0xFF362914], 1, 90);
		COLOR_DARK = FlxGradient.createGradientArray(20, 20, [0xFF0F0E0C, 0xFF241E0E], 1, 90);
		COLOR_GRASS = FlxGradient.createGradientArray(20, 20, [0xff004217, 0xff5BDB42], 1, 90);
		COLOR_STONE = FlxGradient.createGradientArray(20, 20, [0xff333333,0xffcccccc], 1, 90);
		
	}
	
	public function cutGround(X:Int, Amt:Int):Void 
	{
		if (Amt < 0) return;
		for (i in _points[X]..._points[X] + Amt)
			_groundMap.pixels.setPixel32(X, i, 0x0);
		_points[X] += Amt;
		_groundMap.dirty = true;
		_groundMap.resetFrameBitmapDatas();
	}
	
	public function fillGround(X:Int, Amt:Int):Void
	{
		if (Amt < 0) return;
		for (i in _points[X] - Amt..._points[X])
			_groundMap.pixels.setPixel32(X, i, COLOR_DIRT[FlxRandom.intRanged(0,COLOR_DIRT.length-1)]);
		_points[X] -= Amt;
		_groundMap.dirty = true;
		_groundMap.resetFrameBitmapDatas();
	}
	
	public function drawStone(X:Int, Y:Int):Void
	{
		_groundMap.pixels.setPixel32(X, Y, COLOR_STONE[FlxRandom.intRanged(0, COLOR_STONE.length - 1)]);
		_groundMap.dirty = true;
		_groundMap.resetFrameBitmapDatas();
	}
	
	public function GenerateGround(Seed:Int = 0):Void
	{
		if (Seed == 0)
			FlxRandom.globalSeed = FlxRandom.int();
		else
			FlxRandom.globalSeed = Seed;
		
		var canvas:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		var y:Int = Std.int((FlxG.height / 20) * 12);
		var stY:Int = y;
		var colorsArr:Array<Int> = new Array<Int>();
		
		_points = new Array<Int>();
		
		var nY:Int = y;
		var mid:Int = Std.int((FlxG.width / 2) + FlxRandom.intRanged( Std.int( -FlxG.width * 0.1), Std.int(FlxG.width * 0.1)));
		var slope:Float;
		var hiPt:Int = FlxRandom.intRanged(20, 60);
		var loPt:Int = 0;
		var aX:Int = FlxRandom.intRanged(2, Std.int(mid * 0.25));
		var bX:Int = FlxRandom.intRanged(Std.int(mid * 1.75), Std.int(FlxG.width - 2));
		
		for (x in 0...FlxG.width)
		{
			if (x > aX && x < bX)
			{
				if (x < mid)
					slope = (x - aX) / (mid - aX);
				else
					slope = (bX - x) / (bX - mid);
			}
			else
				slope = 0;
			slope = (hiPt - stY) * slope;
			
			nY = Std.int(stY + slope);
			_points.push(nY);
			if (nY > loPt)
				loPt = nY;
		}
		
		var xE:Int;
		var xS:Int;
		var h:Int;
		var l:Int;
		
		for (i2 in 0...500)
		{
			if (FlxRandom.chanceRoll(80))
			{
				xE = FlxRandom.intRanged(10, 60);
				xS = FlxRandom.intRanged(0,FlxG.width - xE);
				
				h = FlxG.height;
				l = 0;
				
				for (x2 in xS...xS + xE)
				{
					if (_points[x2] > l) l = _points[x2];
					if (_points[x2] < h) h = _points[x2];
				}
				
				for (x3 in xS...xS + xE)
				{
					if (_points[x3] < l - 16)
						_points[x3] += 3;
					else if (_points[x3] < l - 8)
						_points[x3] += 2;
					else if (_points[x3] < l - 4)
						_points[x3] += 1;
				}
			}
			else
			{
				xE = FlxRandom.intRanged(3, 6);
				xS = FlxRandom.intRanged(0,FlxG.width);
				var yA:Int = FlxRandom.intRanged(4, 8);
				h = FlxG.height;
				l = 0;
				for (x5 in xS...xS + xE)
				{
					if (_points[x5] > l) l = _points[x5];
					if (_points[x5] < h) h = _points[x5];
				}
				for (x4 in Std.int(xS - (xE / 2))...Std.int(xS + (xE / 2)))
				{
					_points[x4] = Std.int(l - yA + (2 * FlxRandom.sign()));
				}
			}
		}
		
		hiPt = FlxG.height;
		loPt = 0;
		for (i3 in 0...FlxG.width)
		{
			if (_points[i3] < hiPt) hiPt = _points[i3];
			if (_points[i3] > loPt) loPt = _points[i3];
		}
		
		_highest = hiPt;
		_lowest = loPt;
		
		var j:Float;
		
		for (sx in 0...FlxG.width)
		{
			for (i in _points[sx]...FlxG.height)
			{
				j = ((i - hiPt) / 7) + ((i - _points[sx]) * .33);
				colorsArr = new Array<Int>();
				if (i < _points[sx] + 4 && j > 20)
					colorsArr = colorsArr.concat(COLOR_GRASS);
				else
				{
					if (j < 12)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 13)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 14)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 15)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 16)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 16)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 17)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 19)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					if (j < 20)
						colorsArr = colorsArr.concat(COLOR_SNOW);
					
					//if (j > 14 && j < 18)
					//	colorsArr = colorsArr.concat(COLOR_STONE);
					
					if (j > 14 && j < 38)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 15 && j < 39)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 16 && j < 40)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 17 && j < 41)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 18 && j < 42)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 19 && j < 43)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 20 && j < 44)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 21 && j < 45)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 22 && j < 46)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 23 && j < 47)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 24 && j < 48)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					if (j > 25 && j < 49)
						colorsArr = colorsArr.concat(COLOR_DIRT);
					
					
					
					if (j > 32 && j < 52)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 33 && j < 53)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 34 && j < 54)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 35 && j < 55)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 56)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 57)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 58)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 59)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 60)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 61)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 62)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 63)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 64)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 65)
						colorsArr = colorsArr.concat(COLOR_MID);
					if (j > 36 && j < 66)
						colorsArr = colorsArr.concat(COLOR_MID);
					
					
					if (j > 63)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 64)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 65)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 66)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 67)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 68)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 69)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 70)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 71)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 72)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 73)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 74)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 75)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 76)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 77)
						colorsArr = colorsArr.concat(COLOR_DARK);
					if (j > 78)
						colorsArr = colorsArr.concat(COLOR_DARK);
				}
				
				if (FlxRandom.chanceRoll(66))
					j += .66;
				canvas.setPixel32(sx, i, colorsArr[FlxRandom.intRanged(0,colorsArr.length - 1)]);
			}
		}
		
		_groundMap = new FlxSprite(0, 0);
		_groundMap.makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		_groundMap.cachedGraphics.destroyOnNoUse = true;
		_groundMap.pixels = canvas.clone();
		_groundMap.dirty = true;
		canvas.dispose();
		_groundMap.resetFrameBitmapDatas();
		
	}
	
	function get_lowest():Int 
	{
		return _lowest;
	}
	
	public var lowest(get_lowest, null):Int;
	
	function get_highest():Int 
	{
		return _highest;
	}
	
	public var highest(get_highest, null):Int;
	
	function get_groundMap():FlxSprite 
	{
		return _groundMap;
	}
	
	public var groundMap(get_groundMap, null):FlxSprite;
	
	function get_points():Array<Int> 
	{
		return _points;
	}
	
	public var points(get_points, null):Array<Int>;
	
}