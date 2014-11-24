package
{
	import ants.GridPixel;
	import ants.Simulator;
	
	import fl.controls.Button;
	import fl.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import ga.Parameters;
	import ga.ParametersChangeEvent;
	import ga.Population;
	
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
	
	
	public class GeneticProgram extends Sprite
	{
		private var parameters:Parameters;
		
		private var mainPopulation:Population;
		
		private var populationSize:uint;
		private var initialDepthOfSubtrees:uint = 4;
		
		private var mutationProbability:Number;
		private var crossOverProbability:Number;
		
		
		private var convergenceTreshhold:Number = .01;
		
		private var maxNumGenerations:uint = 20;
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
		
		private var _simulator:Simulator;
		private var _bigSimulator:Simulator;
		
		private var _simulatorParameters:SimulationParameters; 
		
		private var _savedFunctions:Array;
		
		public function GeneticProgram()
		{
			visualLayer = new Sprite;
			this.addChild(visualLayer);
			
			t = new Timer(0.01, 0);
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
			setUpSimulator();
			//
			parameters = new Parameters;
			parameters.x = this.stage.stageWidth;
			parameters.y = 0;
			Parameters.inst.addEventListener(ParametersChangeEvent.PARAMETERS_CHANGE, parametersChangeHandler);
			this.addChild(parameters);
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
			/*var c:IfPherormone = new IfPherormone;
			c.addChild(new MoveToPherormone);
			c.addChild(new MoveRandomly);
			b.addChild(c);*/
			b.addChild(new MoveRandomly);
			f.root.addChild(b);
			return f;
		}
		
		private function setUpSimulator():void {
			_simulator = new Simulator(true, -1);
			_simulator.setTrainingSimulation();
			_simulator.draw();
			this.addChild(_simulator);
			_simulator.y = 80;
			_simulator.x = 20;
			
			_bigSimulator = new Simulator(true, -1);
			_bigSimulator._pixelSize = 13;
			_bigSimulator.setSimulation(40, 40);
			_bigSimulator.changeTickTime(200);
			_bigSimulator.setNest(20, 20);
			_bigSimulator.numAnts = 100;
			GridPixel.dropInPherormonePerTick = .05;
			_bigSimulator.draw();
			this.addChild(_bigSimulator);
			_bigSimulator.y = 120;
			_bigSimulator.x = 0;
			
			var button:Button = new Button;
			button.label = "Simulation Start";
			button.addEventListener(MouseEvent.CLICK, this.startSimulation);
			button.x = 110;
			button.y = 50;
			this.addChild(button);
			
			var pause:Button = new Button;
			pause.label = "Simulation Pause";
			pause.addEventListener(MouseEvent.CLICK, pauseResumeSimulator);
			this.addChild(pause);
			pause.x = 310;
			pause.y = 50;
			
			/*_simulatorParameters = new SimulationParameters;
			this.addChild(_simulatorParameters);
			_simulatorParameters.x = 660;
			_simulatorParameters.tickTimeSlider.addEventListener(SliderEvent.CHANGE, simulatorParametersChanged);
			_simulatorParameters.numAntsSlider.addEventListener(SliderEvent.CHANGE, simulatorParametersChanged);
			_simulatorParameters.amountFoodSlider.addEventListener(SliderEvent.CHANGE, simulatorParametersChanged);
			_simulatorParameters.dropPherormonesSlider.addEventListener(SliderEvent.CHANGE, simulatorParametersChanged);
			//
			simulatorParametersChanged();*/
		}
		
		private function simulatorParametersChanged(e:SliderEvent = null):void {
			_simulator.changeTickTime(_simulatorParameters.tickTimeSlider.value);
			_simulator.numAnts = _simulatorParameters.numAntsSlider.value;
			_simulatorParameters.numAntsText.text = String(_simulatorParameters.numAntsSlider.value);
			GridPixel.dropInPherormonePerTick = _simulatorParameters.dropPherormonesSlider.value;
			GridPixel.amountOfFoodPerClick = _simulatorParameters.amountFoodSlider.value;
		}
		
		private function pauseResumeSimulator(e:MouseEvent):void {
			_simulator.pauseResumeSimulation();
			_bigSimulator.pauseResumeSimulation();
		}
		
		private function startSimulation(e:MouseEvent):void {
			_simulator.resetSimulation();
			_simulator.setTrainingSimulation();
			_simulator.startSimulation();
			
			_bigSimulator.resetSimulation();
			_bigSimulator.numAnts = 100;
			_bigSimulator.startSimulation();
		}
		
		private function parametersChangeHandler(e:ParametersChangeEvent):void {
			this.populationSize = e.parameters.getPopulationSize();
			this.crossOverProbability = e.parameters.getCrossoverProbability();
			this.mutationProbability = e.parameters.getMutationProbability();
			this.selectionType = e.parameters.getSelectionType();
			this._simulator.setAntFunction(e.parameters.getAntFunction());
			this._bigSimulator.setAntFunction(e.parameters.getAntFunction());
		}
		
		private function startGeneticAlgorithm(e:MouseEvent):void {
			numGenerations = 0;
			createPopulation();
			this.bestFitness = Number.NEGATIVE_INFINITY;
			this.bestIndividual = null;
			t.start();
		}
		
		private function stopProcess(e:MouseEvent = null):void {
			t.stop();
			this.bestFitness = Number.NEGATIVE_INFINITY;
			this.bestIndividual = null;
		}
		
		private function geneticAlgorithmMain(e:TimerEvent):void {
			t.stop();
			if(this.populationHasConverged()){
				stopProcess();
			}else{
				this.parameters.updateNumGenerations(2*numGenerations);
				runOneGeneration();
				//
				if(maxNumGenerations != numGenerations){
					numGenerations++;
					t.start();
				}else{
					trace("Max num of generations achieved");
				}
			}
		}
		
		private function populationHasConverged():Boolean {
			return false;
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
				trace(bs.toString(), bs.fitness);
			}
		}
		
		private function reportStatistics():void {
			var max:Number = this.mainPopulation.maximum;
			var min:Number =  this.mainPopulation.minimum;
			var avg:Number = this.mainPopulation.average;
			var best:Number =  this.bestFitness;
			var current:Number =  mainPopulation.getElement(0).fitness.x;
			this.parameters.updateStatistics(max, min, 
				avg, best, current, this.bestIndividual, mainPopulation.getElement(0).size, mainPopulation.averageSize);
		}
		
		
		
		private function runOneGeneration():void {
			mainPopulation.sortByFitness(Array.DESCENDING | Array.NUMERIC);
			mainPopulation.computePopulationFitness();
			//show the best individual so far
			var best:FunctionTree = mainPopulation.removeFirst();
			
			
			if(bestIndividual == null || FunctionTree.compareFunctionTrees(best, bestIndividual) > 0){
				bestFitness = best.fitness.x;
				bestIndividual = best;
			}
			reportStatistics();
			mainPopulation.addElement(new FunctionTree(bestIndividual));
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
			mainPopulation.addElement(new FunctionTree(bestIndividual));
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