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
	
	import gp.FuncionEvaluable;
	import gp.FunctionTree;
	
	import grapher.Grapher;
	
	public class GeneticProgram extends Sprite
	{
		private var parameters:Parameters;
		
		private var mainPopulation:Population;
		
		private var populationSize:uint;
		private var initialDepthOfSubtrees:uint = 5;
		
		private var mutationProbability:Number;
		private var crossOverProbability:Number;
		
		
		private var convergenceTreshhold:Number = .000001;
		
		private var maxNumGenerations:uint = 1000;
		public static var numGenerations:uint = 0;
		
		
		private var t:Timer;
		
		private var elitismNumber:uint = 10;
				
		private var visualLayer:Sprite;
		
		private var bestIndividual:FunctionTree;
		private var bestFitness:Number = Number.NEGATIVE_INFINITY;
		
		private var startButton:Button;
		private var stopButton:Button;
		
		private var selectionFunction:Function;
		
		private var selectionType:uint;
		
		private var counter:uint = 0;
		
		private var _grapher:Grapher;
		private static var _targetFunction:FuncionEvaluable;
		
		
		public function GeneticProgram()
		{
			visualLayer = new Sprite;
			this.addChild(visualLayer);
			
			t = new Timer(0, 0);
			t.addEventListener(TimerEvent.TIMER, this.geneticAlgorithmMain);
			
			//botton para iniciar
			startButton = new Button;
			stopButton = new Button;
			startButton.x = startButton. y  = stopButton.y = 20;
			stopButton.x = 140;
			startButton.label = "Start GP";
			stopButton.label = "Stop GP";
			this.addChild(startButton);
			this.addChild(stopButton);
			startButton.addEventListener(MouseEvent.CLICK, this.startGeneticAlgorithm);
			stopButton.addEventListener(MouseEvent.CLICK, this.stopProcess);
			//
			setUpGrapher();
			//
			parameters = new Parameters;
			parameters.x = this.stage.stageWidth;
			parameters.y = 0;
			Parameters.inst.addEventListener(ParametersChangeEvent.PARAMETERS_CHANGE, parametersChangeHandler);
			this.addChild(parameters);
		}
		
		public static function get TARGET_FUNCTION():FuncionEvaluable {
			return _targetFunction;
		}
		
		private function setUpGrapher():void {
			if(_grapher != null && this.contains(_grapher)){
				this.removeChild(_grapher);
			}
			_grapher = new Grapher(800, 600, -5, 5);
			_grapher.drawBackground(5, 1);
			visualLayer.addChild(_grapher);
		}
		
		private function parametersChangeHandler(e:ParametersChangeEvent):void {
			this.populationSize = e.parameters.getPopulationSize();
			this.crossOverProbability = e.parameters.getCrossoverProbability();
			this.mutationProbability = e.parameters.getMutationProbability();
			this.selectionType = e.parameters.getSelectionType();
			if(e.parameters.getTargetFunction() != null){
				this._grapher.clearPlots();
				var height:Number = e.parameters.getTargetFunction().heightInInterval;
				_grapher.drawBackground(height, Math.floor(height / 10));
				this._grapher.plotFunction(e.parameters.getTargetFunction(), 0xFF0000);
				_targetFunction = e.parameters.getTargetFunction();
			}else{
				this._grapher.clearPlots();
				_targetFunction = null;
			}
		}
		
		private function startGeneticAlgorithm(e:MouseEvent):void {
			numGenerations = 0;
			createPopulation();
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
				var bs:FunctionTree = mainPopulation.getElement(i);
				trace(bs.toString());
			}
		}
		
		private function showIndividual(p:FunctionTree):void {
			if(bestIndividual != null && _targetFunction != null){
				this._grapher.clearPlots();
				this._grapher.plotFunction(_targetFunction, 0xFF0000);
				this._grapher.plotFunction(bestIndividual);
			}
		}
		
		private function reportStatistics():void {
			var max:Number = -1*this.mainPopulation.maximum;
			var min:Number = -1* this.mainPopulation.minimum;
			var avg:Number = -1*this.mainPopulation.average;
			var best:Number = -1* this.bestFitness;
			var current:Number = -1* mainPopulation.getElement(0).fitness;
			this.parameters.updateStatistics(Math.round(max), Math.round(min), 
				Math.round(avg), Math.round(best), Math.round(current), this.bestIndividual);
		}
		

		
		private function runOneGeneration():void {
			mainPopulation.sortByFitness(Array.DESCENDING | Array.NUMERIC);
			mainPopulation.computePopulationFitness();
			reportStatistics();
			//show the best individual so far
			var best:FunctionTree = mainPopulation.getElement(0);
			if(best.fitness  >  bestFitness){
				bestFitness = best.fitness;
				bestIndividual = new FunctionTree(best);
			}
			this.showIndividual(mainPopulation.getElement(0));
			
			var newPopulation:Population = new Population(parameters);
			
			for(var j:uint = 0; j < elitismNumber; j++){
				newPopulation.addElement(mainPopulation.getElement(j));
			}
			
			//reproduce the strings
			while(newPopulation.size < this.populationSize){
				var bs1:FunctionTree;
				var bs2:FunctionTree;
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
		
		private function selectIndividual():FunctionTree {
			var bs1:FunctionTree;
			if(this.selectionType == Parameters.TOURNAMENT_SELECTION){
				bs1 = mainPopulation.chooseWithTournamentSelection();
			}
			return bs1;
		}
		
	
		
		private function reproduceAndAddToPopulation(bs1:FunctionTree, bs2:FunctionTree, population:Population):void{
			//cross over or reinstert them into pupulation
			var children:Array;
			switch(this.parameters.getCrossoverType()){
				case Parameters.SubtreeSwapCrossover:
					children = bs1.crossOver(bs2, false);
					break;
				case Parameters.FairSubtreeSwapCrossover:
					children = bs1.crossOver(bs2, true);
					break;
			}
			//
			var c0:FunctionTree = children[0] as FunctionTree;
			var c1:FunctionTree = children[1] as FunctionTree;
			this.mutate(c0);
			this.mutate(c1);
			population.addElement(c0);
			population.addElement(c1);
		}
		
		
		private function mutate(bs:FunctionTree):void {
			if(Math.random() < this.mutationProbability){
				switch(this.parameters.getMutationType()){
					case Parameters.SubTreeReplacementMutation:
						bs.subTreeReplacementMutation();
						break;
				}
			}
		}
		
		
		
		private function createPopulation():void {
			var repetition:Array = new Array;
			mainPopulation = new Population(parameters);	
			var depth:uint = 1;
			var blockSize:uint = Math.floor(populationSize/initialDepthOfSubtrees);
			var i:uint = 0;
			while(i < populationSize){
				if(i % blockSize == 0)
					depth ++;
				var t:FunctionTree = new FunctionTree;
				t.initializeRandomly(depth, (i%2 == 0));
				if(repetition[t.toString()] == undefined){
					mainPopulation.addElement(t);
					repetition[t.toString()] = true;
					i++;
				}
			}
			trace("population created");
		}
	}
}