package elements;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Guy
{

	private var _female:Bool;
		
	public inline static var COLOR_HUMAN:Int = 0xFF00FFFF;
	
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
	
	private var _life:Float; 
	private var _pos:FlxPoint;
	private var _action:Int;
	
	private var _w:World;
	
	private var _targetTree:Tree;
	private var _home:House;
	private var _building:House;
	private var _atHome:Bool;
	private var _wait:Float;
	private var _sinceBirth:Float;
	private var _underground:Bool;
	private var _digDir:Int;
	
	
	public function new(W:World) 
	{
		_w = W;
	}
	
	public function spawn(X:Int, Y:Int):Guy
	{
		_life = 1;
		_female = FlxRandom.chanceRoll();
		_pos = new FlxPoint(X, Y);
		_action = ACT_IDLE;
		_sinceBirth = FlxRandom.intRanged(60, 100);
		_underground = false;
		_digDir = -1;
		_targetTree = null;
		_home = null;
		_atHome = false;
		_building = null;
		_digDir = -1;
		_wait = 0;
		return this;
	}
	
	public function update():Void
	{
		
		if (_action < ACT_TREE || _action == ACT_MINE)
		{
			_life-= FlxRandom.floatRanged(0.001, 0.003);
			
			if (FlxRandom.chanceRoll(5))
			{
				if (_w.humanFood > 0)
					_w.humanFood -= FlxRandom.intRanged(0, Std.int(FlxMath.bound(2, 0, _w.humanFood)));
				else
					_life -= FlxRandom.floatRanged(0.003, 0.009);
			}
			
			if (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y), _w.lyrMagma, 255))
			{
				//Magma!
				_life-=FlxRandom.floatRanged(0.3, 0.9);
			}
			
			if (_life <= 0)
			{
				//_dead = true;
				if (_home != null)
					_home.owned = false;
				return;
			}
		}
		
		if (_sinceBirth > 0)
			_sinceBirth--;
			
		if (_home == null)
		{
		// we need a house! check if there are any vacant ones...
			for (ch in _w.houses)
			{
				if (!ch.owned)
				{
					// my house!
					_home = ch;
					ch.owned = true;
				}
			}
		}
		
		
		/// if we're already doing something...
		if (_action > ACT_WALKDOWN)
		{
			switch(_action)
			{
				case ACT_TREE:
					ChopTree();
				case ACT_BUILD:
					BuildHouse();
				case ACT_BIRTH:
					BirthChild();
				case ACT_MINE:
					MineTunnel();
			}
		}
		else 
		{
			var t:Tree;
			t = null;
			if (!_underground && ((_home == null && _w.humanWood < 100) || _w.humanFood < 1000))
			{
				
				
				var closest:Float = FlxG.width * 2;
				var tDist:Float;
				_pos.y = _w.ground.points[Std.int(_pos.x)] - 1;
				
				/// find the nearest tree...
				for (t2 in _w.trees)
				{
					if (t2.status == Tree.STATUS_NORMAL && _pos.x > t2.x && _pos.x < t2.x + t2.width)
					{
						t = t2;
						_targetTree = t;
						t.status = Tree.STATUS_CUTTING;
						_action = ACT_TREE;
						break;
					}
				}
				
				if (_action != ACT_TREE)
				{
					for (t3 in _w.trees)
					{
						if (t3.status == Tree.STATUS_NORMAL)
						{
							tDist = Math.abs(FlxMath.getDistance(_pos, new FlxPoint((t3.x/2)+1, t3.y+t3.height)));
							if (tDist < closest)
							{
								t = t3;
								closest = tDist;
							}
						}
					}
				}
				
			}
			
			if (t != null && _action != ACT_TREE)
			{
				if ((t.x / 2) + 1 < _pos.x)
				{
					//Walk(DIR_LEFT)
					_action = ACT_WALKLEFT;
					
				}
				else
				{
					//Walk(DIR_RIGHT);
					_action = ACT_WALKRIGHT;
				}
			}
			else if (_action != ACT_TREE)
			{
				if (_underground && _pos.y < _w.ground.points[Std.int(_pos.x)])
				{
					_underground = false;
					_pos.y = _w.ground.points[Std.int(_pos.x)] - 1;
					_action = -1;
				}
				
				if (_action == ACT_WALKLEFT)
				{
					if (_pos.x > 10 || (_underground && (!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x - 1), Std.int(_pos.y), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x - 1), Std.int(_pos.y), _w.caves, 200) || _pos.y < _w.ground.points[Std.int(_pos.x)] + 16)))
						_action = -1;
				}
				
				if (_action == ACT_WALKRIGHT)
				{
					if (_pos.x < FlxG.width- 10 || (_underground && (!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x + 1), Std.int(_pos.y), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x + 1), Std.int(_pos.y), _w.caves, 200) || _pos.y < _w.ground.points[Std.int(_pos.x)] + 16)))
						_action = -1;
				}
				
				if (_action == ACT_WALKUP)
				{
					if (!_underground || (_pos.y -2 < _w.ground.points[Std.int(_pos.x)] || (!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y - 1), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y - 1), _w.caves, 200))))
						_action = -1;
				}
				
				if (_action == ACT_WALKDOWN)
				{
					if (!_underground || (_pos.y > FlxG.height - 10 || (!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y + 1), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x),Std.int(_pos.y + 1), _w.caves, 200))))
						_action = -1;
				}
				var bX:Int=0;
				var bY:Int=0;
				var avg:Float=0;
				
				if (_action == -1 || FlxRandom.chanceRoll(5))
				{
					// pick a new action!
					var acts:Array<Int> = new Array<Int>();
					acts.push(ACT_IDLE);
					if (_pos.x > 10)
					{
						if (!_underground || (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x-1),Std.int(_pos.y),_w.caves,50) && !FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x-1),Std.int(_pos.y),_w.caves,200)))
							acts.push(ACT_WALKLEFT);
					}
					if (_pos.x < FlxG.width - 10)
					{
						if (!_underground || (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x+1),Std.int(_pos.y),_w.caves,50) && !FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x+1),Std.int(_pos.y),_w.caves,200)))
							acts.push(ACT_WALKRIGHT);
					}
					if (_underground)
					{
						if (_pos.y -2 < _w.ground.points[Std.int(_pos.x)] || (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y-1), _w.caves, 50) && !FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y-1), _w.caves, 200)))
							acts.push(ACT_WALKUP);
						if (_pos.y < FlxG.height - 10 && (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x),Std.int(_pos.y+1), _w.caves, 50) && !FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x),Std.int(_pos.y+1), _w.caves, 200)))
							acts.push(ACT_WALKDOWN);
							
						acts.push(ACT_MINE);
					}
					else
					{
						if (_home == null && _w.humanWood > 100)
						{
							//var avg:Float;
							for (s in  Std.int(_pos.x - 4)...Std.int(_pos.x +3))
								avg += _w.ground.points[s];
							avg /= 7;
							
							bX = Std.int(_pos.x - 3);
							bY = Std.int(avg);
							
							var tmpS:FlxSprite = new FlxSprite(bX, bY-5).makeGraphic(7, 5, 0x00000000,true);
							if (!FlxG.overlap(_w.lyrHouses, tmpS) && !FlxG.overlap(_w.lyrTrees, tmpS))
								acts.push(ACT_BUILD);
							tmpS.kill();
						}
						
						if (_home != null)
						{
							if (_female)
							{
								if (_sinceBirth <= 0 && _w.humanFood >= 10)
									acts.push(ACT_BIRTH);
							}
							else
							{
								acts.push(ACT_MINE);
							}
						}
						
						for (t in _w.trees)
						{
							if (t.status == Tree.STATUS_NORMAL)
							{
								if (_pos.x > t.x && _pos.x < t.x + t.width)
								{
									acts.push(ACT_TREE);
									break;
								}
							}
						}
						
					}
					
					_action = acts[FlxRandom.intRanged(0, acts.length)];
					
					switch(_action)
					{
						case ACT_TREE:
							_targetTree = t;
							t.status = Tree.STATUS_CUTTING;
							
						case ACT_BUILD:
							var h:House = new House(_w, bX,bY);
							_w.houses.push(h);
							_w.lyrHouses.add(h);
							_building = h;
							_home = h;
							h.owned = true;
							_w.humanWood -= 100;
							
						case ACT_MINE:
							if (!_underground)
							{
								_pos.y = _w.ground.points[Std.int(_pos.x)];
								_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y),World.CORIENT_D);
								
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
					
				case ACT_WALKUP:
					Walk(DIR_UP);
					
				case ACT_WALKDOWN:
					Walk(DIR_DOWN);
					
			}
			
		}
		
	}
	
	private function MineTunnel():Void
	{
		
		if (!_underground)
		{
			_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y), World.CORIENT_D);
			_pos.y++;
			_underground = true;
		}
		else
		{
			
			if (_digDir == World.CORIENT_L)
			{
				if (_pos.x < 10 || _pos.y < _w.ground.points[Std.int(_pos.x)] + 16)
				{
					if (FlxRandom.chanceRoll(88))
						_digDir = World.CORIENT_D;
					else 
						_digDir = World.CORIENT_U;
				}
			}
			
			if (_digDir == World.CORIENT_R)
			{
				if (_pos.x > FlxG.width- 10 ||  _pos.y < _w.ground.points[Std.int(_pos.x)] + 16)
				{
					if (FlxRandom.chanceRoll(88))
						_digDir = World.CORIENT_D;
					else 
						_digDir = World.CORIENT_U;
				}
			}
			
			if (_digDir == World.CORIENT_U)
			{
				if (_pos.y  < _w.ground.points[Std.int(_pos.x)] )
					_digDir = -1;
			}
			
			if (_digDir == World.CORIENT_D)
			{
				if (_pos.y > FlxG.height - 10 )
					_digDir = -1;
			}
			
			if (_digDir != -1 && FlxRandom.chanceRoll(1)) 
			{	
				_digDir = -1;
				_action = -1;
			}
			else
			{
				var mDirs:Array<Int> = new Array<Int>();
				if (_digDir == -1 || _wait <=0)
				{
					_wait = FlxRandom.intRanged(5, 20);
					_digDir = -1;
					if (!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y + 2), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y + 2), _w.caves, 255) && _pos.y+1 < FlxG.height - 10)
					{
						mDirs.push(World.CORIENT_D);
					}
					if ((!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y - 2), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y - 2), _w.caves, 255)) && _pos.y >= _w.ground.points[Std.int(_pos.x)])
					{
						mDirs.push(World.CORIENT_U);
					}
					
					if (_pos.y > _w.ground.points[Std.int(_pos.x)] + 16)
					{
						if ((!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x+2), Std.int(_pos.y), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x+2), Std.int(_pos.y) , _w.caves, 255)) && _pos.x + 1 < FlxG.width-10)
						{
							mDirs.push(World.CORIENT_R);
						}
						if ((!FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x-2), Std.int(_pos.y), _w.caves, 50) || FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x-2), Std.int(_pos.y), _w.caves, 255)) && _pos.x - 1 > 10)
						{
							mDirs.push(World.CORIENT_L);
						}
					}
					
										
					if (mDirs.length > 0)
					{
						_digDir = mDirs[FlxRandom.intRanged(0, mDirs.length)];
					}
				}
				
				if (_digDir != -1)
				{
					_wait--;	
					_w.MakeCave(Std.int(_pos.x), Std.int(_pos.y), _digDir);
					Walk(_digDir);
				}
				else
				{
					_digDir	= -1;
					_action = -1;
				}
			}
		}
	}
	
	private function Walk(D:Int):Void
	{
		// don't WALK into MAGMA!
		switch(D)
		{
			case DIR_LEFT:
				if (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x - 1), Std.int(_pos.y), _w.lyrMagma, 255))
					return;
			case DIR_RIGHT:
				if (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x + 1), Std.int(_pos.y), _w.lyrMagma, 255))
					return;
			case DIR_UP:
				if (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x) , Std.int(_pos.y - 1), _w.lyrMagma, 255))
					return;
			case DIR_DOWN:
				if (FlxCollision.pixelPerfectPointCheck(Std.int(_pos.x), Std.int(_pos.y + 1), _w.lyrMagma, 255))
					return;
		}
		
		
		
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
	
	private function BirthChild():Void
	{
		if (!_atHome)
		{
			if (_home.x + 2 == _pos.x)
			{
				_atHome = true;
				_wait = FlxRandom.intRanged(80, 120);
				_home.birthing = true;
				
			}
			else if (_home.x + 2 > _pos.x)
			{
				_pos.x++;
			}
			else if (_home.x +2 < _pos.x)
			{
				_pos.x--;
			}
		}
		else
		{
			if (_wait > 0)
				_wait--;
			else
			{
				_sinceBirth = FlxRandom.intRanged(70,100);
				_atHome = false;
				_w.humanFood -= 10;
				_home.birthing = false;
				_w.SpawnGuy(Std.int(_pos.x));
				_action = -1;
			}
		}
	}
	
	private function BuildHouse():Void
	{
		if (_building == null)
		{
			_action = -1;
			return;
		}
		
		if (_building.health <= 50)
		{
			_building.build(FlxRandom.intRanged(0, 3));
		}
		else
		{
			_building = null;
			_action = -1;
		}
	}
	
	private function ChopTree():Void
	{
		if (_targetTree == null) 
		{
			_action = -1;
			return;
		}
		
		var wood:Int = FlxRandom.intRanged(0, 5);
		var food:Int = FlxRandom.intRanged(5, 10);
		
		if (wood*3 > _targetTree.health) 
			_targetTree.health = 0;
		else
			_targetTree.health -= wood*3;
		_w.humanWood += wood;
		_w.humanFood += food;
		
		if (_targetTree.health <= 0)
		{
			_targetTree.status = Tree.STATUS_CUTDOWN;
			_targetTree.kill();
			_targetTree = null;
			_action = -1;
		}
		
	}
	
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
	
	function get_underground():Bool 
	{
		return _underground;
	}
	
	public var underground(get_underground, null):Bool;
	
	function get_female():Bool 
	{
		return _female;
	}
	
	public var female(get_female, null):Bool;
	
	function get_atHome():Bool 
	{
		return _atHome;
	}
	
	public var atHome(get_atHome, null):Bool;
	
}