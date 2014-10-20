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
		private var populationMinimum:Number = 1000000;
		private var populationSum:Number = 0;
		
		private var fitnessProbabilitySpace:Array;
		
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
		
		private var TSprobabilityDistribution:Array;
		private function setParameters(parameters:Parameters):void {
			tournamentSelectionRange = parameters.getTournamentSelectRange();
			tournamentSelectionProbability = parameters.getTournamentSelecProbability();
			ROULETEE_PREASSURE = parameters.getRouletteSelectionPressure();
			
			TSprobabilityDistribution = new Array;
			var sum:Number = 0;
			for(var i:uint = 0; i < tournamentSelectionRange; i++){
				var prob:Number = tournamentSelectionProbability  * Math.pow(1 - tournamentSelectionProbability, i);
				sum += prob;
				TSprobabilityDistribution.push(sum);
			}
			if(sum != 1)
				TSprobabilityDistribution.push(1);
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
		
		/*public function chooseWithTankSelection():Individual {
			if(Math.random() < Math.pow(rankSelectionProbability, Math.sqrt(i))){
				
			}
		}*/
		
		public function selectIndividualAtRandom(subpopulation:Array):Individual {
			return subpopulation[Math.floor(Math.random() * subpopulation.length)] as Individual;
		}
		
		public function chooseWithTournamentSelection():Individual {
			var candidates:Array = new Array;
			var max:Number = -100000000;
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
		
		public function chooseWithRouletteWheelSelection():Individual {
			if(fitnessComputed == false)
				this.computePopulationFitness();
			//		
			var ind:Individual =  this.binarySearch(fitnessProbabilitySpace, Math.random() * this.populationSquareSum);
			return ind;
		}
		
		private function binarySearch(a:Array, value:Number):Individual {
			var i:uint = 0;
			var j:uint = a.length - 1;
			while(i != j){
				var m:uint = Math.floor((i+j) / 2);
				if( a[m][0] < value ) {
					if( a[m+1][0] > value ) {
						i = j = m;
					}else{
						i = m;
					}
				}else{
					j = m;
				}
			}
			return a[i][1];
		}
		
		
		private var populationSquareSum:Number = 0;
		
		public function computePopulationFitness():void {
			fitnessComputed = true;
			
			var sum:Number = 0;
			var max:Number = -100000000000;
			var min:Number = 1000000000000;
			var squareSum:Number = 0;
			
			fitnessProbabilitySpace = new Array;
			for(var i:uint = 0; i< population.length; i++){
				var bs:Individual = population[i] as Individual;
				sum += bs.fitness;
				var increment:Number =  (average + ROULETEE_PREASSURE* (maximum  - average) <  bs.fitness) ? 100000- bs.fitness : 1;
				squareSum += increment;
				max = Math.max(bs.fitness, max);
				min = Math.min(bs.fitness, min);
				fitnessProbabilitySpace.push(new Array(squareSum, bs));
			}
			
			this.populationAverage =  sum/population.length;
			this.populationMaximum = max;
			this.populationMinimum = min;
			this.populationSum = sum;		
			this.populationSquareSum = squareSum;		
		}
	}
}