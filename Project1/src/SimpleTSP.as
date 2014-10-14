package
{
	import fl.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import ga.PointSet;
	import ga.Population;
	import ga.TspPoint;
	
	public class SimpleTSP extends Sprite
	{
		private var mainPopulation:Population;
		
		private var populationSize:uint = 500;
		private var genomeLength:uint;
		
		private var mutationProbability:Number = .1;
		private var crossOverProbability:Number = .7;
		
		private var convergenceTreshhold:Number = .01;
		
		private var maxNumGenerations:uint = 200;
		private var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		public static var CURRENT_POINTSET:PointSet;
		
		private var progressExampleLayer:Sprite;
		
		private var startButton:Button;
		
		public function SimpleTSP()
		{
			var ps:PointSet = new PointSet;
			this.setPointSet(ps);
			
			t = new Timer(1, 0);
			t.addEventListener(TimerEvent.TIMER, this.geneticAlgorithmMain);
			
			this.stage.doubleClickEnabled = true;
			this.stage.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			
			//botton para iniciar
			startButton = new Button;
			startButton.x = startButton. y = 20;
			startButton.label = "Iniciar GA";
			this.addChild(startButton);
			startButton.addEventListener(MouseEvent.CLICK, this.startGeneticAlgorithm);
			
		}
		
		private function doubleClickHandler(e:MouseEvent):void {
			var p:TspPoint = new TspPoint(e.stageX, e.stageY);
			CURRENT_POINTSET.addPoint(p);
		}
		
		public function setPointSet(ps:PointSet):void {
			CURRENT_POINTSET = ps;
			this.addChild(CURRENT_POINTSET);
		}
		
		private function startGeneticAlgorithm(e:MouseEvent):void {
			genomeLength = CURRENT_POINTSET.points.length;
			createPopulation();
			this.printGeneration();
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
		}
		
		
		private function createProbabilityControlers():void {
			
		}
		
		
		var counter:uint = 0;
		private function populationHasConverged():Boolean {
			if(counter < 200){
				counter++;
				return false;
			}else{
				return true;
			}
		}
		
		private function printGeneration():void {
			mainPopulation.sortByFitness();
			for(var i:uint = 0; i< mainPopulation.size; i++){
				var bs:Individual = mainPopulation.getElement(i);
				trace(bs.toString());
			}
		}
		
		private function showIndividual(p:Individual):void {
			if(progressExampleLayer != null && this.contains(progressExampleLayer)){
				this.removeChild(progressExampleLayer);
			}
			progressExampleLayer = new Sprite;
			this.addChild(progressExampleLayer);
			progressExampleLayer.addChild(p.drawIndividual());
		}
		
		private function runOneGeneration():void {
			mainPopulation.sortByFitness();
			//show the best individual so far
			this.showIndividual(mainPopulation.getElement(0));
			
			var n:uint = this.mainPopulation.size;
			
			//remove the lowest individuals
			while(mainPopulation.size > Math.ceil(n/2)){
				this.mainPopulation.removeLast();
			}
			//crear mutaciones
			//this.createMutations();
			
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
				var children:Array;
				//select crossover randomly
				if(Math.random() < .5){
					children = bs1.orderPartiallyMappedCrossover(bs2);
				}else{
					children = bs1.positionBasedCrossOver(bs2);
				}
				//
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