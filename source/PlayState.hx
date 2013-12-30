package;

import elements.World;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	private var _world:World;
	
	private var _created:Int = 0;
	private var _tick:Float;
	
	private var _lyrHUD:FlxGroup;
	private var _hudHPop:FlxText;
	private var _hudHWood:FlxText;
	private var _hudHFood:FlxText;
	private var _hudDPop:FlxText;
	private var _hudDFood:FlxText;
	private var _hudDOre:FlxText;
	
	private var _lyrStatus:FlxGroup;
	private var _msgs:Array<FlxText>;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		//FlxG.mouse.show();
		#end
		
		_tick = 0;
		_world = new World(this);
		
		_msgs = new Array<FlxText>();
		_lyrStatus = new FlxGroup();
		add(_lyrStatus);
		
		_msgs.push(cast _lyrStatus.add(new FlxText(8, 8, FlxG.width - 10, "Initializing...")));
		_created = 1;
		
		_lyrHUD = new FlxGroup();
		
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	private function UpdateHUD():Void
	{
		_hudHPop.text = Std.string(_world.humanPop);
		_hudHFood.text = Std.string(_world.humanFood);
		_hudHWood.text = Std.string(_world.humanWood);
		_hudDPop.text = Std.string(_world.dwarfPop);
		_hudDFood.text = Std.string(_world.dwarfFood);
		_hudDOre.text = Std.string(_world.dwarfOre);
	}
	
	
	private function GenerateWorld():Void
	{
		switch (_created)
		{
			case 1:
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 16, FlxG.width - 10, "Starting Ground Generation...")));
				_created = 2;
			case 2:
				_world.MakeGround();
				_created = 3;
			case 3:
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 24, FlxG.width - 10, "Starting Tree Generation...")));
				_created = 4;
			case 4:
				_world.populateTrees();
				_created =5;
			case 5:
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 32, FlxG.width - 10, "Starting Human Generation...")));
				_created = 6;
			case 6:
				_world.populateHumans();
				_created = 7;
			case 7:
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 40, FlxG.width - 10, "Generating Caves...")));
				_created = 8;
			case 8:
				_world.populateCaves();
				_created = 9;
			case 9:
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 48, FlxG.width - 10, "Populating Dwarfs...")));
				_created = 10;
			case 10:
				_world.populateDwarfs();
				_created = 11;
			case 11:
				_world.populateHouses();
				
				_msgs.push(cast _lyrStatus.add(new FlxText(8, 56, FlxG.width - 10, "Finished!")));
				
				_lyrStatus.kill();
				
				_world.MakeSky();
				add(_world.dRooms);
				add(_world.sky);
				add(_world.ground.groundMap);
				add(_world.lyrTrees);
				add(_world.caves);
				add(_world.lyrMagma);
				add(_world.lyrFX);
				add(_world.lyrHouses);
				add(_world.lyrDHouses);
				add(_world.lyrShrooms);
				add(_world.lyrGuys);
				add(_world.lyrDwarfs);
				
				add(_lyrHUD);
				
				_lyrHUD.add(new FlxSprite(10, 10).makeGraphic(140, 62, 0x99000000));
				_lyrHUD.add(new FlxText(14, 14, 132, "Humans").setFormat(null,8,0xffffff,"center"));
				_lyrHUD.add(new FlxText(14, 26, 70, "Population:"));
				_lyrHUD.add(new FlxText(14, 38, 70, "Food:"));
				_lyrHUD.add(new FlxText(14, 50, 70, "Wood:"));
				_hudHPop = cast _lyrHUD.add(new FlxText(84, 26, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				_hudHFood = cast _lyrHUD.add(new FlxText(84, 38, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				_hudHWood = cast _lyrHUD.add(new FlxText(84, 50, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				
				_lyrHUD.add(new FlxSprite(10, 82).makeGraphic(140, 62, 0x99000000));
				_lyrHUD.add(new FlxText(14, 86, 132, "Dwarfs").setFormat(null,8,0xffffff,"center"));
				_lyrHUD.add(new FlxText(14, 98, 70, "Population:"));
				_lyrHUD.add(new FlxText(14, 110, 70, "Food:"));
				_lyrHUD.add(new FlxText(14, 122, 70, "Ore:"));
				_hudDPop = cast _lyrHUD.add(new FlxText(84, 98, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				_hudDFood = cast _lyrHUD.add(new FlxText(84, 110, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				_hudDOre = cast _lyrHUD.add(new FlxText(84, 122, 60, "0").setFormat(null, 8, 0xffffff, "right"));
				
				/*
				
				var gradient_v:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x0);
				var cTransform:ColorTransform = new ColorTransform(255,255,255,1,0,0,0,0);
				
				
				gradient_v = _world.ground.groundMap.pixels.clone();
				gradient_v.colorTransform(gradient_v.rect, cTransform);
				
				//.copyChannel(_world.ground.groundMap.pixels, _world.ground.groundMap.pixels.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE);
				
				gradient_v.applyFilter(gradient_v, gradient_v.rect, new Point(), new BlurFilter(128,128, 1));
				
				var s:FlxSprite = new FlxSprite();
				s.pixels = gradient_v.clone();
				add(s);*/
				
				_created = 100;
		}
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (_created < 100)
		{
			GenerateWorld();
		}
		else
		{
			if (_tick <= 0)
			{
				_world.update();
				_tick = 2;
			}
			else
				_tick -= FlxG.elapsed * 80;
			
			UpdateHUD();
		}
		super.update();
	}	
}