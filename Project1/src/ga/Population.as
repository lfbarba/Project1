package ga
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flashx.textLayout.elements.ParagraphElement;
	
	import gp.FunctionTree;

	public class Population
	{
		private var populationAverage:Number;
		private var populationMaximum:Number = 0;
		private var populationMinimum:Number = Number.POSITIVE_INFINITY;
		private var populationSum:Number = 0;
		
		private var population:Array;
		
		public var tournamentSelectionRange:Number;
		
		public var tournamentSelectionProbability:Number;
		
		private var fitnessComputed:Boolean = false;
		
		public static var ROULETEE_PREASSURE:Number;
		
		public function Population(parameters:Parameters)
		{
			population = new Array;
			parameters.addEventListener(ParametersChangeEvent.PARAMETERS_CHANGE, parametersChangeHandler);
			this.setParameters(parameters);
		}
		
		private function setParameters(parameters:Parameters):void {
			tournamentSelectionRange = parameters.getTournamentSelectRange();
			tournamentSelectionProbability = parameters.getTournamentSelecProbability();
		}
		
		private function parametersChangeHandler(e:ParametersChangeEvent):void {
			setParameters(e.parameters);
		}
		
		public function get average():Number{
			if(this.fitnessComputed == false)
				this.computePopulationFitness();
			return this.populationAverage;
		}
		
		public function get maximum():Number{
			if(this.fitnessComputed == false)
				this.computePopulationFitness();
			return this.populationMaximum;
		}
		
		public function get minimum():Number{
			if(this.fitnessComputed == false)
				this.computePopulationFitness();
			return this.populationMinimum;
		}
		
		public function get sum():Number{
			if(this.fitnessComputed == false)
				this.computePopulationFitness();
			return this.populationSum;
		}
		
		public function getElement(index:uint):FunctionTree {
			return this.population[index] as FunctionTree;
		}
		
		public function get size():uint {
			return this.population.length;
		}
		
		public function sortByFitness(order:uint = 0):void {
			population.sort(FunctionTree.compareFunctionTrees, order);
			//population.sortOn("fitness", order);
		}
		
		public function removeLast():FunctionTree {
			fitnessComputed = false;
			return population.pop() as FunctionTree;	
		}
		
		public function removeFirst():FunctionTree {
			fitnessComputed = false;
			return population.shift() as FunctionTree;
			
		}
		
		public function addElement(bs:FunctionTree):void {
			fitnessComputed = false;
			this.population.push(bs);
		}
		
		public function selectIndividualAtRandom(subpopulation:Array):FunctionTree {
			return subpopulation[Math.floor(Math.random() * subpopulation.length)] as FunctionTree;
		}
		
		public function chooseWithTournamentSelection():FunctionTree {
			var candidates:Array = new Array;
			var max:Number = Number.NEGATIVE_INFINITY;
			var best:FunctionTree;
			for(var i:uint = 0; i < tournamentSelectionRange; i++){
				var ind:FunctionTree = this.population[Math.floor(Math.random() * this.size)] as FunctionTree;
				if(max < ind.fitness.x){
					max = ind.fitness.x;
					best = ind;
				}
				candidates.push(ind);
			}	
			if(Math.random() < this.tournamentSelectionProbability){
				return best;
			}else{
				return this.selectIndividualAtRandom(candidates);
			}
		}
		
		public function computePopulationFitness():void {
			fitnessComputed = true;
			
			var sum:Number = 0;
			var max:Number = Number.NEGATIVE_INFINITY;
			var min:Number = Number.POSITIVE_INFINITY;
			var squareSum:Number = 0;
			
			for(var i:uint = 0; i< population.length; i++){
				var bs:FunctionTree = population[i] as FunctionTree;
				if(bs.maxDepth > 20){
					bs.initializeRandomly(5, true);
				}
				sum += bs.fitness;
				max = Math.max(bs.fitness.x, max);
				min = Math.min(bs.fitness.x, min);
			}
			
			this.populationAverage =  sum/population.length;
			this.populationMaximum = max;
			this.populationMinimum = min;
			this.populationSum = sum;			
		}
	}
}