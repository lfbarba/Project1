package gp.targetFunctions
{
	import flash.display.Sprite;
	
	import gp.FuncionEvaluable;

	public class FunctionB implements FuncionEvaluable
	{
		public function FunctionB()
		{
		}
		
		public function evaluate(x:Number):Number
		{
			return Math.cos(x) + 3* Math.sin(Math.pow(x, 2));
		}
		
		public function get heightInInterval():uint{
			return 10;
		}
		
		public function get label():String {
			return this.toString();
		}
		
		public function get value():uint {
			return 0;
		}
		
		public function get icon():Sprite {
			return null;
		}
		
		public function toString():String {
			return "cos(x) + 3*sin(x^2)";
		}
	}
}