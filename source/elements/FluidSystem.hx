package elements;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import haxe.macro.Expr.Function;

class FluidSystem
{

	public var COLORS:Array<Int>;
	
	private var _w:World;
	private var _fSpr:FlxSprite;
	private var _f:Array<FluidParticle>;
	private var _onParticleUpdate:Dynamic;
	
	private var _gravity:Int;
	
	private var None:Int = 0;
	private var L:Int = 1;
	private var R:Int = 2;
	private var DL:Int = 3;
	private var DR:Int = 4;
	private var D:Int = 5;
	
	private var _work:BitmapData;
	
	public function new(W:World, Colors:Array<Int>, OnParticleUpdate:Dynamic=null, GravityDir:Int = 1) 
	{
		_w = W;
		_f = new Array<FluidParticle>();
		_fSpr = new FlxSprite();
		_fSpr.cachedGraphics.destroyOnNoUse = true;
		_fSpr.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		COLORS = Colors;
		_onParticleUpdate = OnParticleUpdate;
		_gravity = GravityDir;
	}
	public function CheckPos(BMD:BitmapData, X:Int, Y:Int):Bool
	{
		if (X <= 0 || X >= FlxG.width || Y <= 0 || Y >= FlxG.height) return false;
		return BMD.getPixel32(X, Y) != 0;
	}
	
	private function ParticleSort(fA:FluidParticle, fB:FluidParticle):Int
	{
		if (fA.y > fB.y)
			return -_gravity;
		else if (fA.y < fB.y)
			return _gravity;
		else
			return 0;
	}
	
	private function erasePx(BMD:BitmapData,X:Int, Y:Int):Void
	{
		BMD.setPixel32(X, Y, 0x0);
		
	}
	
	private function drawPx(BMD:BitmapData,X,Y):Void 
	{
		BMD.setPixel32(X, Y, COLORS[FlxRandom.intRanged(0, COLORS.length - 1)]);
	}
	
	private function CheckOkay(F:FluidParticle):Bool
	{
		if (F.x < 0 || F.y < 0 || F.x > FlxG.width || F.y > FlxG.height)
		{
			_f.remove(F);
			return false;
		}
		else
			F.update();
		return true;
			
	}
	
	public function isEmpty(BMD:BitmapData, X:Int, Y:Int):Bool
	{
		return !CheckPos(BMD, X, Y) && !_w.isSolid( X, Y);
	}
	
	public function update():Void
	{

		_work = new BitmapData(FlxG.width, FlxG.height, true, 0x0);//_fSpr.pixels.clone();
		var dirChoice:Array<Int>;
		var loops:Int = 0;
		var moved:Bool = false;
		var down:Bool = false;
		
		

		_f.sort(ParticleSort);
		
		for (fP in _f)
		{		
			moved = false;
			if (isEmpty(_work, fP.x, fP.y + _gravity))
			{
				moved = true;
				//erasePx(_work, fP.x, fP.y);
				fP.y += _gravity;
					
			}
			else
			{
				dirChoice = new Array();
				
				if (isEmpty(_work, fP.x - 1, fP.y) && isEmpty(_work, fP.x - 1, fP.y + _gravity))
					dirChoice.push(DL);
				
				if (isEmpty(_work, fP.x + 1, fP.y) && isEmpty(_work, fP.x + 1, fP.y + _gravity))
					dirChoice.push(DR);
					
				if (isEmpty(_work, fP.x - 1, fP.y) && !isEmpty(_work, fP.x + 1, fP.y))
					dirChoice.push(L);
					
				if (isEmpty(_work, fP.x + 1, fP.y) && !isEmpty(_work, fP.x - 1, fP.y))
					dirChoice.push(R);
					
				if (dirChoice.length > 0)
				{
					
					moved = true;
					//erasePx(_work, fP.x, fP.y);
					var choice:Int = dirChoice[FlxRandom.intRanged(0, dirChoice.length - 1)];
					if (choice == DR || choice == DL)
						fP.y+=_gravity;
					if (choice == L || choice == DL)
						fP.x--
					else if (choice == R || choice == DR)
						fP.x++;
				}
				
			}
			if (CheckOkay(fP))
			{
				if (moved)
				{
					fP.justMoved();
					
				}
				drawPx(_work, fP.x, fP.y);
			}
		}
		
		//trace(loops);
		
		_fSpr.cachedGraphics.destroyOnNoUse = true;
		_fSpr.pixels = _work.clone();
		_work.dispose();
		_fSpr.dirty = true;
		_fSpr.resetFrameBitmapDatas();
	}
	
	private function CountEmpties(BMD:BitmapData, X:Int, Y:Int):Int
	{
		var c:Int=0;
		if (!CheckPos(BMD, X - 1, Y - 1)) c++;
		if (!CheckPos(BMD, X, Y - 1)) c++;
		if (!CheckPos(BMD, X + 1, Y - 1)) c++;
		if (!CheckPos(BMD, X - 1, Y)) c++;
		if (!CheckPos(BMD, X + 1, Y)) c++;
		if (!CheckPos(BMD, X - 1, Y + 1)) c++;
		if (!CheckPos(BMD, X , Y + 1)) c++;
		if (!CheckPos(BMD, X - 1, Y + 1)) c++;
		return c;
	}
	
	public function spawnFluid(X:Int, Y:Int):Void
	{
		var pY:Int = 0;
		var pX:Int = 0;
		var hits:Bool = false;
		var dirChoice:Array<Int>;
		var fP:FluidParticle;
		
		while (!hits && Y + pY + 1 < FlxG.height)
		{
			if (!_w.isSolid(X, Y + pY + 1) && !CheckPos(_fSpr.pixels, X, Y + pY + 1))
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
			fP = new FluidParticle(X, Y + pY, _onParticleUpdate);
			_f.push(fP);
			drawPx(_fSpr.pixels, X, Y + pY);
		}
	}
	
	function killAtPos(X:Int, Y:Int):Void
	{
		for (p in _f)
		{
			if (p.x == X && p.y == Y)
			{
				_f.remove(p);
				break;
			}
		}
	}
	
	function get_fSpr():FlxSprite 
	{
		return _fSpr;
	}
	
	public var fSpr(get_fSpr, null):FlxSprite;
	
	function get_f():Array<FluidParticle> 
	{
		return _f;
	}
	
	public var f(get_f, null):Array<FluidParticle>;
}