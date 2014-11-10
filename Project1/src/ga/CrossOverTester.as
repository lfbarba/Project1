package ga
{
	import fl.data.DataProvider;
	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import gp.FunctionTree;

	public class CrossOverTester extends CrossOverTesterFrame
	{
		private var a:FunctionTree;
		private var b:FunctionTree;
		
		public function CrossOverTester()
		{
			super();
			//set up combo
			var options:Array = new Array;
			options.push({label:"Reversed Partially Mapped Crossover", value: Parameters.ReversedPartiallyMappedCrossover});
			options.push({label:"Ordered Partially Mapped Crossover", value: Parameters.OrderedPartiallyMappedCrossover});
			options.push({label:"Parallel Partially Mapped Crossover", value: Parameters.ParallelPartiallyMappedCrossover});
			options.push({label:"Ordered Position Based Crossover", value: Parameters.OrderedPositionBasedCrossover});
			options.push({label:"Parallel Position Based Crossover", value: Parameters.ParallelPositionBasedCrossover});
			
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
			
			a = new FunctionTree(length);
			b = new FunctionTree(length);
			this.firstGenome.text = a.genome.join(",");
			this.secondGenome.text = b.genome.join(",");
			this.firstChild.text = "";
			this.secondChild.text = "";
		}
		
		
		private function computeChildrenHandler(e:MouseEvent):void {
			var children:Array;
			var itemsFromAInC1:Array = new Array;
			var itemsFromBInC2:Array= new Array;
			switch(this.crossOverFunction.selectedItem.value){
				case Parameters.ReversedPartiallyMappedCrossover: 
					children = a.partiallyMappedCrossover(b, true, true, itemsFromAInC1, itemsFromBInC2);
					break;
				case Parameters.OrderedPartiallyMappedCrossover: 
					children = a.partiallyMappedCrossover(b, true, false, itemsFromAInC1, itemsFromBInC2);
					break;
				case Parameters.ParallelPartiallyMappedCrossover: 
					children = a.partiallyMappedCrossover(b, false, false, itemsFromAInC1, itemsFromBInC2);
					break;
				case Parameters.OrderedPositionBasedCrossover: 
					children = a.randomInjectionBasedCrossOver(b, true, itemsFromAInC1, itemsFromBInC2);
					break;
				case Parameters.ParallelPositionBasedCrossover: 
					children = a.randomInjectionBasedCrossOver(b, false, itemsFromAInC1, itemsFromBInC2);
					break;
			}
			
			var c1:FunctionTree = children[0] as FunctionTree;
			var c2:FunctionTree = children[1] as FunctionTree;
			
			
			for(var i:uint = 0; i < c1.genome.length; i++){
				if(c1.genome[i] != undefined && itemsFromAInC1[c1.genome[i]] == true){
					c1.genome[i] = "<b>"+c1.genome[i]+"</b>";
				}
				if(c2.genome[i] != undefined && itemsFromBInC2[c2.genome[i]] == true){
					c2.genome[i] = "<b>"+c2.genome[i]+"</b>";
				}
			}
			
			
			this.firstChild.htmlText = c1.genome.join(",");
			this.secondChild.htmlText = c2.genome.join(",");
		}
	}
}