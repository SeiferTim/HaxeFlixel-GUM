package elements;
import flixel.FlxG;
import flixel.util.FlxRandom;

class MagmaParticle
{

	private var _x:Int;
	private var _y:Int;
	private var _temp:Float;
	private var _ageSinceLastMove:Float;
	
	public function new(X:Int, Y:Int):Void
	{
		_x = X;
		_y = Y;
		_temp = 1;
		_ageSinceLastMove = 0;
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
	
	public function update():Void
	{
		_ageSinceLastMove += FlxG.elapsed;
		
	}
	
	public function justMoved():Void
	{
		_ageSinceLastMove = 0;
	}
	
}