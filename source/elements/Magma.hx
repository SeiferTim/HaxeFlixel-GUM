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

	public static var COLORS_MAGMA:Array<Int>;
	
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
		COLORS_MAGMA = FlxGradient.createGradientArray(1, 10, [0xFFFF6600, 0xFFFFD52B, 0xFFFFF700],1,90);
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
		BMD.setPixel32(X, Y, COLORS_MAGMA[FlxRandom.intRanged(0,COLORS_MAGMA.length-1)]);
	}
	
	private function CheckOkay(M:MagmaParticle):Bool
	{
		if (M.x < 0 || M.y < 0 || M.x > FlxG.width || M.y > FlxG.height)
		{
			_m.remove(M);
			return false;
		}
		else
			M.update();
		return true;
			
	}
	
	public function isEmpty(BMD:BitmapData, X:Int, Y:Int):Bool
	{
		return !CheckMPos(BMD, X, Y) && !_w.isSolid( X, Y);
	}
	
	public function update():Void
	{

		var work:BitmapData = _mSpr.pixels.clone();
		var dirChoice:Array<Int>;
		var loops:Int = 0;
		var moved:Bool = false;
		var down:Bool = false;
		
		var None:Int = 0;
		var L:Int = 1;
		var R:Int = 2;
		var DL:Int = 3;
		var DR:Int = 4;
		var D:Int = 5;

		_m.sort(ParticleSort);
		
		for (mP in _m)
		{		
			moved = false;
			if (isEmpty(work, mP.x, mP.y + 1))
			{
				moved = true;
				erasePx(work, mP.x, mP.y);
				mP.y++;
					
			}
			else
			{
				dirChoice = new Array();
				
				if (isEmpty(work, mP.x - 1, mP.y) && isEmpty(work, mP.x - 1, mP.y + 1))
					dirChoice.push(DL);
				
				if (isEmpty(work, mP.x + 1, mP.y) && isEmpty(work, mP.x + 1, mP.y + 1))
					dirChoice.push(DR);
					
				if (isEmpty(work, mP.x - 1, mP.y) && !isEmpty(work, mP.x + 1, mP.y))
					dirChoice.push(L);
					
				if (isEmpty(work, mP.x + 1, mP.y) && !isEmpty(work, mP.x - 1, mP.y))
					dirChoice.push(R);
					
				if (dirChoice.length > 0)
				{
					
					moved = true;
					erasePx(work, mP.x, mP.y);
					var choice:Int = dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
					if (choice == DR || choice == DL)
						mP.y++;
					if (choice == L || choice == DL)
						mP.x--
					else if (choice == R || choice == DR)
						mP.x++;
				}
				
			}
			if (CheckOkay(mP))
			{
				if (moved)
				{
					mP.justMoved();
					drawPx(work, mP.x, mP.y);
				}
				else
				{
					if (FlxRandom.chanceRoll(Math.floor(mP.ageSinceLastMove*CountEmpties(work,mP.x,mP.y))))
					{
						//trace('stone!');
						erasePx(work, mP.x, mP.y);
						_w.ground.drawStone(mP.x, mP.y);
						_m.remove(mP);
						
					}
					else 
					{
						
						dirChoice = new Array();
						if (_w.isSolid(mP.x, mP.y + 1))
							dirChoice.push(D);
						if (_w.isSolid(mP.x - 1, mP.y))
							dirChoice.push(L);
						if (_w.isSolid(mP.x+1, mP.y))
							dirChoice.push(R);
						if (dirChoice.length > 0)
						{
							if (FlxRandom.chanceRoll(1) && FlxRandom.chanceRoll(1))
							{
								erasePx(work, mP.x, mP.y);
								_w.MakeCave(mP.x, mP.y, World.CORIENT_P);
								_m.remove(mP);
							}
						}
						
						
					}
				}
				
			}
		}
		
		//trace(loops);
		
		_mSpr.cachedGraphics.destroyOnNoUse = true;
		_mSpr.pixels = work.clone();
		work.dispose();
		_mSpr.dirty = true;
		_mSpr.resetFrameBitmapDatas();
	}
	
	private function CountEmpties(BMD:BitmapData, X:Int, Y:Int):Int
	{
		var c:Int=0;
		if (!CheckMPos(BMD, X - 1, Y - 1)) c++;
		if (!CheckMPos(BMD, X, Y - 1)) c++;
		if (!CheckMPos(BMD, X + 1, Y - 1)) c++;
		if (!CheckMPos(BMD, X - 1, Y)) c++;
		if (!CheckMPos(BMD, X + 1, Y)) c++;
		if (!CheckMPos(BMD, X - 1, Y + 1)) c++;
		if (!CheckMPos(BMD, X , Y + 1)) c++;
		if (!CheckMPos(BMD, X - 1, Y + 1)) c++;
		return c;
	}
	
	public function spawnMagma(X:Int, Y:Int):Void
	{
		var pY:Int = 0;
		var pX:Int = 0;
		var hits:Bool = false;
		var dirChoice:Array<Int>;
		var mP:MagmaParticle;
		
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
			mP = new MagmaParticle(X, Y + pY);
			_m.push(mP);
			drawPx(_mSpr.pixels, X, Y + pY);
		}
	}
	
	function get_mSpr():FlxSprite 
	{
		return _mSpr;
	}
	
	public var mSpr(get_mSpr, null):FlxSprite;
	
}