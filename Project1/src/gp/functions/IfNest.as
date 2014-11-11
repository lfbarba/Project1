package gp.functions
{
	import ants.Ant;
	
	import gp.TFunction;
	import gp.TNode;

	public class IfNest extends TNode implements TFunction
	{
		private var arg1:TNode;
		private var arg2:TNode;
		
		public function IfNest()
		{
			super();
		}
		
		public function get numArguments():uint{
			return 2;
		}
		
		override public function get size():uint {
			setArgs();
			return 1+ arg1.size + arg2.size;
		}
		
		override public function get maxDepth():uint {
			setArgs();
			return 1+ Math.max(arg1.maxDepth, arg2.maxDepth);
		}
		
		private function setArgs():void {
			if(this.children.length != this.numArguments){
				throw(new Error("Childrens not assigned for IfNest function"));
			}
			arg1 = this.children[0];
			arg2 = this.children[1];
		}
		
		override public function get evaluate():* {
			setArgs();
			var a:Ant = Ant.currentAnt;
			if(a.isInNest){
				arg1.evaluate;
			}else{
				arg2.evaluate;
			}
		}
		
		override public function toString():String {
			if(this.children.length != this.numArguments){
				return "IfNest Function node, agrs not defined";
			}else{
				setArgs();
				return indent + "IF Nest then \n"+arg1.toString() +  "\n"+indent+"else \n" + arg2.toString();
			}
		}
	}
}