package gp.targetFunctions
{
	import bkde.as3.parsers.CompiledObject;
	import bkde.as3.parsers.MathParser;
	
	import flash.display.Sprite;
	
	import gp.FuncionEvaluable;

	public class CustomFunction implements FuncionEvaluable
	{
		
		var mpExp:MathParser;
		var compobjExp:CompiledObject;
		public function CustomFunction()
		{
			mpExp= new MathParser(["x"]);
		}
		
		public function setFunction(s:String):void {
			compobjExp = mpExp.doCompile(s);
			if (compobjExp.errorStatus == 1) {
				compobjExp = mpExp.doCompile("0");
			}
		}
		
		public function evaluate(x:Number):Number
		{
			var resVal:Number = mpExp.doEval(compobjExp.PolishArray, [x]);
			return resVal;
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
			return "Write your own function";
		}
	}
}