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
			tree.generateRandomly(3, true);
			tree2.generateRandomly(3, true);
			
			trace(tree.toString(), "value", tree.evaluate(10), "size", tree.size, "depth", tree.maxDepth);
			trace(tree.chooseRandomNode(3));
			
			/*trace(tree.toString(), "value", tree.evaluate(10), "size", tree.size, "depth", tree.maxDepth);
			trace(tree2.toString(), "value", tree2.evaluate(10), "size", tree2.size, "depth", tree2.maxDepth);
			//
			tree.crossOver(tree2);
			trace(tree.toString(), "value", tree.evaluate(10), "size", tree.size, "depth", tree.maxDepth);
			trace(tree2.toString(), "value", tree2.evaluate(10), "size", tree2.size, "depth", tree2.maxDepth);*/
		}
	}
}