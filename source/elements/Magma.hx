package elements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Magma
{

	private var COLORS_MAGMA:Array<Int>;
	
	private var _w:World;
	private var _mSpr:FlxSprite;
	private var _m:Array<MagmaParticle>;
	
	
	public function new(W:World) 
	{
		_w = W;
		_m = new Array<MagmaParticle>();
		_mSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		COLORS_MAGMA = FlxGradient.createGradientArray(20, 20, [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700]);
	}
	
	public function CheckMPos(X:Int, Y:Int):Bool
	{
		return FlxColorUtil.getAlpha(_mSpr.pixels.getPixel32(X, Y)) >= 255;
	}
	
	private function ParticleSort(mA:MagmaParticle, mB:MagmaParticle):Int
	{
		if (mA.y > mB.y)
			return -1;
		else if (mA.y < mB.y)
			return 1;
		else
			return 0;
	}
	
	public function update():Void
	{
		_m.sort(ParticleSort);
		
		var mP1:FlxPoint;
		var dirChoice:Array<Int>;
		
		for (mP in _m)
		{
			mP1 = new FlxPoint(mP.x, mP.y);
			if (!CheckMPos(mP.x + 0, mP.y + 1) && !_w.isSolid(mP.x + 0, mP.y +1))
				mP.y++;
			else
			{
				dirChoice = new Array();
				if (CheckMPos(mP.x, mP.y - 1) || (CheckMPos(mP.x - 1 , mP.y - 1) && CheckMPos(mP.x - 1, mP.y)) || (CheckMPos(mP.x + 1 , mP.y - 1) && CheckMPos(mP.x + 1, mP.y)))
				{
					
					if (!CheckMPos(mP.x - 1, mP.y) && !_w.isSolid(mP.x - 1, mP.y))
						dirChoice.push( -1);
					
					if (!CheckMPos(mP.x + 1, mP.y) && !_w.isSolid(mP.x + 1, mP.y))
						dirChoice.push(1);
						
					if (dirChoice.length > 0)
					{
						mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length)];
					}
				}
				else
				{
					if (!CheckMPos(mP.x - 1, mP.y +1 ) && !_w.isSolid(mP.x - 1, mP.y +1))
						dirChoice.push( -1);
					
					if (!CheckMPos(mP.x + 1, mP.y+1) && !_w.isSolid(mP.x + 1, mP.y+1))
						dirChoice.push(1);
						
					if (dirChoice.length > 0)
					{
						mP.y++;
						mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length)];
					}
				}
			}
			_mSpr.pixels.setPixel32(Std.int(mP1.x), Std.int(mP1.y), 0x00000000);
			_mSpr.pixels.setPixel32(mP.x, mP.y, COLORS_MAGMA[FlxRandom.intRanged(0, COLORS_MAGMA.length)]);
		}
		
		
	}
	
	public function spawnMagma(X:Int, Y:Int):Void
	{
		_m.push(new MagmaParticle(X, Y));
	}
	
	function get_mSpr():FlxSprite 
	{
		return _mSpr;
	}
	
	public var mSpr(get_mSpr, null):FlxSprite;
	
}