package
{
	import flash.display.Sprite;
	
	import gp.FunctionTree;
	
	public class Test extends Sprite
	{
		public function Test()
		{
			super();
			var tree:FunctionTree = new FunctionTree;
			var tree2:FunctionTree = new FunctionTree;
			tree.initializeRandomly(1, true);
			tree2.initializeRandomly(1, true);
			
			
			trace(tree.toString(), "value", tree.evaluate(10), "size", tree.size, "depth", tree.maxDepth);
			trace(tree2.toString(), "value", tree2.evaluate(10), "size", tree2.size, "depth", tree2.maxDepth);
			//
			var children:Array = tree.crossOver(tree2, false);
			trace(children[0].toString(), "value", children[0].evaluate(10), "size", children[0].size, "depth", children[0].maxDepth);
			trace(children[1].toString(), "value", children[1].evaluate(10), "size", children[1].size, "depth", children[1].maxDepth);
		}
	}
}