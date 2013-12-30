package elements;
import flash.geom.Rectangle;
import flixel.util.FlxRect;

class DwarfRoom
{

	static public inline var TYPE_HOUSING:Int = 0;
	static public inline var TYPE_FARM:Int = 1;
	static public inline var TYPE_STORAGE:Int = 2;
	
	private var _rect:FlxRect;
	private var _roomtype:Int;
	private var _full:Bool;
	
	public function new(X:Int, Y:Int, Width:Int, Height:Int, RoomType:Int ) 
	{
		_rect = new FlxRect(X, Y, Width, Height);
		_roomtype = RoomType;
		_full = false;
	}
	
	function get_rect():FlxRect 
	{
		return _rect;
	}
	
	public var rect(get_rect, null):FlxRect;
	
	function get_roomtype():Int 
	{
		return _roomtype;
	}
	
	public var roomtype(get_roomtype, null):Int;
	
	function get_full():Bool 
	{
		return _full;
	}
	
	function set_full(value:Bool):Bool 
	{
		return _full = value;
	}
	
	public var full(get_full, set_full):Bool;
	
}