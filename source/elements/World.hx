package elements;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;

class World
{
	
	public inline static var CORIENT_D:UInt = 0;
	public inline static var CORIENT_U:UInt = 1;
	public inline static var CORIENT_R:UInt = 2;
	public inline static var CORIENT_L:UInt = 3;
	public inline static var CORIENT_P:UInt = 4;
	
	private var _ground:Ground;
	private var _magma:Magma;
	
	private var _guys:Array<Guy>;
	private var _dwarfs:Array<Dwarf>;
	private var _trees:Array<Tree>;
	private var _houses:Array<House>;
	private var _dHouses:Array<DwarfHouse>;
	
	private var _sky:FlxSprite;
	private var _lyrTrees:FlxGroup;
	private var _lyrHouses:FlxGroup;
	private var _lyrDHouses:FlxGroup;
	private var _caves:FlxSprite;
	private var _lyrFX:FlxGroup;
	private var _lyrGuys:FlxSprite;
	private var _lyrDwarfs:FlxSprite;
	private var _lyrMagma:FlxSprite;
	private var _dRooms:FlxSprite;
	private var _lyrShrooms:FlxGroup;
	private var _dwarfRooms:Array<DwarfRoom>;
	
	private var COLOR_CMID:Array<Int>;
	private var COLOR_DIRT:Array<Int>;
	
	private var _humanWood:Int;
	private var _humanFood:Int;
	private var _humanPop:Int;
	
	private var _dwarfOre:Int;
	private var _dwarfFood:Int;
	private var _dwarfPop:Int;
	
	private var _gs:PlayState;
	
	
	

	public function new(GS:PlayState) 
	{
		_gs = GS;
		
		COLOR_CMID = FlxGradient.createGradientArray(20, 20, [0x990F0E0C, 0x99241E0E], 1, 90);
		COLOR_DIRT = FlxGradient.createGradientArray(20, 20, [0xFF4F3710, 0xFF362914], 1, 90);
		
		_humanWood = 0;
		_humanFood = 2000;
		
		_lyrFX = new FlxGroup();
		_lyrHouses = new FlxGroup();
		_lyrDHouses = new FlxGroup();
		_lyrTrees = new FlxGroup();
		_lyrGuys = new FlxSprite();
		_lyrDwarfs = new FlxSprite();
		_lyrShrooms = new FlxGroup();
		_sky = new FlxSprite();
		_dRooms = new FlxSprite();
		_dwarfRooms = new Array<DwarfRoom>();
		_magma = new Magma(this);
		_lyrMagma = _magma.mSpr;
		_dwarfFood = 2000;
		_dwarfOre = 0;

	}
	
