package gp.functions
{
	import ants.Ant;
	
	import gp.TFunction;
	import gp.TNode;
	import gp.terminals.MoveRandomly;

	public class IfFood extends TNode implements TFunction
	{
		private var arg1:TNode;
		
		public function IfFood()
		{
			super();
		}
		
		override public function get encoding():String {
			setArgs();
			var delimiter:String = "("+this.maxDepth+")";
			return String(flash.utils.getQualifiedClassName(this))+delimiter+arg1.encoding;
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
				throw(new Error("Childrens not assigned for IfFood function"));
			}
			arg1 = this.children[0];
		}
		
		override public function get evaluate():* {
			setArgs();
			var a:Ant = Ant.currentAnt;
			if(a.isThereFood){
				a.pickFood();
			}else{
				arg1.evaluate;
			}
		}
		
		override public function toString():String {
			if(this.children.length != this.numArguments){
				return "IfFood Function node, agrs not defined";
			}else{
				setArgs();
				return indent + "IF Food then \n"+indent+" PickFood\n"+indent+"else \n"+ arg1.toString();
			}
		}
	}
}