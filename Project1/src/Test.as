package
{
	import ants.GridPixel;
	import ants.Simulator;
	
	import fl.controls.Button;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
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
		private var s:Simulator;
		private var p:SimulationParameters;
		
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
			
			s = new Simulator(40, 40, 100, true);
			s.changeTickTime(100);
			s.graphic = true;
			s.setNest(15, 10);
			s.draw();
			s.setAntFunction(f);
			this.addChild(s);
			s.y = 20;
			
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
		
		private function parametersChanged(e:SliderEvent = null):void {
			s.changeTickTime(p.tickTimeSlider.value);
			s.numAnts = p.numAntsSlider.value;
			p.numAntsText.text = String(p.numAntsSlider.value);
			GridPixel.dropInPherormonePerTick = p.dropPherormonesSlider.value;
			GridPixel.dropFoodRadiusOnDoubleClick = p.amountFoodSlider.value;
		}
		
		private var _paused:Boolean = false;
		private function pauseHandler(e:MouseEvent):void {
			if(_paused == false){
				s.pauseSimulation();
				_paused = true;
			}else{
				s.resumeSimulation();
				_paused = false;
			}
		}
		
		private function start(e:MouseEvent):void {
			s.startSimulation();
		}
	}
}