	public function MakeSky():Void
	{
		_sky = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff415587, 0xff7784b1]);
	}
	
	public function updateDwarfs():Void
	{
		_dwarfPop = 0;
		_lyrDwarfs.pixels.fillRect(new Rectangle(0, 0, _lyrDwarfs.pixels.width, _lyrDwarfs.pixels.height), 0x0); //= new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		for (d in _dwarfs)
		{
			if (d.life > 0)
			{
				_dwarfPop++;
				d.update();
				_lyrDwarfs.pixels.setPixel32(Std.int(d.pos.x), Std.int(d.pos.y), Dwarf.COLOR_DWARF);
			}
		}
		_lyrDwarfs.dirty = true;
		_lyrDwarfs.resetFrameBitmapDatas();
	}
	
	public function updateGuys():Void
	{
		_humanPop = 0;
		_lyrGuys.pixels.fillRect(new Rectangle(0, 0, _lyrGuys.pixels.width, _lyrGuys.pixels.height), 0x0);// = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		for (g in guys)
		{
			if (g.life > 0)
			{
				_humanPop++;
				g.update();
				if (!g.atHome)
				{
					if (!g.underground)
						_lyrGuys.pixels.setPixel32(Std.int(g.pos.x), Std.int(ground.points[Std.int(g.pos.x)] - 1), Guy.COLOR_HUMAN);
					else
						_lyrGuys.pixels.setPixel32(Std.int(g.pos.x), Std.int(g.pos.y), Guy.COLOR_HUMAN);
				}
			}
		}
		_lyrGuys.dirty = true;
		_lyrGuys.resetFrameBitmapDatas();
	}
	
	public function update():Void
	{
		updateDwarfs();
		updateGuys();
		_magma.update();
	}
	
	public function MakeGround():Void
	{
		_ground = new Ground(_gs);
		
		_ground.GenerateGround();
	}
	
	public function isBMDSolid(BMD:BitmapData, X:Int, Y:Int):Bool
	{
		if (X <=0 || X>= FlxG.width || Y <= 0 || Y >= FlxG.height) return false;
		var a:UInt =  FlxColorUtil.getAlpha(BMD.getPixel32(X, Y));
		return a < 50 || a > 200;
	}
	
	public function isSolid(X:Int, Y:Int):Bool
	{
		if (X <=0 || X>= FlxG.width || Y <= 0 || Y >= FlxG.height) return false;
		var a:UInt =  FlxColorUtil.getAlpha(_caves.pixels.getPixel32(X, Y));
		return a < 50 || a > 200;
	}
	
	public function populateCaves():Void
	{
		_caves = new FlxSprite(0, 0);// .makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		_caves.cachedGraphics.destroyOnNoUse = true;
		_caves.pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		_caves.dirty = true;
		var cX:Int;
		var cY:Int;
		/*
		var rX:Int;
		var rY:Int;
		var hasM:Bool;
		var checks:Int;
		var dirX:Int;
		var dirY:Int;
		var chanceX:Int;
		var chanceY:Int;
		
		for (cCnt in 0...FlxRandom.intRanged(10, 100))
		{
			cX = FlxRandom.intRanged(0,FlxG.width);
			cY = FlxRandom.intRanged(_ground.points[cX] + 10, FlxG.height -10);
			
			rX = cX;
			rY = cY;
			
			hasM = FlxRandom.chanceRoll(Std.int(((rY / 2) / FlxG.height) * 100));
			
			for (cT in 0...FlxRandom.intRanged(200, 400))
			{
				MakeCave(rX, rY, CORIENT_P);
				if (hasM && FlxRandom.chanceRoll())
				{
					_magma.spawnMagma(rX, rY);
				}
				
				checks = 0;
				while (!isSolid(rX, rY) && checks < 100)
				{
					checks++;
					if (FlxRandom.chanceRoll(10))
					{
						rX = cX;
						rY = cY;
					}
					if (FlxRandom.chanceRoll())
						rX += Std.int(FlxRandom.sign());
					else
						rY += Std.int(FlxRandom.sign());
				}
			}
		}
		*/
		
		GenerateNoiseCaves();
		
		var c:BitmapData = _caves.pixels.clone();
		for (cCnt in 0...3)//FlxRandom.intRanged(2, 10))
		{
			cX = FlxRandom.intRanged(0, FlxG.width);
			c = drawCaveCrack(c, cX, FlxRandom.intRanged(_ground.points[cX] + 10, FlxG.height -10));
		}
		
		_caves.cachedGraphics.destroyOnNoUse = true;
		_caves.pixels = c.clone();
		c.dispose();
		AddMagma();
		
		//var anyMoved:Bool = true;
		
		//while (anyMoved)
		//	anyMoved = _magma.update();
		_magma.update();
		_caves.resetFrameBitmapDatas();
	}
	
	private function AddMagma():Void 
	{
		//var gradient_v:BitmapData = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0x0, 0x0, 0xff000000, 0xff000000, 0xff000000], 1, 90, true);
		//FlxGradient.overlayGradientOnBitmapData(gradient_v, FlxG.width, FlxG.height, [0x0, 0xff000000, 0x0], 0, 0, 1, 0, true);
		
		//var invertTransform:ColorTransform = new ColorTransform( -1, -1, -1, -1, 255, 255, 255, 255);
		//gradient_v.colorTransform(gradient_v.rect, invertTransform);
		//var gradient_v:BitmapData = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0x0,0x0, 0xff000000, 0xff000000, 0x0,0x0], 1, 0, true);
		
		var gradient_v:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		gradient_v.copyChannel(_ground.groundMap.pixels, _ground.groundMap.pixels.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE);
		gradient_v.applyFilter(gradient_v, gradient_v.rect, new Point(), new BlurFilter(64,64, 1));
		var gradient_v:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		var cTransform:ColorTransform = new ColorTransform(255,255,255,1,0,0,0,0);
		
		
		gradient_v = _ground.groundMap.pixels.clone();
		gradient_v.colorTransform(gradient_v.rect, cTransform);
		
		//.copyChannel(_world.ground.groundMap.pixels, _world.ground.groundMap.pixels.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE);
		
		gradient_v.applyFilter(gradient_v, gradient_v.rect, new Point(), new BlurFilter(128,128, 1));		
		
		
		
		var noise:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		noise.perlinNoise(FlxG.width/2, FlxG.height/2, 4, FlxRandom.int(), false, true, BitmapDataChannel.ALPHA, true);
		noise.merge(gradient_v, gradient_v.rect, new Point(0, 0), 0x60, 0x60, 0x60, 0x255);
		
		for (nX in 0...noise.width)
		{
			for (nY in _ground.points[nX]...noise.height)
			{
				if (!isSolid(nX,nY))
				{
					if (FlxColorUtil.getAlpha(noise.getPixel32(nX, nY)) > 120)
					{
						_magma.spawnMagma(nX, nY);
					}
				}
			}
		}
		gradient_v.dispose();
		//gradient_h.dispose();
		noise.dispose();
		
	}
	
	private function GenerateNoiseCaves():Void
	{
		var c:BitmapData = _caves.pixels.clone();
		var gradient:BitmapData = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xff000000, 0x88000000,0x33000000 ], 1, 90, false);
		
		var noise:BitmapData;
		
		for (i in 0...FlxRandom.intRanged(3,4))
		{
			noise = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
			noise.perlinNoise(FlxG.width/3, FlxG.height/3, 10, FlxRandom.int(), false, false, BitmapDataChannel.ALPHA, true);
			noise.merge(gradient, gradient.rect, new Point(0, 0), 70, 70, 70, 70);
			
			
			for (nX in 0...noise.width)
			{
				for (nY in _ground.points[nX]...noise.height)
				{
					if (FlxColorUtil.getAlpha(noise.getPixel32(nX, nY)) < 50 )
					{
						c = DrawCaveP(c, nX, nY);
					}
				}
			}
			noise.dispose();
		}
		_caves.cachedGraphics.destroyOnNoUse = true;
		_caves.pixels = c.clone();
		c.dispose();
		gradient.dispose();
		_caves.resetFrameBitmapDatas();
		
		
	}
	
	private function drawCaveCrack(BMD:BitmapData, StartX:Int, StartY:Int, Level:Int = 0):BitmapData
	{
			var rX:Int = StartX;
			var rY:Int = StartY;
			var dirX:Int = Std.int(FlxRandom.sign());
			var dirY:Int = Std.int(FlxRandom.sign());
			var chanceX:Int = FlxRandom.intRanged(10, 90);
			var chanceY:Int = FlxRandom.intRanged(10, 90);
			var checks:Int = 0;
			var height:Int = 1;// FlxRandom.intRanged(1, 20 - Level);
			var width:Int = 1;// FlxRandom.intRanged(1, 20 - Level);
			var branchTicks:Int = 25 * Level;
			
			var c:BitmapData = BMD;
			
			var loops:Int = FlxRandom.intRanged(50, 150);
			
			for (cT in 0...loops)
			{
				for (Y in rY-Std.int(Math.ceil(height/2))...rY+Std.int(Math.floor(height/2)))
				{
					for (X in rX-Std.int(Math.ceil(width/2))...rX+Std.int(Math.floor(width/2)))
					{
						if (X >= 0 && Y >= _ground.points[X] && Y <= FlxG.height && X <= FlxG.width)
						{
							if (isSolid(X, Y))
							{
								c = DrawCaveP(c, X, Y);
								//MakeCave(X, Y, CORIENT_P);
								//if (FlxRandom.chanceRoll(Std.int((rY)/(FlxG.height/4)) * 100) && FlxRandom.chanceRoll(60))
								//	_magma.spawnMagma(X, Y);
								
							}
						}
					}
				}
				if (branchTicks <= 0)
				{
					
					if (FlxRandom.chanceRoll(Std.int(FlxMath.bound(5 - Level, 1, 5))))
					{
						if(FlxRandom.chanceRoll(30))
						{
							c = drawCaveCrack(c,rX, rY, Level + 1);
							branchTicks = 25 * Level;
						}
						
					}
					
				}
				else
					branchTicks--;
				//checks = 0;
				//while (!isSolid(rX, rY) && checks < 100)
				//{
				//	checks++;
					if (FlxRandom.chanceRoll(chanceX))
						rX += dirX;
					if (FlxRandom.chanceRoll(chanceY))
						rY += dirY;
					
					if (FlxRandom.chanceRoll(10))
						width += Std.int(FlxRandom.sign());

					width = Std.int(FlxMath.bound(width, 1, FlxMath.bound(10 - Level, 1, (loops - cT) / 4)));
					
					if (FlxRandom.chanceRoll(10))
						height += Std.int(FlxRandom.sign());

					height = Std.int(FlxMath.bound(height, 1, FlxMath.bound(10 - Level, 1, (loops - cT) / 4)));

					
				//}
			}
			return c;
	}
	
	public function populateDwarfs():Void
	{
		_dRooms = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		_dwarfs = new Array<Dwarf>();
		_lyrDwarfs = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x0, true);
		var dX:Int = FlxRandom.intRanged(5, FlxG.width - 30);
		var dY:Int = FlxRandom.intRanged(_ground.points[dX] + 20, FlxG.height - 10);
		dY += 10 - (dY % 10);
		
		var dH:Int = FlxRandom.intRanged(2, 4) * 5;
		var dW:Int = FlxRandom.intRanged(1, 4) * 5;
		
		for (X in dX...dX + dW)
		{
			for (Y in dY...dY + dH)
			{
				MakeCave(X, Y, CORIENT_P);
				if (FlxRandom.chanceRoll(5))
					dwarfOre += FlxRandom.intRanged(1, 4);
			}
		}
		
		_dRooms.pixels.fillRect(new Rectangle(dX, dY, dW, dH), 0xffff0000);
		_dRooms.dirty = true;
		_dRooms.resetFrameBitmapDatas();
		
		for (dC in 0...FlxRandom.intRanged(5,15))
		{
			SpawnDwarf(Std.int(dX + (dW / 2)), Std.int(dY + dH - 1));
		}
	}
	
	public function giveDOre():Void 
	{
		if (FlxRandom.chanceRoll(20))
			_dwarfOre += FlxRandom.intRanged(1, 4);
	}
	
	public function populateHouses():Void
	{
		_houses = new Array<House>();
		_dHouses = new Array<DwarfHouse>();
		
	}
	
	public function populateHumans():Void
	{
		_lyrGuys = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x0,true);
		_guys = new Array<Guy>();
		var pos:Int = FlxRandom.intRanged(20, FlxG.width - 20);
		for (i in 0...FlxRandom.intRanged(4, 8))
			SpawnGuy(pos);
	}
	
	public function SpawnDwarf(X:Int, Y:Int):Void 
	{
		_dwarfs.push(new Dwarf(this).spawn(X, Y));
	}
	
	public function SpawnGuy(X:Int):Void 
	{
		_guys.push(new Guy(this).spawn(X, _ground.points[Std.int(FlxG.width / 2)] - 1));
	}
	
	public function populateTrees():Void 
	{
		_trees = new Array<Tree>();
		
		var treeNo:Int = FlxRandom.intRanged(Std.int(0.2 * FlxG.width), Std.int(0.5 * FlxG.width));
		var t:Tree;
		var tX:Int;
		for (j in 0...treeNo)
		{
			tX = FlxRandom.intRanged(0,FlxG.width);
			if (FlxRandom.chanceRoll(Std.int(((_ground.points[tX] - _ground.highest - 10) / (_ground.lowest - _ground.highest + 10))*100)))
			{
				t = new Tree(this);
				t.x = tX - (t.width / 2);
				t.y = _ground.points[tX] - t.height +2;
				_trees.push(t);
				_lyrTrees.add(t);
			}
		}
	}
	
	public function MakeCave(X:Int, Y:Int, Orient:UInt = 0, DoReset:Bool = true ):Void
	{
		
		var tmp:BitmapData;// = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
		//trace(_caves.pixels == null);
		tmp = _caves.pixels.clone();
		
		switch(Orient)
		{
			case CORIENT_D:
				X -= 2;
				Y += 1;
				if (isSolid(X, Y) && _ground.points[X] < Y)
					tmp.setPixel32(X, Y, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (_ground.points[X+1]< Y+0)
					tmp.setPixel32(X + 1, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+2]< Y+0)
					tmp.setPixel32(X + 2, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X + 3] > Y + 0)
					tmp.setPixel32(X + 3, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (isSolid(X + 4, Y) && _ground.points[X + 4] < Y + 0)
					tmp.setPixel32(X + 4, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X, Y + 1) && _ground.points[X + 0] < Y + 1)
					tmp.setPixel32(X + 0, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 1) && _ground.points[X + 1] < Y + 1)
					tmp.setPixel32(X + 1, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 2, Y + 1) && _ground.points[X + 2] < Y + 1)
					tmp.setPixel32(X + 2, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 3, Y + 1) && _ground.points[X + 3] < Y + 1)
					tmp.setPixel32(X + 3, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 4, Y + 1) && _ground.points[X + 4] < Y + 1)
					tmp.setPixel32(X + 4, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
			case CORIENT_U:
				X -= 2;
				Y -= 1;
				if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
					tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (_ground.points[X+1]< Y+0)
					tmp.setPixel32(X + 1, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+2]< Y+0)
					tmp.setPixel32(X + 2, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+3]< Y+0)
					tmp.setPixel32(X + 3, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (isSolid(X + 4, Y + 0) && _ground.points[X+4]< Y+0)
					tmp.setPixel32(X + 4, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 0, Y - 1) && _ground.points[X+0]< Y-1)
					tmp.setPixel32(X + 0, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y - 1) && _ground.points[X+2]< Y-1)
					tmp.setPixel32(X + 1, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 2, Y - 1) && _ground.points[X+3]< Y-1)
					tmp.setPixel32(X + 2, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 3, Y - 1) && _ground.points[X+4]< Y-1)
					tmp.setPixel32(X + 3, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 4, Y - 1) && _ground.points[X+5]< Y-1)
					tmp.setPixel32(X + 4, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
			case CORIENT_R:
				Y -= 2;
				X += 1;
				if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
					tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (_ground.points[X+0]< Y+1)
					tmp.setPixel32(X + 0, Y + 1, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+0]< Y+2)
					tmp.setPixel32(X + 0, Y + 2, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+0]< Y+3)
					tmp.setPixel32(X + 0, Y + 3, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (isSolid(X + 0, Y + 4) && _ground.points[X+0]< Y+4)
					tmp.setPixel32(X + 0, Y + 4, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 0) && _ground.points[X+1]< Y+0)
					tmp.setPixel32(X + 1, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 1) && _ground.points[X+1]< Y+1)
					tmp.setPixel32(X + 1, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 2) && _ground.points[X+1]< Y+2)
					tmp.setPixel32(X + 1, Y + 2, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 3) && _ground.points[X+1]< Y+3)
					tmp.setPixel32(X + 1, Y + 3, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X + 1, Y + 4) && _ground.points[X+1]< Y+4)
					tmp.setPixel32(X + 1, Y + 4, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
			case CORIENT_L:
				Y -= 2;
				X -= 1;
				if (isSolid(X + 0, Y + 0) && _ground.points[X+0]< Y+0)
					tmp.setPixel32(X + 0, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (_ground.points[X+0]< Y+1)
					tmp.setPixel32(X + 0, Y + 1, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+0]< Y+2)
					tmp.setPixel32(X + 0, Y + 2, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (_ground.points[X+0]< Y+3)
					tmp.setPixel32(X + 0, Y + 3, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
				if (isSolid(X + 0, Y + 4) && _ground.points[X+0]< Y+4)
					tmp.setPixel32(X + 0, Y + 4, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X - 1, Y + 0) && _ground.points[X+0]< Y+0)
					tmp.setPixel32(X - 1, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X - 1, Y + 1)&& _ground.points[X-1]< Y+1)
					tmp.setPixel32(X - 1, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X - 1, Y + 2)&& _ground.points[X-1]< Y+2)
					tmp.setPixel32(X - 1, Y + 2, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X - 1, Y + 3)&& _ground.points[X-1]< Y+3)
					tmp.setPixel32(X - 1, Y + 3, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
				if (isSolid(X - 1, Y + 4)&& _ground.points[X-1]< Y+4)
					tmp.setPixel32(X - 1, Y + 4, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
			case CORIENT_P:
				// A cave in a specific point, for random caves mostly
				tmp = DrawCaveP(tmp, X, Y);
				
		}
		_caves.cachedGraphics.destroyOnNoUse = true;
		_caves.pixels = tmp.clone();
		tmp.dispose();
		_caves.dirty = true;
		if (DoReset)
			_caves.resetFrameBitmapDatas();
	}
	
	private function DrawCaveP(BMD:BitmapData, X:Int, Y:Int):BitmapData
	{
		if (_ground.points[X + 0] < Y + 0)
			BMD.setPixel32(X + 0, Y + 0, COLOR_CMID[FlxRandom.intRanged(0, COLOR_CMID.length-1)]);
		if (isBMDSolid(BMD, X - 1, Y - 1) && _ground.points[X - 1] < Y - 1)
			BMD.setPixel32(X - 1, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X + 0, Y - 1) && _ground.points[X +0] < Y - 1)
			BMD.setPixel32(X + 0, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X + 1, Y - 1) && _ground.points[X + 1] < Y - 1)
			BMD.setPixel32(X + 1, Y - 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X - 1, Y + 0) && _ground.points[X - 1] < Y + 0)
			BMD.setPixel32(X - 1, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X + 1, Y + 0) && _ground.points[X + 1] < Y + 0)
			BMD.setPixel32(X + 1, Y + 0, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X - 1, Y + 1) && _ground.points[X - 1] < Y + 1)
			BMD.setPixel32(X - 1, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X + 0, Y + 1) && _ground.points[X + 0] < Y + 1)
			BMD.setPixel32(X + 0, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length-1)]);
		if (isBMDSolid(BMD, X + 1, Y + 1) && _ground.points[X + 1] < Y + 1)
			BMD.setPixel32(X + 1, Y + 1, COLOR_DIRT[FlxRandom.intRanged(0, COLOR_DIRT.length - 1)]);
		return BMD;
	}
	
	function get_dRooms():FlxSprite 
	{
		return _dRooms;
	}
	
	public var dRooms(get_dRooms, null):FlxSprite;
	
	function get_lyrDHouses():FlxGroup 
	{
		return _lyrDHouses;
	}
	
	public var lyrDHouses(get_lyrDHouses, null):FlxGroup;
	
	function get_lyrMagma():FlxSprite 
	{
		return _lyrMagma;
	}
	
	public var lyrMagma(get_lyrMagma, null):FlxSprite;
	
	function get_lyrDwarfs():FlxSprite 
	{
		return _lyrDwarfs;
	}
	
	public var lyrDwarfs(get_lyrDwarfs, null):FlxSprite;
	
	function get_lyrGuys():FlxSprite 
	{
		return _lyrGuys;
	}
	
	public var lyrGuys(get_lyrGuys, null):FlxSprite;
	
	function get_sky():FlxSprite 
	{
		return _sky;
	}
	
	public var sky(get_sky, null):FlxSprite;
	
	function get_caves():FlxSprite 
	{
		return _caves;
	}
	
	public var caves(get_caves, null):FlxSprite;
	
	function get_lyrFX():FlxGroup 
	{
		return _lyrFX;
	}
	
	public var lyrFX(get_lyrFX, null):FlxGroup;
	
	function get_lyrHouses():FlxGroup 
	{
		return _lyrHouses;
	}
	
	public var lyrHouses(get_lyrHouses, null):FlxGroup;
	
	function get_dHouses():Array<DwarfHouse> 
	{
		return _dHouses;
	}
	
	public var dHouses(get_dHouses, null):Array<DwarfHouse>;
	
	function get_houses():Array<House> 
	{
		return _houses;
	}
	
	public var houses(get_houses, null):Array<House>;
	
	function get_lyrTrees():FlxGroup 
	{
		return _lyrTrees;
	}
	
	public var lyrTrees(get_lyrTrees, null):FlxGroup;
	
	function get_trees():Array<Tree> 
	{
		return _trees;
	}
	
	public var trees(get_trees, null):Array<Tree>;
	
	function get_ground():Ground 
	{
		return _ground;
	}
	
	public var ground(get_ground, null):Ground;
	
	function get_guys():Array<Guy> 
	{
		return _guys;
	}
	
	public var guys(get_guys, null):Array<Guy>;
	
	function get_humanWood():Int 
	{
		return _humanWood;
	}
	
	function set_humanWood(value:Int):Int 
	{
		return _humanWood = value;
	}
	
	public var humanWood(get_humanWood, set_humanWood):Int;
	
	function get_humanFood():Int 
	{
		return _humanFood;
	}
	
	function set_humanFood(value:Int):Int 
	{
		return _humanFood = value;
	}
	
	public var humanFood(get_humanFood, set_humanFood):Int;
	
	function get_humanPop():Int 
	{
		return _humanPop;
	}
	
	public var humanPop(get_humanPop, null):Int;
	
	function get_dwarfOre():Int 
	{
		return _dwarfOre;
	}
	
	function set_dwarfOre(value:Int):Int 
	{
		return _dwarfOre = value;
	}
	
	public var dwarfOre(get_dwarfOre, set_dwarfOre):Int;
	
	function get_dwarfFood():Int 
	{
		return _dwarfFood;
	}
	
	function set_dwarfFood(value:Int):Int 
	{
		return _dwarfFood = value;
	}
	
	public var dwarfFood(get_dwarfFood, set_dwarfFood):Int;
	
	function get_dwarfPop():Int 
	{
		return _dwarfPop;
	}
	
	public var dwarfPop(get_dwarfPop, null):Int;
	
	function get_dwarfRooms():Array<DwarfRoom> 
	{
		return _dwarfRooms;
	}
	
	public var dwarfRooms(get_dwarfRooms, null):Array<DwarfRoom>;
	
	function get_lyrShrooms():FlxGroup 
	{
		return _lyrShrooms;
	}
	
	public var lyrShrooms(get_lyrShrooms, null):FlxGroup;
	
}