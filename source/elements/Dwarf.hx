package elements;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Dwarf
{
	
	private var _female:Bool;
	
	public inline static var COLOR_DWARF:Int = 0xFFFF00FF;
	
	public inline static var ACT_IDLE:Int = 0;
	public inline static var ACT_WALKLEFT:Int = 1;
	public inline static var ACT_WALKRIGHT:Int = 2;
	public inline static var ACT_WALKUP:Int = 3;
	public inline static var ACT_WALKDOWN:Int = 4;
	public inline static var ACT_TREE:Int = 5;
	public inline static var ACT_BUILD:Int = 6;
	public inline static var ACT_BIRTH:Int = 7;
	public inline static var ACT_MINE:Int = 8;
	
	private inline static var DIR_DOWN:Int = 0;
	private inline static var DIR_UP:Int = 1;
	private inline static var DIR_RIGHT:Int = 2;
	private inline static var DIR_LEFT:Int = 3;
	
	private inline static var DIG_DIR_RD:Int = 0;
	private inline static var DIG_DIR_LD:Int = 1;
	private inline static var DIG_DIR_RU:Int = 2;
	private inline static var DIG_DIR_LU:Int = 3;
	
	private var _life:Float;
	private var _pos:FlxPoint;
	private var _action:Int;
	
	private var _w:World;
	private var _home:DwarfHouse;
	private var _building:DwarfHouse;
	private var _atHome:Bool;
	private var _wait:Float;
	private var _sinceBirth:Float;
	private var _underground:Bool;
	private var _digDir:Int;
	private var _curDigX:Int;
	private var _curDigY:Int;
	private var _room:Rectangle;
	private var _startedRoom:Bool;
	
	
	
	public function new(W:World) 
	{
		_w = W;
	}
	
	
	public function spawn(X:Int, Y:Int):Dwarf
	{
		_life = 4;
		_female = FlxRandom.chanceRoll();
		_pos = new FlxPoint(X, Y);
		_action = ACT_IDLE;
		_sinceBirth = FlxRandom.intRanged(120, 400);
		_underground = true;
		_curDigX = -1;
		_curDigY = -1;
		_atHome = false;
		_digDir = -1;
		_wait = 0;
		_room = null;
		_startedRoom = false;
		
		return this;
		
	}
	
	public function update():Void
	{
		_pos.x = Std.int(_pos.x);
		_pos.y = Std.int(_pos.y);
		
		if (_action < ACT_TREE || _action == ACT_MINE)
			_life -= FlxRandom.floatRanged(0.001, 0.003);
		if (FlxRandom.chanceRoll(2))
		{
			if (_w.dwarfFood > 0)
				_w.dwarfFood -= FlxRandom.intRanged(0,Std.int(FlxMath.bound(2, 0, _w.dwarfFood)));
			else
				_life-= FlxRandom.floatRanged(0.015, 0.045);
		}
		
		if (_life <= 0)
			return;
		
		if (_sinceBirth > 0)
			_sinceBirth--;
		
		if (_home == null)
		{
			for (ch in _w.dHouses)
			{
				if (!ch.owned)
				{
					_home = ch;
					ch.owned = true;
				}
			}
		}
		
		if (_action > ACT_WALKDOWN)
		{
			switch(_action)
			{
				case ACT_BIRTH:
					BirthChild();
				case ACT_BUILD:
					BuildHouse();
				case ACT_MINE:
					MineTunnel();
			}
		}
		else
		{
			if (_underground && _pos.y < _w.ground.points[Std.int(_pos.x)])
			{
				_underground = false;
				_pos.y = _w.ground.points[Std.int(_pos.x)] - 1;
				_action  = -1;
			}
			else if (!_underground && _pos.y >= _w.ground.points[Std.int(_pos.x)])
			{
				_underground = true;
				_action = -1;
			}
			
			if (_action == ACT_WALKLEFT)
			{
				if (_pos.x < 10 || (_underground && _w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y))))
					_action = -1;
			}
			
			if (_action == ACT_WALKRIGHT)
			{
				if (_pos.x > FlxG.width - 10 || (_underground && _w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y))))
					_action = -1;
			}
			
			if (_action == ACT_WALKUP)
			{
				if (!_underground || pos.y -2 < _w.ground.points[Std.int(_pos.x)] || _w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
					_action = -1;
			}
			
			if (_action == ACT_WALKDOWN)
			{
				if (!_underground || _pos.y > FlxG.height - 10 || _w.isSolid(Std.int(_pos.x),Std.int( _pos.y + 1)))
					_action = -1;
			}
			
			if (_action == -1 || FlxRandom.chanceRoll(5))
			{
				var acts:Array<Int> = new Array<Int>();
				acts.push(ACT_IDLE);
				acts.push(ACT_MINE);
				if (_pos.x > 10)
				{
					if (!_underground || !_w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y)))
						acts.push(ACT_WALKLEFT);
				}
				if (_pos.x < FlxG.width - 10)
				{
					if (!_underground || !_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						acts.push(ACT_WALKRIGHT);
				}
				if (_underground)
				{
					if (_pos.y -2 < _w.ground.points[Std.int(_pos.x)] || !_w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
						acts.push(ACT_WALKUP);
					if (_pos.y < FlxG.height - 10 && !_w.isSolid(Std.int(_pos.x), Std.int(_pos.y + 1)))
						acts.push(ACT_WALKDOWN);
						
					if (_home == null && _w.dwarfOre > 150)
					{
						var tmpS:FlxSprite = new FlxSprite(_pos.x - 3, _pos.y - 3).makeGraphic(7, 7, 0xFF000000,true);
						if (!FlxG.overlap(_w.lyrDHouses, tmpS) && !FlxCollision.pixelPerfectCheck(tmpS, _w.lyrMagma, 200))
							acts.push(ACT_BUILD);
						tmpS.kill();
					}
					
					if (_female && _home != null && _sinceBirth <=0 && _w.dwarfFood >= 15)
					{
						acts.push(ACT_BIRTH);
					}
				}
				
				_action = acts[FlxRandom.intRanged(0, acts.length)];
				
				switch(_action)
				{
					case ACT_BUILD:
						var h:DwarfHouse = new DwarfHouse(_w, Std.int(_pos.x), Std.int(_pos.y));
						_w.dHouses.push(h);
						_w.lyrDHouses.add(h);
						_building = h;
						_home = h;
						h.owned = true;
						_w.dwarfOre-= 150;
					case ACT_MINE:
						if (!_underground)
						{
							_pos.y = _w.ground.points[Std.int(_pos.x)];
							_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y),World.CORIENT_D);
							_w.giveDOre();
							_underground = true;
						}
				}
			}
		}
		
		switch (_action)
		{
			case ACT_IDLE:
			
			case ACT_WALKLEFT:
				Walk(DIR_LEFT);
			case ACT_WALKRIGHT:
				Walk(DIR_RIGHT);
			case ACT_WALKDOWN:
				Walk(DIR_DOWN);
			case ACT_WALKUP:
				Walk(DIR_UP);
		}
	}
	
	private function BirthChild():Void
	{
		if (!_atHome)
		{
			if (_home.x + 2 == _pos.x && _home.y + 4 == _pos.y)
			{
				_atHome = true;
				_wait =FlxRandom.intRanged(80, 120);
				_home.birthing = true;
				
			}
			else 
			{
				
				if (Math.abs(_pos.y - (_home.y + 4)) > Math.abs(_pos.x - (_home.x + 2)))
				{
					if (_pos.y > (_home.y + 4))
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y - 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_UP);
					}
					else
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y + 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y + 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_DOWN);
					}
				}
				else
				{
					if (_pos.x > (_home.x + 2))
					{
						if (_w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x - 1), Std.int(_pos.y) , World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_LEFT);
					}
					else
					{
						if (_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x + 1), Std.int(_pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_RIGHT);
					}
				}
			}
		}
		else
		{
			if (_wait > 0)
				_wait--;
			else
			{
				_sinceBirth = FlxRandom.intRanged(120,400);
				_atHome = false;
				_w.dwarfFood -= 15;
				_home.birthing = false;
				_w.SpawnDwarf(Std.int(_pos.x),Std.int(_pos.y));
				_action = -1;
			}
		}
	}
	
	private function Walk(D:Int):Void
	{
		var xD:Int;
		var yD:Int;
		if (D == DIR_LEFT || D == DIR_RIGHT)
		{
			if (D == DIR_LEFT)
				xD = -1;
			else
				xD = 1;
				
			if (!_underground && _w.ground.points[Std.int(_pos.x)] <  _w.ground.points[Std.int(_pos.x + xD)] - 1)
			{
				_w.ground.cutGround(Std.int(_pos.x), 1);
				_pos.y++;
				_w.ground.fillGround(Std.int(_pos.x + xD), 1);
			}
			else if (!_underground && _w.ground.points[Std.int(_pos.x  + xD)] < _w.ground.points[Std.int(_pos.x)] - 1)
			{
				_w.ground.cutGround(Std.int(_pos.x + xD), 1);
				_pos.y++;
				_w.ground.fillGround(Std.int(_pos.x)  , 1);
			}
			else
			{
				_pos.x+=xD;
			}
				
			
		}
		else
		{
			if (D == DIR_UP)
				_pos.y--;
			else if (D == DIR_DOWN)
				_pos.y++;
		}
	}
	
	private function BuildHouse():Void
	{
		if (_building == null)
		{
			_action = -1;
			return;
		}
		if (_building.health <= 25)
		{
			_building.build(FlxRandom.intRanged(0, 3));
		}
		else
		{
			_building = null;
			_action = -1;
		}
		
	}
	
	private function MineTunnel():Void
	{
		if (_room == null)
		{
			_startedRoom = false;
			var bX1:Int = Std.int(_pos.x - 20);
			var bX2:Int = Std.int(_pos.x + 20);
			var bY1:Int = Std.int(_pos.y - 20);
			var bY2:Int = Std.int(_pos.y + 20);
			
			if (bX1 < 10) bX1 = 10;
			else if (bX1 > FlxG.width - 20) bX1 = FlxG.width - 25;
			if (bX2 > FlxG.width - 10) bX2 = FlxG.width - 10;
			else if (bX2 < 20) bX2 = 20;
			
			
			for (d in bX1...bX2)
			{
				if (_w.ground.points[d] + 10 > bY1)
					bY1 = _w.ground.points[d];
			}
			if (bY2 <= bY1 + 10)
				bY2 = bY1 + 10;
			
			if (bY2 > FlxG.height - 30) bY2 = FlxG.height - 30;
			
			if (bX2 > bX1)
			{
				var bX3:Int = bX1;
				bX1 = bX2;
				bX2 = bX3;
			}
							
			if (bY2 > bY1)
			{
				var bY3:Int = bY1;
				bY1 = bY2;
				bY2 = bY3;
			}
			
			if (bX1 != bX2 && bY1 != bY2)
			{
				_room = new Rectangle(FlxRandom.intRanged(bX1, bX2), FlxRandom.intRanged(bY1, bY2), FlxRandom.intRanged(3, 8) * 5, FlxRandom.intRanged(1, 4) * 5);
				_room.x = Std.int(_room.x);
				_room.y = Std.int(_room.y);
				_room.width = Std.int(_room.width);
				_room.height = Std.int(_room.height);
				
				_room.y += 10 - (_room.y % 10);
				
				//debug
				//_w.caves.pixels.fillRect(_room, 0xffff0000);
				var t:FlxSprite = new FlxSprite(_room.x, _room.y).makeGraphic(Std.int(_room.width), Std.int(_room.height), 0xff000000,true);
				if (FlxCollision.pixelPerfectCheck(t, _w.dRooms))
				{
					_room = null;
					_action = -1;
				}
				else
				{
					_w.dRooms.pixels.fillRect(_room, 0xffff0000);
					_w.dRooms.dirty = true;
				}
				t.kill();
			}
			
		}
		else if (!_startedRoom)
		{
			var Dist11:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.x, _room.y)));
			var Dist21:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.x + _room.width, _room.y)));
			var Dist12:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.x, _room.y + _room.height)));
			var Dist22:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.x + _room.width, _room.y + _room.height)));
			
			if (Dist11 == 0 || (_pos.x == _room.x && _pos.y == _room.y))
			{
				_digDir = DIG_DIR_RD;
				_curDigX = 0;
				_curDigY = 0;
				_startedRoom = true;
			}
			else if (Dist12 == 0 || (_pos.x == _room.x && _pos.y == _room.y + _room.height))
			{
				_digDir = DIG_DIR_RU;
				_curDigX = 0;
				_curDigY = Std.int(_room.height);
				_startedRoom = true;
			}
			else if (Dist21 == 0 || (_pos.x == _room.x + _room.width && _pos.y == _room.y))
			{
				_digDir = DIG_DIR_LD;
				_curDigX = Std.int(_room.width);
				_curDigY = 0;
				_startedRoom = true;
			}
			else if (Dist22 == 0 || (_pos.x == _room.x + _room.width && _pos.y == _room.y + _room.height))
			{
				_digDir = DIG_DIR_LU;
				_curDigX = Std.int(_room.width);
				_curDigY = Std.int(_room.height);
				_startedRoom = true;
			}
			else
			{
				var closest:Float = Dist11;
				var dX:Int = Std.int(_room.x);
				var dY:Int = Std.int(_room.y);
				if (Dist12 < closest) 
				{
					closest = Dist12;
					dX = Std.int(_room.x);
					dY = Std.int(_room.y + _room.height);
				}
				if (Dist21 < closest) 
				{
					closest = Dist21;
					dX = Std.int(_room.x + _room.width);
					dY = Std.int(_room.y);
				}
				if (Dist22 < closest)
				{
					closest = Dist22;
					dX = Std.int(_room.x + _room.width);
					dY = Std.int(_room.y + _room.height);
				}
				if (Math.abs(_pos.y - dY) > Math.abs(_pos.x - dX))
				{
					if (_pos.y > dY)
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y - 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_UP);
					}
					else
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y + 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y + 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_DOWN);
					}
				}
				else
				{
					if (_pos.x > dX)
					{
						if (_w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x - 1), Std.int(_pos.y) , World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_LEFT);
					}
					else
					{
						if (_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x + 1), Std.int(_pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_RIGHT);
					}
				}
				
				
			}
			
		}
		else
		{
			if (_digDir == DIG_DIR_LD || _digDir == DIG_DIR_RD)
			{
				if (_digDir == DIG_DIR_RD)
				{
					if (_curDigX < _room.width)
					{
						if (_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x + 1), Std.int(pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_RIGHT);
						_curDigX++;
					}
					else if (_curDigY < _room.height)
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y + 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(pos.y + 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_DOWN);
						_curDigY++;
						_digDir = DIG_DIR_LD;
					}
					else
					{
						_startedRoom = false;
						_curDigY = -1;
						_curDigX = -1;
						_room = null;
						_action = -1;
						return;
					}
				}
				else if (_digDir == DIG_DIR_LD)
				{
					if (_curDigX > 0)
					{
						if (_w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x - 1), Std.int(pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_LEFT);
						_curDigX--;
					}
					else if (_curDigY < _room.height)
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y + 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(pos.y + 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_DOWN);
						_curDigY++;
						_digDir = DIG_DIR_RD;
					}
					else
					{
						_startedRoom = false;
						_curDigY = -1;
						_curDigX = -1;
						_room = null;
						_action = -1;
						return;
					}
				}
			}
			else if (_digDir == DIG_DIR_LU || _digDir == DIG_DIR_RU)
			{
				if (_digDir == DIG_DIR_RU)
				{
					if (_curDigX < _room.width)
					{
						if (_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x + 1), Std.int(pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_RIGHT);
						_curDigX++;
					}
					else if (_curDigY > 0)
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(pos.y - 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_UP);
						_curDigY--;
						_digDir = DIG_DIR_LU;
					}
					else
					{
						_startedRoom = false;
						_curDigY = -1;
						_curDigX = -1;
						_room = null;
						_action = -1;
						return;
					}
				}
				else if (_digDir == DIG_DIR_LU)
				{
					if (_curDigX > 0)
					{
						if (_w.isSolid(Std.int(_pos.x - 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x - 1), Std.int(pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_LEFT);
						_curDigX--;
					}
					else if (_curDigY > 0)
					{
						if (_w.isSolid(Std.int(_pos.x), Std.int(_pos.y - 1)))
						{
							_w.MakeCave(Std.int(_pos.x), Std.int(pos.y - 1), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_UP);
						_curDigY--;
						_digDir = DIG_DIR_RU;
					}
					else
					{
						_startedRoom = false;
						_curDigY = -1;
						_curDigX = -1;
						_room = null;
						_action = -1;
						return;
					}
				}
			}
		}
	}
	
	function get_female():Bool 
	{
		return _female;
	}
	
	public var female(get_female, null):Bool;
	
	function get_underground():Bool 
	{
		return _underground;
	}
	
	public var underground(get_underground, null):Bool;
	
	function get_life():Float 
	{
		return _life;
	}
	
	public var life(get_life, null):Float;
	
	function get_pos():FlxPoint 
	{
		return _pos;
	}
	
	public var pos(get_pos, null):FlxPoint;
	
	function get_atHome():Bool 
	{
		return _atHome;
	}
	
	public var atHome(get_atHome, null):Bool;
	
}