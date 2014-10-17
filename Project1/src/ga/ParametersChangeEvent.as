package ga
{
	import flash.events.Event;
	
	public class ParametersChangeEvent extends Event
	{
		public static var PARAMETERS_CHANGE:String = "ParametersChange";
		
		public var parameters:Parameters;
		
		public function ParametersChangeEvent(type:String, p:Parameters)
		{
			this.parameters = p;
			super(type, bubbles, cancelable);
		}
	}
}