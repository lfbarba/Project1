package ants
{
	import flash.events.Event;
	
	public class TickEvent extends Event
	{
		public var withReset:Boolean = false;	
		public static var TICK_EVENT:String = "TickEvent";
		public function TickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}