package ga
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Population
	{
		private var populationAverage:Number;
		private var populationMaximum:Number = 0;
		private var populationMinimum:Number = 1000000;
		private var populationSum:Number = 0;
		
		private var fitnessProbabilitySpace:Array;
		
		private var population:Array;
		
		public var tournamentSelectionRange:Number = .3;
		
		public var tournamentSelectionProbability:Number = .5;
		
		private var rankSelectionProbability:Number = .9;
		
		private var fitnessComputed:Boolean = false;
		
		public static var POPULATION_BAD_TRESHHOLD:uint = 32000;
		
		public function Population()
		{
			population = new Array;
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
		
		public function chooseWithTournamentSelection():Individual {
			var range:uint = Math.floor(tournamentSelectionRange * this.size);
			var index:uint;
			//flip a biased coin to select at random from the fittest or from the rest
			if(Math.random() < tournamentSelectionProbability){
				//select from the top
				index = Math.floor(Math.random() * range);
			}else{
				index = range + Math.floor(Math.random() * (this.size - range));
			}
			return this.population[index] as Individual;
		}
		
		public function chooseWithRouletteWheelSelection():Individual {
			if(fitnessComputed == false)
				this.computePopulationFitness();
			//
			var pointer:Number = Math.random() * this.populationSquareSum;
			//binary search fitnessProbabilitySpace to find the bs 
			var i:uint = 0;
			var j:uint = fitnessProbabilitySpace.length - 1;
			var iterations:uint = 0;
			while(i != j){
				iterations++;
				var m:uint = Math.floor((i+j) / 2);
				if( fitnessProbabilitySpace[m][0] < pointer ) {
					if( fitnessProbabilitySpace[m+1][0] > pointer ) {
						i = j = m;
					}else{
						i = m;
					}
					
				}else{
					j = m;
				}
			}
			return fitnessProbabilitySpace[i][1] as Individual;
		}
		
		private var populationSquareSum:Number = 0;
		
		public function computePopulationFitness():void {
			fitnessComputed = true;
			
			var sum:Number = 0;
			var max:Number = 0;
			var min:Number = 1000000000000;
			var squareSum:Number = 0;
			
			fitnessProbabilitySpace = new Array;
			for(var i:uint = 0; i< population.length; i++){
				var bs:Individual = population[i] as Individual;
				sum += bs.fitness;
				squareSum += Math.pow(bs.fitness, 3.5);
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