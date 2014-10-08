package
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import ga.Population;
	
	public class SimpleTSP extends Sprite
	{
		private var mainPopulation:Population;
		
		private var populationSize:uint = 500;
		private var genomeLength:uint = 50;
		
		private var mutationProbability:Number = .1;
		private var crossOverProbability:Number = .7;
		
		private var convergenceTreshhold:Number = .01;
		
		private var maxNumGenerations:uint = 200;
		private var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		public function SimpleTSP()
		{
			createPopulation();
			
			t = new Timer(1, 0);
			t.addEventListener(TimerEvent.TIMER, this.geneticAlgorithmMain);
			t.start();			
		}

		private function stopProcess():void {
			t.stop();
			trace("number of generations = ", numGenerations);
		}
		
		private function geneticAlgorithmMain(e:TimerEvent):void {
			if(this.populationHasConverged()){
				stopProcess();
			}else{
				runOneGeneration();
				printGeneration();
				trace("//////////////////");
				
				if(numGenerations == maxNumGenerations){
					trace("Maximum number of generations ("+maxNumGenerations+"), no convergence achieved");
					stopProcess();
				}
				numGenerations++;
			}
			this.graphics.beginFill(0);
			this.graphics.drawCircle(Math.random() * this.stage.stageWidth, Math.random() * this.stage.stageHeight, 5);
			this.graphics.endFill();
		}
		
		
		private function createProbabilityControlers():void {
			
		}
		
		private function populationHasConverged():Boolean {
			return mainPopulation.maximum > 1 - convergenceTreshhold;
		}
		
		private function printGeneration():void {
			mainPopulation.sortByFitness();
			for(var i:uint = 0; i< mainPopulation.size; i++){
				var bs:Individual = mainPopulation.getElement(i);
				trace(bs.toString());
			}
		}
		
		private function runOneGeneration():void {
			mainPopulation.sortByFitness(Array.DESCENDING);
			var n:uint = this.mainPopulation.size;
			
			//remove the lowest individuals
			while(mainPopulation.size > Math.ceil(n/2)){
				this.mainPopulation.removeLast();
			}
			//crear mutaciones
			this.createMutations();
			
			mainPopulation.computePopulationFitness();
			
			//choose the individuals to reproduce
			var toReproduce:Population = new Population;
			for(var i:uint = 0; i< mainPopulation.size; i++){
				if(Math.random() < this.crossOverProbability){
					toReproduce.addElement(this.mainPopulation.getElement(i));
				}
			}
			toReproduce.computePopulationFitness();
			
			//empty population
			this.mainPopulation = new Population;
			
			//reproduce the strings
			while(toReproduce.size > 0 && mainPopulation.size < this.populationSize){
				var bs1:Individual = toReproduce.chooseAnIndividualAtRandomWithFitness();
				var bs2:Individual = toReproduce.chooseAnIndividualAtRandomWithFitness();
				reproduceAndAddToMainPopulation(bs1, bs2);
			}
		}
		
		
		private function reproduceAndAddToMainPopulation(bs1:Individual, bs2:Individual):void{
			//cross over or reinstert them into pupulation
			if(Math.random() < this.crossOverProbability){
				var children:Array = bs1.partiallyMappedCrossOver(bs2);
				var c0:Individual = children[0] as Individual;
				var c1:Individual = children[1] as Individual;
				mainPopulation.addElement(c0);
				mainPopulation.addElement(c1);
			}else{
				mainPopulation.addElement(bs1);
				mainPopulation.addElement(bs2);
			}
		}
		
		private function createMutations():void {
			for(var i:uint = 0; i< mainPopulation.size; i++){
				var bs:Individual = mainPopulation.getElement(i);
				if(Math.random() < this.mutationProbability){
					bs.mutate();
				}
			}
		}
		
		
		
		private function createPopulation():void {
			mainPopulation = new Population;	
			for(var i:uint = 0; i< populationSize; i++){
				mainPopulation.addElement(new Individual(genomeLength));
			}
		}
	}
}