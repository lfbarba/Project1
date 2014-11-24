package gp.terminals
{
	import ants.Ant;
	
	import gp.TNode;
	import gp.TTerminal;
	
	public class MoveToNest extends TNode implements TTerminal
	{

		public function MoveToNest()
		{
			super();
		}
		
		override public function get encoding():String {
			return "MoveToNest";
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