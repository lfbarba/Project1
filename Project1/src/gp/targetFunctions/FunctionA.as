package gp.targetFunctions
{
	import flash.display.Sprite;
	
	import gp.FuncionEvaluable;

	public class FunctionA implements FuncionEvaluable
	{
		public function FunctionA()
		{
		}
		
		public function evaluate(x:Number):Number
		{
			return 1 + 3*Math.pow(x, 3) + 2*Math.pow(x,2) + x;
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
			return "3x^3 + 2x^2 + x + 1";
		}
	}
}