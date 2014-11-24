package gp.terminals
{
	import ants.Ant;
	
	import gp.TNode;
	import gp.TTerminal;
	import flash.utils.*;
	
	public class MoveToNest extends TNode implements TTerminal
	{

		public function MoveToNest()
		{
			super();
		}
		
		override public function get encoding():String {
			return String(flash.utils.getQualifiedClassName(this));
		}
		
		override public function get evaluate():* {
			var a:Ant = Ant.currentAnt;
			a.moveToNest();
		}
		
		override public function get size():uint {
			return 1;
		}
		
		override public function get maxDepth():uint {
			return 0;
		}
		
		override public function toString():String {
			return indent+"MoveToNest";
		}
	}
}