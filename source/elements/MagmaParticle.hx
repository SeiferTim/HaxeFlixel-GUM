package elements;

class MagmaParticle
{

	private var _x:Int;
	private var _y:Int;
	private var _temp:Float;
	
	public function new(X:Int, Y:Int):Void
	{
		_x = X;
		_y = Y;
		_temp = 1;
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
	
}