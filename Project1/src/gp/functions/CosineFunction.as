package gp.functions
{
	import flash.display.Sprite;
	
	import gp.TFunction;
	import gp.TNode;

	public class CosineFunction extends TNode implements TFunction
	{
		private var arg1:TNode;
		
		public static var icon:Sprite = new cosIcon as Sprite;
		
		public function CosineFunction()
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
				throw(new Error("Childrens not assigned for cosine function"));
			}
			arg1 = this.children[0];
		}
		
		override public function get value():* {
			setArgs();
			return Math.cos(arg1.value);
		}
		
		override public function toString():String {
			if(this.children.length != this.numArguments){
				return "Cosine Function node, agrs not defined";
			}else{
				setArgs();
				return "cos("+arg1.toString()+")";
			}
		}
	}
}