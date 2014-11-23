package
{
	import ants.GridPixel;
	import ants.Simulator;
	
	import fl.controls.Button;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import gp.FuncionEvaluable;
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
		private var _simulator:Simulator;
		private var p:SimulationParameters;
		
		public function Test()
		{
			super();
			_simulator = new Simulator(true, -1);
			_simulator.y = 20;
			GridPixel.dropInPherormonePerTick = .05;
			_simulator.setAntFunction(optimalFunction);
			
			_simulator.setSimulation(40, 40);
			_simulator.changeTickTime(200);
			_simulator.setNest(20, 20);
			_simulator.numAnts = 100;
			_simulator.draw();
			
			this.addChild(_simulator);
			
			
			var button:Button = new Button;
			button.label = "Start";
			button.addEventListener(MouseEvent.CLICK, this.start);
			this.addChild(button);
			
			var pause:Button = new Button;
			pause.label = "Pause";
			pause.addEventListener(MouseEvent.CLICK, pauseHandler);
			this.addChild(pause);
			pause.x = 200;
			
			p = new SimulationParameters;
			this.addChild(p);
			p.x = 660;
			p.tickTimeSlider.addEventListener(SliderEvent.CHANGE, parametersChanged);
			p.numAntsSlider.addEventListener(SliderEvent.CHANGE, parametersChanged);
			p.amountFoodSlider.addEventListener(SliderEvent.CHANGE, parametersChanged);
			p.dropPherormonesSlider.addEventListener(SliderEvent.CHANGE, parametersChanged);
			//
			parametersChanged();
		}
		
		private function get optimalFunction():FuncionEvaluable {
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
			return f;
		}
		
		private function parametersChanged(e:SliderEvent = null):void {
			_simulator.changeTickTime(p.tickTimeSlider.value);
			_simulator.numAnts = p.numAntsSlider.value;
			p.numAntsText.text = String(p.numAntsSlider.value);
			GridPixel.dropInPherormonePerTick = p.dropPherormonesSlider.value;
			GridPixel.amountOfFoodPerClick = p.amountFoodSlider.value;
			//s.changeTickTime(0);
		}
		
		private function pauseHandler(e:MouseEvent):void {
			_simulator.pauseResumeSimulation();
			_simulator.resetSimulation();
		}
		
		private function start(e:MouseEvent):void {
			//_simulator.resetSimulation();
			//_simulator.setTrainingSimulation();
			_simulator.startSimulation();
		}
	}
}