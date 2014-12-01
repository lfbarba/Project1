package gp.functions
{
	import flash.display.Sprite;
	
	import gp.TFunction;
	import gp.TNode;

	public class SubstractFunction extends TNode implements TFunction
	{
		private var arg1:TNode;
		private var arg2:TNode;
		public static var icon:Sprite = new substractIcon as Sprite;
		
		public function SubstractFunction()
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
				throw(new Error("Childrens not assigned for Substract function"));
			}
			arg1 = this.children[0];
			arg2 = this.children[1];
		}
		
		override public function get value():* {
			setArgs();
			return arg1.value - arg2.value;
		}
		
		override public function toString():String {
			if(this.children.length != this.numArguments){
				return "Substract Function node, agrs not defined";
			}else{
				setArgs();
				return "("+arg1.toString() + " - "+ arg2.toString()+")";
			}
		}
	}
}