package gp.terminals
{
	import ants.Ant;
	
	import gp.TNode;
	import gp.TTerminal;
	import flash.utils.*;
	
	public class MoveToPherormone extends TNode implements TTerminal
	{

		public function MoveToPherormone()
		{
			super();
		}
		
		override public function encoding(depth:uint):String {
			return String(flash.utils.getQualifiedClassName(this));
		}
		
		override public function get evaluate():* {
			var a:Ant = Ant.currentAnt;
			a.moveToPherormone();
		}
		
		override public function get size():uint {
			return 1;
		}
		
		override public function get maxDepth():uint {
			return 0;
		}
		
		override public function toString():String {
			return indent+"MoveToPherormone";
		}
	}
}