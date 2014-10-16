package
{
	import fl.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import ga.CrossOverTester;
	import ga.PointSet;
	import ga.Population;
	import ga.TspPoint;
	
	public class SimpleTSP extends Sprite
	{
		private var mainPopulation:Population;
		
		private var populationSize:uint = 300;
		private var genomeLength:uint;
		
		private var mutationProbability:Number = 1;
		private var crossOverProbability:Number = .8;
		
		
		private var convergenceTreshhold:Number = .000001;
		
		private var maxNumGenerations:uint = 1000;
		private var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		public static var CURRENT_POINTSET:PointSet;
		
		private var progressExampleLayer:Sprite;
		
		private var visualLayer:Sprite;
		
		private var bestIndividual:Individual;
		private var bestFitness:Number = -1* Population.POPULATION_BAD_TRESHHOLD;
		
		private var startButton:Button;
		private var stopButton:Button;
		private var openTester:Button;
		
		private var crossOverTester:CrossOverTester;
		
		public function SimpleTSP()
		{
			visualLayer = new Sprite;
			this.addChild(visualLayer);
			this.addEventListener(Event.ENTER_FRAME, fitIntoScreen);
			
			var ps:PointSet = new PointSet;
			ps.readFromFile("berlin52.txt");
			//ps.createPointInCricle();
			this.setPointSet(ps);
			
			t = new Timer(1, 0);
			t.addEventListener(TimerEvent.TIMER, this.geneticAlgorithmMain);
			
			this.stage.doubleClickEnabled = true;
			this.stage.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			
			//botton para iniciar
			startButton = new Button;
			stopButton = new Button;
			startButton.x = startButton. y  = stopButton.y = 20;
			stopButton.x = 140;
			startButton.label = "Start GA";
			stopButton.label = "Stop GA";
			this.addChild(startButton);
			this.addChild(stopButton);
			startButton.addEventListener(MouseEvent.CLICK, this.startGeneticAlgorithm);
			stopButton.addEventListener(MouseEvent.CLICK, this.stopProcess);
			//
			this.openTester = new Button;
			openTester.label = "CrossoverTester";
			openTester.x = 20;
			openTester.y = this.stage.stageHeight - 40;
			this.addChild(openTester);
			openTester.addEventListener(MouseEvent.CLICK, openCrossoverTester);
			//
			crossOverTester = new CrossOverTester;
			crossOverTester.x = this.stage.stageWidth/2;
			crossOverTester.y = this.stage.stageHeight/2;
			this.addChild(crossOverTester);
		}
		
		private function openCrossoverTester(e:MouseEvent):void {
			this.crossOverTester.testTwoRandomIndividuals(16);
		}
		
		private function fitIntoScreen(e:Event = null){
			var w:Number = CURRENT_POINTSET.width;
			var h:Number = CURRENT_POINTSET.height;
			var ratio:Number = Math.max(w/this.stage.stageWidth, h / this.stage.stageHeight);
			if(ratio > 1){
				visualLayer.scaleX = 1/ratio;
				visualLayer.scaleY = -1/ratio;
				visualLayer.y = this.stage.stageHeight;
			}
		}
		
		private function doubleClickHandler(e:MouseEvent):void {
			var p:TspPoint = new TspPoint(e.stageX, e.stageY);
			CURRENT_POINTSET.addPoint(p);
		}
		
		public function setPointSet(ps:PointSet):void {
			CURRENT_POINTSET = ps;
			visualLayer.addChild(CURRENT_POINTSET);
		}
		
		private function startGeneticAlgorithm(e:MouseEvent):void {
			numGenerations = 0;
			genomeLength = CURRENT_POINTSET.points.length;
			createPopulation();
			//this.printGeneration();
			t.start();
		}

		private function stopProcess(e:MouseEvent = null):void {
			t.stop();
			trace("number of generations = ", numGenerations);
			mainPopulation.printStatistics();
			trace("Best fitness", Population.POPULATION_BAD_TRESHHOLD - this.bestFitness);
			this.bestFitness = -1*Population.POPULATION_BAD_TRESHHOLD;
			this.bestIndividual = null;
		}
		
		
		
		private function geneticAlgorithmMain(e:TimerEvent):void {
			if(this.populationHasConverged()){
				stopProcess();
			}else{
				runOneGeneration();
				//
				numGenerations++;
				if(numGenerations % 50 == 0)
					trace("Running generation", numGenerations,"Best", Math.floor(Population.POPULATION_BAD_TRESHHOLD - this.bestFitness),
					"Current" , Math.round(Population.POPULATION_BAD_TRESHHOLD -mainPopulation.maximum));
			}
		}
		
		
		var counter:uint = 0;
		private function populationHasConverged():Boolean {
			if(this.mainPopulation.maximum - this.mainPopulation.average < this.convergenceTreshhold &&
				this.mainPopulation.average - this.mainPopulation.minimum < this.convergenceTreshhold ){
				trace("Convergence achieved");
				return true;
			}
			return false;
		}
		
		private function printGeneration():void {
			mainPopulation.sortByFitness(Array.DESCENDING || Array.NUMERIC);
			for(var i:uint = 0; i< mainPopulation.size; i++){
				var bs:Individual = mainPopulation.getElement(i);
				trace(bs.toString());
			}
		}
		
		private function showIndividual(p:Individual):void {
			if(progressExampleLayer != null && visualLayer.contains(progressExampleLayer)){
				visualLayer.removeChild(progressExampleLayer);
			}
			progressExampleLayer = new Sprite;
			visualLayer.addChild(progressExampleLayer);
			if(bestIndividual != null)
				progressExampleLayer.addChild(bestIndividual.drawIndividual(0x0000FF, 6));
			progressExampleLayer.addChild(p.drawIndividual());	
		}
		
		private function runOneGeneration():void {
			//crear mutaciones
			mainPopulation.sortByFitness(Array.DESCENDING | Array.NUMERIC);
			//show the best individual so far
			var best:Individual = mainPopulation.getElement(0);
			if(best.fitness  >  bestFitness){
				bestFitness = best.fitness;
				bestIndividual = new Individual(best.length, true, best.genome);
			}
			this.showIndividual(mainPopulation.getElement(0));
			
			mainPopulation.computePopulationFitness();
			
			var newPopulation:Population = new Population
			
			//reproduce the strings
			while(newPopulation.size < this.populationSize){
				var bs1:Individual;
				var bs2:Individual;
				if(Math.random() < .2){
					bs1 = mainPopulation.chooseWithTournamentSelection();
					bs2 = mainPopulation.chooseWithTournamentSelection();
				}else{
					bs1 = mainPopulation.chooseWithRouletteWheelSelection();
					bs2 = mainPopulation.chooseWithRouletteWheelSelection();
				}
				reproduceAndAddToPopulation(bs1, bs2, newPopulation);
			}
			
			mainPopulation = newPopulation;
			this.createMutations();
		}
		
		private function applyNoSelection():Population {
			var selectedPopulation:Population = new Population;
			while(mainPopulation.size > 0){
				selectedPopulation.addElement(mainPopulation.removeFirst());
			}
			return selectedPopulation;
		}
		
	
		
		private function reproduceAndAddToPopulation(bs1:Individual, bs2:Individual, population:Population):void{
			//cross over or reinstert them into pupulation
			if(Math.random() < this.crossOverProbability){
				var children:Array;
				//select crossover type randomly
				var sample:Number = Math.random();
				if(sample < .3){
					children = bs1.randomInjectionBasedCrossOver(bs2, true);
				}else if(sample < .6){
					children = bs1.randomInjectionBasedCrossOver(bs2, false);
				}else if(sample < .8){
					children = bs1.partiallyMappedCrossover(bs2, true);
				}else{
					children = bs1.partiallyMappedCrossover(bs2, false);
				}
				//
				var c0:Individual = children[0] as Individual;
				var c1:Individual = children[1] as Individual;
				population.addElement(c0);
				population.addElement(c1);
			}else{
				population.addElement(bs1);
				population.addElement(bs2);
			}
		}
		
		private function createMutations():void {
			for(var i:uint = 0; i< mainPopulation.size; i++){
				var bs:Individual = mainPopulation.getElement(i);
				this.mutate(bs);
			}
		}
		
		private function mutate(bs:Individual):void {
			if(Math.random() < this.mutationProbability){
				var rand:Number = Math.random();
				if(rand < .33){
					bs.swapMutation();
				}else if (rand < .66){
					bs.reverseMutation();
				}else{
					bs.insertMutation();
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