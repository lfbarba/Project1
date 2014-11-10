package gp.functions
{
	import gp.TFunction;
	import gp.TNode;

	public class SineFunction extends TNode implements TFunction
	{
		private var arg1:TNode;
		
		public function SineFunction()
		{
			super();
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
				throw(new Error("Childrens not assigned for sine function"));
			}
			arg1 = this.children[0];
		}
		
		override public function get value():* {
			setArgs();
			return Math.sin(arg1.value);
		}
		
		override public function toString():String {
			if(this.children.length != this.numArguments){
				return "Sine Function node, agrs not defined";
			}else{
				setArgs();
				return "sin("+arg1.toString()+")";
			}
		}
	}
}