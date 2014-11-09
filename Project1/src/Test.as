package
{
	import flash.display.Sprite;
	
	import gp.FunctionTree;
	
	import grapher.Grapher;
	
	public class Test extends Sprite
	{
		public function Test()
		{
			super();
			var grapher:Grapher = new Grapher(400, 300, -5.2, 5.5);
			this.addChild(grapher);
		}
	}
}