package elements;
import flash.display.BitmapData;
import flash.geom.Rectangle;
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
	private var oneTime:Bool = false;
	
	public function new(W:World) 
	{
		_w = W;
		_m = new Array<MagmaParticle>();
		_mSpr = new FlxSprite();// .makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		_mSpr.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		COLORS_MAGMA = [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700];//FlxGradient.createGradientArray(1, 10, [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700],1,90);
	}
	
	public function CheckMPos(X:Int, Y:Int):Bool
	{
		if (X <= 0 || X >= FlxG.width || Y <= 0 || Y >= FlxG.height) return false;
		return _mSpr.pixels.getPixel32(X, Y) != 0;
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
	
	public function update():Bool
	{

		var anyMoved:Bool = false;
		
		var tmp:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		
		_m.sort(ParticleSort);
		
		//var mP1:FlxPoint;
		var dirChoice:Array<Int>;
		//trace(_m.length);
		for (mP in _m)
		{
			//mP1 = new FlxPoint(mP.x, mP.y);
			
			if (!CheckMPos(mP.x, mP.y + 1) && !_w.isSolid(mP.x + 0, mP.y +1))
			{
				
					mP.y++;
					anyMoved = true;
			}
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
						mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
						anyMoved = true;
					}
				}
				else
				{
					if (!CheckMPos(mP.x - 1, mP.y +1 ) && !_w.isSolid(mP.x - 1, mP.y +1))
						dirChoice.push( -1);
					
					if (!CheckMPos(mP.x + 1, mP.y + 1) && !_w.isSolid(mP.x + 1, mP.y + 1))
						dirChoice.push(1);
						
					if (dirChoice.length > 0)
					{
						mP.y++;
						mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
						anyMoved = true;
					}
				}
				
			}
		}
		
		//_mSpr.pixels.fillRect(new Rectangle(0, 0, _mSpr.pixels.width, _mSpr.pixels.height), 0x0);
		
		
		
		for (mP in _m)
		{
			if (mP.x > FlxG.width || mP.x < 0 || mP.y > FlxG.height || mP.y < 0)
			{	
				_m.remove(mP);
			}
			else 
			{
				tmp.setPixel32(mP.x, mP.y, COLORS_MAGMA[FlxRandom.intRanged(0, COLORS_MAGMA.length-1)]);
			}
			
		}
		_mSpr.pixels = tmp.clone();
		tmp.dispose();
		_mSpr.dirty = true;
		_mSpr.resetFrameBitmapDatas();
		return anyMoved;
		
		
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