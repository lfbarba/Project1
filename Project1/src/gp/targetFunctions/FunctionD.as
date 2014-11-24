package gp.targetFunctions
{
	import flash.display.Sprite;
	
	import gp.FuncionEvaluable;

	public class FunctionD implements FuncionEvaluable
	{
		public function FunctionD()
		{
		}
		
		public function evaluate(x:Number):Number
		{
			return x*x/3 + 2*x - 9;
		}
		
		public function get heightInInterval():uint{
			return 30;
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
			return "x^2/3 + 2*x - 9";
		}
	}
}