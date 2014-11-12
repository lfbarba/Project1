package
{
	import ants.Simulator;
	
	import flash.display.Sprite;
	
	import gp.FunctionTree;
	import gp.functions.DropFood;
	import gp.functions.DropPherormone;
	import gp.functions.IfCarryingFood;
	import gp.functions.IfFood;
	import gp.functions.IfNest;
	import gp.functions.IfPherormone;
	import gp.terminals.MoveRandomly;
	import gp.terminals.MoveToNest;
	import gp.terminals.MoveToPherormone;
	
	public class Test extends Sprite
	{
		public function Test()
		{
			super();
			var f:FunctionTree = new FunctionTree;
			f.root = new IfCarryingFood;
			var a:IfNest = new IfNest;
			var d:DropFood = new DropFood;
			d.addChild(new MoveToNest);
			a.addChild(d);
			var h:DropPherormone = new DropPherormone;
			h.addChild(new MoveToNest);
			a.addChild(h);
			f.root.addChild(a);
			//
			var b:IfFood = new IfFood;
			var c:IfPherormone = new IfPherormone;
			c.addChild(new MoveToPherormone);
			c.addChild(new MoveRandomly);
			b.addChild(c);
			f.root.addChild(b);
			trace(f);
			
			var s:Simulator = new Simulator(40, 40, 100, true);
			s.graphic = true;
			s.dropPileOfFood(30, 10, 5);
			s.dropPileOfFood(28, 14, 5);
			s.dropPileOfFood(30, 30, 10);
			s.setNest(15, 10);
			s.draw();
			s.setAntFunction(f);
			this.addChild(s);
			s.startSimulation();
		}
	}
}