package elements;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;

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
	public inline static var ACT_PLANT:Int = 9;
	public inline static var ACT_HARVEST:Int = 10;
	
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
	private var _room:DwarfRoom;
	private var _startedRoom:Bool;
	private var _targetPos:FlxPoint;
	private var _shroom:DwarfShroom;
	private var _alive:Bool;
	
	
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
		_shroom = null;
		_alive = true;
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
		{
			if (_alive)
			{
				_alive = false;
				if (_home != null)
					_home.owned = false;
				_home = null;
				_room = null;
				_startedRoom = false;
				_shroom = null;
				
			}
			return;
		}
		
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
				case ACT_PLANT:
					PlantCrops();
				case ACT_HARVEST:
					Harvest();
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
						
					if ((_home == null && _w.dwarfOre > 150) || _w.dwarfOre > _w.dwarfPop * 150)
					{
						//var tmpS:FlxSprite = new FlxSprite(_pos.x - 3, _pos.y - 3).makeGraphic(7, 7, 0xFF000000,true);
						//if (!FlxG.overlap(_w.lyrDHouses, tmpS) && !FlxCollision.pixelPerfectCheck(tmpS, _w.lyrMagma, 200))
						acts.push(ACT_BUILD);
						//tmpS.kill();
					}
					
					
					if (_female && _sinceBirth <=0 && _w.dwarfFood >= 15)
					{
						if ( _home != null)
							acts.push(ACT_BIRTH);
						else if (_w.dwarfOre > 150)
							acts.push(ACT_BUILD);
					}
				}
				
				if (_w.dwarfFood < _w.dwarfPop * 200)
				{
					
					if (_w.lyrShrooms.countLiving() > 100)
					{
						acts.push(ACT_HARVEST);
						acts.push(ACT_HARVEST);
					}
					acts.push(ACT_PLANT);
					acts.push(ACT_PLANT);
					
				}
				if (_w.dwarfFood < _w.dwarfPop * 100)
				{
					if (_w.lyrShrooms.countLiving() > 10)
					{
						acts.push(ACT_HARVEST);
						acts.push(ACT_HARVEST);
					}
					acts.push(ACT_PLANT);
					acts.push(ACT_PLANT);
					
				}
				if (_w.dwarfFood < _w.dwarfPop * 50)
				{
					if (_w.lyrShrooms.countLiving() > 1)
					{
						acts.push(ACT_HARVEST);
						acts.push(ACT_HARVEST);
					}
					acts.push(ACT_PLANT);
					acts.push(ACT_PLANT);
					
					
				}
				acts.push(ACT_PLANT);
				if (_w.lyrShrooms.countLiving() > 1)
				{
					acts.push(ACT_HARVEST);
				}
				
				_action = acts[FlxRandom.intRanged(0, acts.length-1)];
				
				switch(_action)
				{
					case ACT_BUILD:
						
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
		
		if (_room == null)
		{
			_targetPos = null;
			for (r in _w.dwarfRooms)
			{
				if (r.roomtype == DwarfRoom.TYPE_HOUSING && !r.full)
				{
					_room = r;
				}
			}
		}
		if (_room == null)
		{
			_building = null;
			_room = null;
			_targetPos = null;
			_action = -1;
		}
		else
		{
			if (_targetPos == null)
			{
				var check:FlxPoint = new FlxPoint(_room.rect.x + 2, _room.rect.y + 2);
				var foundSpot:Bool = false;
				var anyOverlap:Bool = false;
				while (check.y < _w.ground.points[Std.int(check.x)])
					check.y += 5;
				while (check.x < _room.rect.right - 2 && check.y < _room.rect.bottom)
				{
					for (d in _w.lyrDHouses.members)
					{
						var s:DwarfHouse = cast d;
						if (s.alive && s.exists && _room.rect.overlaps(s.rect) && s.overlapsPoint(check))
						{
							anyOverlap = true;
							break;
						}
					}
					
					if (!anyOverlap && check.y > _w.ground.points[Std.int(check.x)]) 
					{
						_targetPos = new FlxPoint(check.x, check.y);
						
						check.x = _room.rect.right;
						check.y = _room.rect.bottom;
						foundSpot = true;
					}
					else
					{
						anyOverlap = false;
						check.x += 5;
						if (check.x > _room.rect.right - 2)
						{
							check.x = _room.rect.x + 2;
							check.y += 5;
							while (check.y < _w.ground.points[Std.int(check.x)])
							{
								check.x = _room.rect.x + 2;
								check.y += 5;
							}
						}
					}
				}
				if (!foundSpot)
				{
					_room.full = true;
					_building = null;
					_room = null;
					_targetPos = null;
					_action = -1;
				}
				else
				{
					//trace('found spot!');
					var h:DwarfHouse = new DwarfHouse(_w, Std.int(_targetPos.x), Std.int(_targetPos.y));
					_w.dHouses.push(h);
					_w.lyrDHouses.add(h);
					_building = h;
					_home = h;
					h.owned = true;
					_w.dwarfOre-= 150;
					
					
				}
			}
			else
			{
				if (_pos.x != _targetPos.x || _pos.y != _targetPos.y)
				{
					
					var dX:Int = Std.int(_targetPos.x);
					var dY:Int = Std.int(_targetPos.y);
					
					
					if (Math.abs(_pos.y - dY) > Math.abs(_pos.x - dX))
					{
						if (_pos.y > dY)
						{
							
							Walk(DIR_UP);
						}
						else
						{
							
							Walk(DIR_DOWN);
						}
					}
					else
					{
						if (_pos.x > dX)
						{
							
							Walk(DIR_LEFT);
						}
						else
						{
							
							Walk(DIR_RIGHT);
						}
						
						
						
					}
				}
				else
				{
					if (_building.health <= 25)
					{
						_building.build(FlxRandom.intRanged(0, 3));
					}
					else
					{
						_building = null;
						_room = null;
						_targetPos = null;
						_action = -1;
					}
				}
			}
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
				_room = new DwarfRoom(FlxRandom.intRanged(bX1, bX2), FlxRandom.intRanged(bY1, bY2), FlxRandom.intRanged(3, 8) * 5, FlxRandom.intRanged(1, 4) * 5, FlxRandom.intRanged(0,3));
				_room.rect.x = Std.int(_room.rect.x);
				_room.rect.y = Std.int(_room.rect.y);
				_room.rect.width = Std.int(_room.rect.width);
				_room.rect.height = Std.int(_room.rect.height);
				_room.rect.y += 10 - (_room.rect.y % 10);
				
				/// if the room overlaps another room, abort
				
				if (_room.roomtype == DwarfRoom.TYPE_MSPRING)
				{
					_w.lyrMSprings.add(new MagmaSpring(_w, FlxRandom.intRanged(Std.int(_room.rect.x + 2), Std.int(_room.rect.right - 2)), FlxRandom.intRanged(Std.int(_room.rect.y +2), Std.int(_room.rect.bottom - 2))));
					
				}
				
				var bad:Bool = false;
				var tmp:FlxRect = new FlxRect(_room.rect.x - 2, _room.rect.y - 2, _room.rect.width + 4, _room.rect.height + 4);
				if (tmp.right > FlxG.width || tmp.x < 0 || tmp.bottom > FlxG.height || tmp.y < 0) bad = true;
				if (!bad)
				{
					for (r in _w.dwarfRooms)
					{
						if (tmp.overlaps(r.rect))
						{
							bad = true;
							break;
						}
					}
				}
				tmp = null;
				
				
				//debug
				//_w.caves.pixels.fillRect(_room, 0xffff0000);
				//var t:FlxSprite = new FlxSprite(_room.rect.x, _room.rect.y).makeGraphic(Std.int(_room.rect.width), Std.int(_room.rect.height), 0xff000000,true);
				//if (FlxCollision.pixelPerfectCheck(t, _w.dRooms))
				
				if (bad)
				{
					_room = null;
					_action = -1;
				}
				else
				{
					_w.dRooms.pixels.fillRect(new Rectangle(_room.rect.x,_room.rect.y, _room.rect.width, _room.rect.height), 0xffff0000);
					_w.dRooms.dirty = true;
					_w.dRooms.resetFrameBitmapDatas();
					_w.dwarfRooms.push(new DwarfRoom(Std.int(_room.rect.x), Std.int(_room.rect.y), Std.int(_room.rect.width), Std.int(_room.rect.height), _room.roomtype));
				}
				//t.kill();
			}
			
		}
		else if (!_startedRoom)
		{
			var Dist11:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.rect.x, _room.rect.y)));
			var Dist21:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.rect.x + _room.rect.width, _room.rect.y)));
			var Dist12:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.rect.x, _room.rect.y + _room.rect.height)));
			var Dist22:Float = Math.abs(FlxMath.getDistance(_pos, new FlxPoint(_room.rect.x + _room.rect.width, _room.rect.y + _room.rect.height)));
			
			if (Dist11 == 0 || (_pos.x == _room.rect.x && _pos.y == _room.rect.y))
			{
				_digDir = DIG_DIR_RD;
				_curDigX = 0;
				_curDigY = 0;
				_startedRoom = true;
			}
			else if (Dist12 == 0 || (_pos.x == _room.rect.x && _pos.y == _room.rect.y + _room.rect.height))
			{
				_digDir = DIG_DIR_RU;
				_curDigX = 0;
				_curDigY = Std.int(_room.rect.height);
				_startedRoom = true;
			}
			else if (Dist21 == 0 || (_pos.x == _room.rect.x + _room.rect.width && _pos.y == _room.rect.y))
			{
				_digDir = DIG_DIR_LD;
				_curDigX = Std.int(_room.rect.width);
				_curDigY = 0;
				_startedRoom = true;
			}
			else if (Dist22 == 0 || (_pos.x == _room.rect.x + _room.rect.width && _pos.y == _room.rect.y + _room.rect.height))
			{
				_digDir = DIG_DIR_LU;
				_curDigX = Std.int(_room.rect.width);
				_curDigY = Std.int(_room.rect.height);
				_startedRoom = true;
			}
			else
			{
				var closest:Float = Dist11;
				var dX:Int = Std.int(_room.rect.x);
				var dY:Int = Std.int(_room.rect.y);
				if (Dist12 < closest) 
				{
					closest = Dist12;
					dX = Std.int(_room.rect.x);
					dY = Std.int(_room.rect.y + _room.rect.height);
				}
				if (Dist21 < closest) 
				{
					closest = Dist21;
					dX = Std.int(_room.rect.x + _room.rect.width);
					dY = Std.int(_room.rect.y);
				}
				if (Dist22 < closest)
				{
					closest = Dist22;
					dX = Std.int(_room.rect.x + _room.rect.width);
					dY = Std.int(_room.rect.y + _room.rect.height);
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
					if (_curDigX < _room.rect.width)
					{
						if (_w.isSolid(Std.int(_pos.x + 1), Std.int(_pos.y)))
						{
							_w.MakeCave(Std.int(_pos.x + 1), Std.int(pos.y), World.CORIENT_P);
							_w.giveDOre();
						}
						Walk(DIR_RIGHT);
						_curDigX++;
					}
					else if (_curDigY < _room.rect.height)
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
					else if (_curDigY < _room.rect.height)
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
					if (_curDigX < _room.rect.width)
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
	
	function PlantCrops():Void
	{
		if (_room == null)
		{
			_targetPos = null;
			for (r in _w.dwarfRooms)
			{
				if (r.roomtype == DwarfRoom.TYPE_FARM && !r.full)
				{
					_room = r;
				}
			}
		}
		if (_room == null)
		{
			_shroom = null;
			_room = null;
			_targetPos = null;
			_action = -1;
		}
		else
		{
			if (_targetPos == null)
			{
				var check:FlxPoint = new FlxPoint(_room.rect.x + 1, _room.rect.y + 3);
				var foundSpot:Bool = false;
				var anyOverlap:Bool = false;
				while (check.y < _w.ground.points[Std.int(check.x)])
					check.y += 4;
				while (check.x < _room.rect.right - 1 && check.y < _room.rect.bottom)
				{
					
					for (d in _w.lyrShrooms.members)
					{
						var s:DwarfShroom = cast d;
						if (s.alive && s.exists && _room.rect.overlaps(s.rect) && s.overlapsPoint(check))
						{
							anyOverlap = true;
							break;
						}
					}
					
					if (!anyOverlap && check.y > _w.ground.points[Std.int(check.x)])
					{
						_targetPos = new FlxPoint(check.x, check.y);
						
						check.x = _room.rect.right;
						check.y = _room.rect.bottom;
						foundSpot = true;
					}
					else
					{
						anyOverlap = false;
						check.x += 3;
						if (check.x > _room.rect.right - 1)
						{
							check.x = _room.rect.x + 1;
							check.y += 4;
							while (check.y < _w.ground.points[Std.int(check.x)])
							{
								check.x = _room.rect.x + 1;
								check.y += 4;
							}
						}
					}
				}
				if (!foundSpot)
				{
					_room.full = true;
					_room = null;
					_targetPos = null;
					_shroom = null;
					_action = -1;
				}
				else
				{
					
					var s:DwarfShroom = cast _w.lyrShrooms.recycle(DwarfShroom, [_w], true);
					if (s == null)
					{
						s = new DwarfShroom(_w);
						_w.lyrShrooms.add(s);
					}
					
					s.reset(_targetPos.x - 1, _targetPos.y - 3);
					s.visible = false;
					_shroom = s;
				
					
				}
			}
			else
			{
				if (_pos.x != _targetPos.x || _pos.y != _targetPos.y)
				{
					
					var dX:Int = Std.int(_targetPos.x);
					var dY:Int = Std.int(_targetPos.y);
					
					
					if (Math.abs(_pos.y - dY) > Math.abs(_pos.x - dX))
					{
						if (_pos.y > dY)
						{
							
							Walk(DIR_UP);
						}
						else
						{
							
							Walk(DIR_DOWN);
						}
					}
					else
					{
						if (_pos.x > dX)
						{
							
							Walk(DIR_LEFT);
						}
						else
						{
							
							Walk(DIR_RIGHT);
						}
						
						
						
					}
				}
				else
				{
					//trace('planted!');
					_shroom.visible = true;
					_shroom = null;
					_room = null;
					_targetPos = null;
					_action = -1;
				}
			}
		}
	}

	private function Harvest():Void
	{
		if (_shroom == null)
		{
			var sh:DwarfShroom;
			for (s in _w.lyrShrooms.members)
			{
				sh = cast s;
				if (sh.alive && sh.status == DwarfShroom.STATUS_NORMAL)
				{
					_shroom = sh;
					_targetPos = new FlxPoint(_shroom.x + 1, _shroom.y + 3);
					_shroom.status = DwarfShroom.STATUS_CUTTING;
					break;
					
				}
			}
			if (_shroom == null)
			{
				_shroom = null;
				_targetPos = null;
				_action = ACT_PLANT;
				
			}
		}
		else
		{
			if (_pos.x != _targetPos.x || _pos.y != _targetPos.y)
			{
				
				var dX:Int = Std.int(_targetPos.x);
				var dY:Int = Std.int(_targetPos.y);
				
				
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
			else
			{
				_shroom.status = DwarfShroom.STATUS_CUTDOWN;
				_shroom.kill();
				_w.dwarfFood += 100;
				
				_shroom = null;
				_targetPos = null;
				_action = -1;
			}
		}
	}
	
	function NoCheck(D:Dynamic):Void
	{
		
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
	
	function get_alive():Bool 
	{
		return _alive;
	}
	
	function set_alive(value:Bool):Bool 
	{
		return _alive = value;
	}
	
	public var alive(get_alive, set_alive):Bool;
	
}