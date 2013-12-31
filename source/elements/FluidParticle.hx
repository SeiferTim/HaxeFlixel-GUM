package elements;
import flixel.FlxG;
import flixel.util.FlxRandom;

class FluidParticle
{

	private var _x:Int;
	private var _y:Int;
	private var _temp:Float;
	private var _ageSinceLastMove:Float;
	private var _age:Float;
	private var _onUpdate:Dynamic;
	
	public function new(X:Int, Y:Int, OnUpdate:Dynamic):Void
	{
		_x = X;
		_y = Y;
		_temp = 1;
		_ageSinceLastMove = 0;
		_age = 0;
		_onUpdate = OnUpdate;
	}
	
	function get_x():Int 
	{
		return _x;
	}
	
	function set_x(value:Int):Int 
	{
		return _x = value;
	}
	
	public var x(get_x, set_x):Int;
	
	function get_y():Int 
	{
		return _y;
	}
	
	function set_y(value:Int):Int 
	{
		return _y = value;
	}
	
	public var y(get_y, set_y):Int;
	
	function get_temp():Float 
	{
		return _temp;
	}
	
	function set_temp(value:Float):Float 
	{
		return _temp = value;
	}
	
	public var temp(get_temp, set_temp):Float;
	
	function get_ageSinceLastMove():Float 
	{
		return _ageSinceLastMove;
	}
	
	public var ageSinceLastMove(get_ageSinceLastMove, null):Float;
	
	function get_age():Float 
	{
		return _age;
	}
	
	public var age(get_age, null):Float;
	
	public function update():Void
	{
		_ageSinceLastMove += FlxG.elapsed;
		_age += FlxG.elapsed;
		if (_age > 100) _age = 100;
		if (_ageSinceLastMove > 100) _ageSinceLastMove = 100;
		if (_onUpdate != null)
		{
			Reflect.callMethod(null, _onUpdate, [this]);
		}
		
	}
	
	public function justMoved():Void
	{
		_ageSinceLastMove = 0;
	}
	
}