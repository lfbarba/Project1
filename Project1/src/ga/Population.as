package ga
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flashx.textLayout.elements.ParagraphElement;

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
		
		public function getElement(index:uint):Individual {
			return this.population[index] as Individual;
		}
		
		public function get size():uint {
			return this.population.length;
		}
		
		public function sortByFitness(order:uint = 0):void {
			population.sortOn("fitness", order);
		}
		
		public function removeLast():Individual {
			fitnessComputed = false;
			return population.pop() as Individual;	
		}
		
		public function removeFirst():Individual {
			fitnessComputed = false;
			return population.shift() as Individual;
			
		}
		
		public function addElement(bs:Individual):void {
			fitnessComputed = false;
			this.population.push(bs);
		}
		
		public function selectIndividualAtRandom(subpopulation:Array):Individual {
			return subpopulation[Math.floor(Math.random() * subpopulation.length)] as Individual;
		}
		
		public function chooseWithTournamentSelection():Individual {
			var candidates:Array = new Array;
			var max:Number = Number.NEGATIVE_INFINITY;
			var best:Individual;
			for(var i:uint = 0; i < tournamentSelectionRange; i++){
				var ind:Individual = this.population[Math.floor(Math.random() * this.size)] as Individual;
				if(max < ind.fitness){
					max = ind.fitness;
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
				var bs:Individual = population[i] as Individual;
				sum += bs.fitness;
				max = Math.max(bs.fitness, max);
				min = Math.min(bs.fitness, min);
			}
			
			this.populationAverage =  sum/population.length;
			this.populationMaximum = max;
			this.populationMinimum = min;
			this.populationSum = sum;			
		}
	}
}