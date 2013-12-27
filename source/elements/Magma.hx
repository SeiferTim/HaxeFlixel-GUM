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
		_mSpr.cachedGraphics.destroyOnNoUse = true;
		_mSpr.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		COLORS_MAGMA = [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700];//FlxGradient.createGradientArray(1, 10, [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700],1,90);
	}
	
	public function CheckMPos(BMD:BitmapData, X:Int, Y:Int):Bool
	{
		if (X <= 0 || X >= FlxG.width || Y <= 0 || Y >= FlxG.height) return false;
		return BMD.getPixel32(X, Y) != 0;
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
	
	private function erasePx(BMD:BitmapData,X:Int, Y:Int):Void
	{
		BMD.setPixel32(X, Y, 0x0);
	}
	
	private function drawPx(BMD:BitmapData,X,Y):Void 
	{
		BMD.setPixel32(X, Y, COLORS_MAGMA[FlxRandom.intRanged(0, COLORS_MAGMA.length-1)]);
	}
	
	private function CheckOkay(M:MagmaParticle):Bool
	{
		if (M.x < 0 || M.y < 0 || M.x > FlxG.width || M.y > FlxG.height)
		{
			_m.remove(M);
			return false;
		}
		return true;
			
	}
	
	public function update(WhileAnyMove:Bool = false):Void
	{

		var anyMoved:Bool = true;
		var work:BitmapData = _mSpr.pixels.clone();
		var dirChoice:Array<Int>;
		var loops:Int = 0;

		WhileAnyMove = false;
		
		while (anyMoved)
		{
			loops++;
			if (loops % 10 == 0)
				trace(loops);
			_m.sort(ParticleSort);
			
			for (mP in _m)
			{		

				if (!CheckMPos(work, mP.x, mP.y + 1) && !_w.isSolid( mP.x + 0, mP.y + 1))
				{
					anyMoved = true;	
					erasePx(work, mP.x, mP.y);
					mP.y++;
					if (CheckOkay(mP))
						drawPx(work, mP.x, mP.y);
						
				}
				else
				{
					dirChoice = new Array();
					
					if (CheckMPos(work, mP.x, mP.y - 1) || (CheckMPos(work, mP.x - 1 , mP.y - 1) && CheckMPos(work, mP.x - 1, mP.y)) || (CheckMPos(work, mP.x + 1 , mP.y - 1) && CheckMPos(work, mP.x + 1, mP.y)))
					{
						
						if (!CheckMPos(work, mP.x - 1, mP.y) && !_w.isSolid(mP.x - 1, mP.y))
							dirChoice.push( -1);
						
						if (!CheckMPos(work, mP.x + 1, mP.y) && !_w.isSolid(mP.x + 1, mP.y))
							dirChoice.push(1);
							
						if (dirChoice.length > 0)
						{
							anyMoved = true;	
							erasePx(work, mP.x, mP.y);
							mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
							if (CheckOkay(mP))
								drawPx(work, mP.x, mP.y);
						}
					}
					else
					{
						if (!CheckMPos(_mSpr.pixels, mP.x - 1, mP.y +1 ) && !_w.isSolid(mP.x - 1, mP.y +1))
							dirChoice.push( -1);
						
						if (!CheckMPos(_mSpr.pixels, mP.x + 1, mP.y + 1) && !_w.isSolid(mP.x + 1, mP.y + 1))
							dirChoice.push(1);
							
						if (dirChoice.length > 0)
						{
							anyMoved = true;	
							erasePx(work, mP.x, mP.y);
							mP.y++;
							mP.x += dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
							if (CheckOkay(mP))
								drawPx(work, mP.x, mP.y);
						}
					}
					
				}
			}
			
			if (!WhileAnyMove) anyMoved = false;
			
		}
		
		trace(loops);
		
		_mSpr.cachedGraphics.destroyOnNoUse = true;
		_mSpr.pixels = work.clone();
		work.dispose();
		_mSpr.dirty = true;
		_mSpr.resetFrameBitmapDatas();
		
		
		
	}
	
	public function spawnMagma(X:Int, Y:Int):Void
	{
		var pY:Int = 0;
		var pX:Int = 0;
		var hits:Bool = false;
		var dirChoice:Array<Int>;
		
		while(!hits && Y+pY+1 < FlxG.height)
		{
			if (!_w.isSolid(X, Y + pY + 1) && !CheckMPos(_mSpr.pixels, X, Y + pY + 1))
			{
				pY++;
			}
			else
			{
				hits = true;
			}
		}
		
		if (hits)
		{	
			_m.push(new MagmaParticle(X, Y+pY));
			drawPx(_mSpr.pixels, X, Y + pY);
		}
	}
	
	function get_mSpr():FlxSprite 
	{
		return _mSpr;
	}
	
	public var mSpr(get_mSpr, null):FlxSprite;
	
}