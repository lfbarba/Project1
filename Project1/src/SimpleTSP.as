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
	import ga.Parameters;
	import ga.ParametersChangeEvent;
	import ga.PointSet;
	import ga.Population;
	import ga.TspPoint;
	
	public class SimpleTSP extends Sprite
	{
		private var parameters:Parameters;
		
		private var mainPopulation:Population;
		
		private var populationSize:uint;
		private var genomeLength:uint;
		
		private var mutationProbability:Number;
		private var crossOverProbability:Number;
		
		
		private var convergenceTreshhold:Number = .000001;
		
		private var maxNumGenerations:uint = 1000;
		public static var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		private var elitismNumber:uint = 10;
		
		public static var CURRENT_POINTSET:PointSet;
		
		private var progressExampleLayer:Sprite;
		
		private var visualLayer:Sprite;
		
		private var bestIndividual:Individual;
		private var bestFitness:Number =  - 100000;
		
		private var startButton:Button;
		private var stopButton:Button;
		private var openTester:Button;
		
		private var selectionFunction:Function;
		
		private var crossOverTester:CrossOverTester;
		
		private var selectionType:uint;
		
		public function SimpleTSP()
		{
			visualLayer = new Sprite;
			this.addChild(visualLayer);
			this.addEventListener(Event.ENTER_FRAME, fitIntoScreen);
			
			var ps:PointSet = new PointSet;
			ps.readFromFile("berlin52.txt");
			//ps.createPointInCricle();
			this.setPointSet(ps);
			
			t = new Timer(0, 0);
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
			
			parameters = new Parameters;
			parameters.x = this.stage.stageWidth;
			parameters.y = 0;
			Parameters.inst.addEventListener(ParametersChangeEvent.PARAMETERS_CHANGE, parametersChangeHandler);
			this.addChild(parameters);
		}
		
		private function parametersChangeHandler(e:ParametersChangeEvent):void {
			this.populationSize = e.parameters.getPopulationSize();
			this.crossOverProbability = e.parameters.getCrossoverProbability();
			this.mutationProbability = e.parameters.getMutationProbability();
			this.selectionType = e.parameters.getSelectionType();
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
			this.bestFitness = -100000;
			this.bestIndividual = null;
		}
		
		private function geneticAlgorithmMain(e:TimerEvent):void {
			t.stop();
			if(this.populationHasConverged()){
				stopProcess();
			}else{
				this.parameters.updateNumGenerations(numGenerations);
				runOneGeneration();
				//
				numGenerations++;
			}
			t.start();
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
		
		private function reportStatistics():void {
			var max:Number = -1*this.mainPopulation.maximum;
			var min:Number = -1* this.mainPopulation.minimum;
			var avg:Number = -1*this.mainPopulation.average;
			var best:Number = -1* this.bestFitness;
			var current:Number = -1* mainPopulation.getElement(0).fitness;
			this.parameters.updateStatistics(Math.round(max), Math.round(min), Math.round(avg), Math.round(best), Math.round(current));
		}
		

		
		private function runOneGeneration():void {
			//crear mutaciones
			mainPopulation.sortByFitness(Array.DESCENDING | Array.NUMERIC);
			mainPopulation.computePopulationFitness();
			reportStatistics();
			//show the best individual so far
			var best:Individual = mainPopulation.getElement(0);
			if(best.fitness  >  bestFitness){
				bestFitness = best.fitness;
				bestIndividual = new Individual(best.length, true, best.genome);
			}
			this.showIndividual(mainPopulation.getElement(0));
			
			var newPopulation:Population = new Population(parameters);
			
			for(var j:uint = 0; j < elitismNumber; j++){
				newPopulation.addElement(mainPopulation.getElement(j));
			}
			
			//reproduce the strings
			while(newPopulation.size < this.populationSize){
				var bs1:Individual;
				var bs2:Individual;
				if(Math.random() < this.crossOverProbability){
					bs1 = selectIndividual();
					bs2 = selectIndividual();
					reproduceAndAddToPopulation(bs1, bs2, newPopulation);
				}else{
					bs1 = selectIndividual();
					this.mutate(bs1);
					newPopulation.addElement(bs1);
				}
			}
			
			mainPopulation = newPopulation;
		}
		
		private function selectIndividual():Individual {
			var bs1:Individual;
			if(this.selectionType == Parameters.TOURNAMENT_SELECTION){
				bs1 = mainPopulation.chooseWithTournamentSelection();
			}else if(this.selectionType == Parameters.ROULETTE_SELECTION){
				bs1 = mainPopulation.chooseWithRouletteWheelSelection();
			}
			return bs1;
		}
		
	
		
		private function reproduceAndAddToPopulation(bs1:Individual, bs2:Individual, population:Population):void{
			if(Math.random() < .5){
				var b:Individual = bs1;
				bs1 = bs2;
				bs2 = b;
			}
			//cross over or reinstert them into pupulation
			var children:Array;
			switch(this.parameters.getCrossoverType()){
				case Parameters.ReversedPartiallyMappedCrossover:
					children = bs1.partiallyMappedCrossover(bs2, true, true);
					break;
				case Parameters.OrderedPositionBasedCrossover:
					children = bs1.randomInjectionBasedCrossOver(bs2, true);
					break;
				case Parameters.ParallelPositionBasedCrossover:
					children = bs1.randomInjectionBasedCrossOver(bs2, false);
					break;
				case Parameters.OrderedPartiallyMappedCrossover:
					children = bs1.partiallyMappedCrossover(bs2, true, false);
					break;
				case Parameters.ParallelPartiallyMappedCrossover:
					children = bs1.partiallyMappedCrossover(bs2, false, false);
					break;
			}
			//
			var c0:Individual = children[0] as Individual;
			var c1:Individual = children[1] as Individual;
			this.mutate(c0);
			this.mutate(c1);
			population.addElement(c0);
			population.addElement(c1);
		}
		
		
		private function mutate(bs:Individual):void {
			if(Math.random() < this.mutationProbability){
				switch(this.parameters.getMutationType()){
					case Parameters.SwapMutation:
						bs.swapMutation();
						break;
					case Parameters.ReverseMutation:
						bs.reverseMutation();
						break;
					case Parameters.InsertMutation:
						bs.insertMutation();
						break;
					case Parameters.RandomMutation:
						if(Math.random() < .33){
							bs.swapMutation();
						}else if(Math.random() < .66){
							bs.reverseMutation();
						}else{
							bs.insertMutation();
						}
						break;
				}
			}
		}
		
		
		
		private function createPopulation():void {
			mainPopulation = new Population(parameters);	
			for(var i:uint = 0; i< populationSize; i++){
				mainPopulation.addElement(new Individual(genomeLength));
			}
		}
	}
}