package gp.terminals
{
	import gp.TNode;
	import gp.TTerminal;
	
	public class VariableTerminal extends TNode implements TTerminal
	{
		public static var XVALUE:Number;
		
		public function VariableTerminal()
		{
			super();
		}
		
		override public function get value():* {
			return XVALUE;
		}
		
		override public function get size():uint {
			return 1;
		}
		
		override public function get maxDepth():uint {
			return 0;
		}
		
		override public function toString():String {
			return "x";
		}
	}
}