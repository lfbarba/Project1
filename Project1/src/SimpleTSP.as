package
{
	import fl.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.Event;
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
		
		private var mutationProbability:Number = .2;
		private var crossOverProbability:Number = .8;
		
		
		private var tournamentSelectionRange:uint = 50;
		private var tournamentSelectionProbability:Number = .4;
		
		private var rankSelectionProbability:Number = .993;
		
		private var convergenceTreshhold:Number = 10;
		
		private var maxNumGenerations:uint = 1000;
		private var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		public static var CURRENT_POINTSET:PointSet;
		
		private var progressExampleLayer:Sprite;
		
		private var visualLayer:Sprite;
		
		private var startButton:Button;
		private var stopButton:Button;
		
		public function SimpleTSP()
		{
			visualLayer = new Sprite;
			this.addChild(visualLayer);
			this.addEventListener(Event.ENTER_FRAME, fitIntoScreen);
			
			var ps:PointSet = new PointSet;
			ps.readFromFile("berlin52.txt");
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
			startButton.label = "Iniciar GA";
			stopButton.label = "Stop GA";
			this.addChild(startButton);
			this.addChild(stopButton);
			startButton.addEventListener(MouseEvent.CLICK, this.startGeneticAlgorithm);
			stopButton.addEventListener(MouseEvent.CLICK, this.stopProcess);
			//
		}
		
		private function fitIntoScreen(e:Event = null){
			var w:Number = CURRENT_POINTSET.width;
			var h:Number = CURRENT_POINTSET.height;
			var ratio:Number = Math.max(w/this.stage.stageWidth, h / this.stage.stageHeight);
			if(ratio > 1){
				visualLayer.scaleX = 1/ratio;
				visualLayer.scaleY = 1/ratio;
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
			genomeLength = CURRENT_POINTSET.points.length;
			createPopulation();
			//this.printGeneration();
			t.start();
		}

		private function stopProcess(e:MouseEvent = null):void {
			t.stop();
			trace("number of generations = ", numGenerations);
			mainPopulation.printStatistics();
		}
		
		
		
		private function geneticAlgorithmMain(e:TimerEvent):void {
			if(this.populationHasConverged()){
				stopProcess();
			}else{
				runOneGeneration();
				//
				numGenerations++;
				if(numGenerations % 50 == 0)
					trace("Running generation", numGenerations);
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
			mainPopulation.sortByFitness(Array.DESCENDING);
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
			progressExampleLayer.addChild(p.drawIndividual());
		}
		
		private function runOneGeneration():void {
			//crear mutaciones
			this.createMutations();
			mainPopulation.sortByFitness();
			//show the best individual so far
			this.showIndividual(mainPopulation.getElement(0));
			mainPopulation.computePopulationFitness();
			
			var selectedPopulation:Population = this.applyRankSelection();
			//empty population
			this.mainPopulation = new Population;
			
			//reproduce the strings
			while(selectedPopulation.size > 0 && mainPopulation.size < this.populationSize){
				var bs1:Individual = selectedPopulation.chooseAnIndividualAtRandomWithFitness();
				var bs2:Individual = selectedPopulation.chooseAnIndividualAtRandomWithFitness();
				reproduceAndAddToMainPopulation(bs1, bs2);
			}
		}
		
		
		private function applyNaiveSelection():Population {
			var percentageOfPopulation:Number = .5;
			//choose the individuals to reproduce
			var selectedPopulation:Population = new Population;
			mainPopulation.sortByFitness();
			while(selectedPopulation.size < mainPopulation.size * percentageOfPopulation){
				selectedPopulation.addElement(mainPopulation.removeFirst());
			}
			selectedPopulation.computePopulationFitness();
			return selectedPopulation;
		}
		
		private function applyTournamentSelection():Population {
			var percentageOfPopulation:Number = .40;
			//choose the individuals to reproduce
			var selectedPopulation:Population = new Population;
			while(selectedPopulation.size < mainPopulation.size * percentageOfPopulation){
				var index:uint;
				//flip a biased coin to select at random from the fittest or from the rest
				if(Math.random() < this.tournamentSelectionProbability){
					//select from the top
					index = Math.floor(Math.random() * this.tournamentSelectionRange);
				}else{
					index = this.tournamentSelectionRange + Math.floor(Math.random() * (mainPopulation.size - this.tournamentSelectionRange));
				}
				
				selectedPopulation.addElement(this.mainPopulation.getElement(index));
			}
			selectedPopulation.computePopulationFitness();
			return selectedPopulation;
		}
		
		
		private function applyRankSelection():Population {
			//choose the individuals to reproduce
			var selectedPopulation:Population = new Population;
			for(var i:uint = 0; i< mainPopulation.size; i++){
				if(Math.random() < Math.pow(rankSelectionProbability, i)){
					selectedPopulation.addElement(this.mainPopulation.getElement(i));
				}
			}
			//trace(Math.round(100*selectedPopulation.size/ this.populationSize)+"%");
			selectedPopulation.computePopulationFitness();
			return selectedPopulation;
		}
		
		private function reproduceAndAddToMainPopulation(bs1:Individual, bs2:Individual):void{
			//cross over or reinstert them into pupulation
			if(Math.random() < this.crossOverProbability){
				var children:Array;
				//select crossover type randomly
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