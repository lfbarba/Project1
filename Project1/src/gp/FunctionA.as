package gp
{
	public class FunctionA implements FuncionEvaluable
	{
		public function FunctionA()
		{
		}
		
		public function evaluate(x:Number):Number
		{
			return 1 + 3*Math.pow(x, 3) + 2*Math.pow(x,2) + x;
		}
	}
}