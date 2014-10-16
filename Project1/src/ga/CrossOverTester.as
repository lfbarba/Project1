package ga
{
	import fl.data.DataProvider;
	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	public class CrossOverTester extends CrossOverTesterFrame
	{
		private var a:Individual;
		private var b:Individual;
		
		public function CrossOverTester()
		{
			super();
			//set up combo
			var options:Array = new Array;
			options.push({label:"Ordered Partially Mapped Crossover", value: 0});
			options.push({label:"Parallel Partially Mapped Crossover", value: 1});
			options.push({label:"Ordered Position Based Crossover", value: 2});
			options.push({label:"Parallel Position Based Crossover", value: 3});
			
			var dp:DataProvider = new DataProvider(options);
			this.crossOverFunction.dataProvider = dp;
			
			this.computeChildrenButton.addEventListener(MouseEvent.CLICK, computeChildrenHandler);
			this.closeButton.addEventListener(MouseEvent.CLICK, closeTester);
			
			this.visible = false;
			
		}
		
		private function closeTester(e:MouseEvent):void {
			this.visible = false;
		}
		
		public function testTwoRandomIndividuals(length:uint) {
			this.visible = true;
			
			a = new Individual(length);
			b = new Individual(length);
			trace(a.genome.join(","));
			this.firstGenome.text = a.genome.join(",");
			this.secondGenome.text = b.genome.join(",");
			this.firstChild.text = "";
			this.secondChild.text = "";
		}
		
		
		private function computeChildrenHandler(e:MouseEvent):void {
			var children:Array;
			switch(this.crossOverFunction.selectedItem.value){
				case 0: 
					children = a.partiallyMappedCrossover(b, true);
					break;
				case 1: 
					children = a.partiallyMappedCrossover(b, false);
					break;
				case 2: 
					children = a.randomInjectionBasedCrossOver(b, true);
					break;
				case 2: 
					children = a.randomInjectionBasedCrossOver(b, false);
					break;
			}
			
			var c1:Individual = children[0] as Individual;
			var c2:Individual = children[1] as Individual;
			
			this.firstChild.text = c1.genome.join(",");
			this.secondChild.text = c2.genome.join(",");
		}
	}
}