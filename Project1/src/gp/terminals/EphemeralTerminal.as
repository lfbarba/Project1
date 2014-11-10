package gp.terminals
{
	import gp.TNode;
	import gp.TTerminal;
	
	public class EphemeralTerminal extends TNode implements TTerminal
	{
		private var _value:Number;
		public function EphemeralTerminal()
		{
			super();
			_value = 1+Math.floor(Math.random() * 9);
		}
		
		public function setValue(v:Number):void {
			this._value = v;
		}
		
		override public function get value():* {
			return _value;
		}
		
		override public function get size():uint {
			return 1;
		}
		
		override public function get maxDepth():uint {
			return 0;
		}
		
		override public function toString():String {
			return String(_value);
		}
	}
}