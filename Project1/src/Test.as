package
{
	import bkde.as3.parsers.CompiledObject;
	import bkde.as3.parsers.MathParser;
	
	import flash.display.Sprite;
	
	import gp.FunctionTree;
	
	public class Test extends Sprite
	{
		public function Test()
		{
			super();
			var mpExp:MathParser = new MathParser(["x"]);
			var mpVal:MathParser = new MathParser([   ]);
			
			var compobjExp:CompiledObject = new CompiledObject();
			var compobjVal:CompiledObject = new CompiledObject();
			
			compobjExp = mpExp.doCompile("4*x^2 - sin(3*x^3) + 4");
			compobjVal = mpVal.doCompile("1");
			
			if (compobjVal.errorStatus == 1) {
				trace(compobjVal.errorMes);
				return;
			}
			
			if (compobjExp.errorStatus == 1) {
				trace(compobjExp.errorMes);
				return;
			}
			
			trace(compobjExp);
			trace(compobjExp.PolishArray);
			
			var xVal:Number = mpVal.doEval(compobjVal.PolishArray, []);
			var resVal:Number = mpExp.doEval(compobjExp.PolishArray, [xVal]);
			
		}
	}
}