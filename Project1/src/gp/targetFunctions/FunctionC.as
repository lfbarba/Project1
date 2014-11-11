package gp.targetFunctions
{
	import flash.display.Sprite;
	
	import gp.FuncionEvaluable;

	public class FunctionC implements FuncionEvaluable
	{
		public function FunctionC()
		{
		}
		
		public function evaluate(x:Number):Number
		{
			return 3*Math.sin(Math.pow(x,2)) + 3* Math.pow(x, 2) + 3*Math.cos(x/4)
		}
		
		public function get heightInInterval():uint{
			return 100;
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
			return "3*sin(x^2) + 3x^2 + 3*cos(x/4)";
		}
	}
}