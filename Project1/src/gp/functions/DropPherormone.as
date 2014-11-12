package gp.functions
{
	import ants.Ant;
	
	import gp.TFunction;
	import gp.TNode;
	import gp.TTerminal;
	
	public class DropPherormone extends TNode implements TFunction
	{
		private var arg1:TNode;
		
		public function DropPherormone()
		{
			super();
		}
		
		override public function get evaluate():* {
			setArgs();
			var a:Ant = Ant.currentAnt;
			a.dropPherormone();
			arg1.evaluate;
		}

		public function get numArguments():uint{
			return 1;
		}
		
		override public function get size():uint {
			setArgs();
			return 1+ arg1.size;
		}
		
		override public function get maxDepth():uint {
			setArgs();
			return 1+ arg1.maxDepth;
		}
		
		private function setArgs():void {
			if(this.children.length != this.numArguments){
				throw(new Error("Childrens not assigned for DropPherormone function"));
			}
			arg1 = this.children[0];
		}
		
		override public function toString():String {
			setArgs();
			return indent+"DropPherormone"+"\n"+ arg1.toString();;
		}
	}
}