package ga
{
	public class Population
	{
		private var populationAverage:Number;
		private var populationMaximum:Number = 0;
		private var populationMinimum:Number = 1;
		private var populationSum:Number = 0;
		
		private var fitnessProbabilitySpace:Array;
		
		private var population:Array;
		
		private var fitnessComputed:Boolean = false;
		
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
			population.sortOn("fitness", order | Array.NUMERIC);
		}
		
		public function removeLast():Individual {
			return population.pop() as Individual;
			fitnessComputed = false;
		}
		
		public function addElement(bs:Individual):void {
			this.population.push(bs);
			fitnessComputed = false;
		}
		
		
		public function chooseAnIndividualAtRandomWithFitness():Individual {
			if(fitnessComputed == false)
				this.computePopulationFitness();
			var pointer:Number = Math.random() * this.populationSum;
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
		
		public function computePopulationFitness():void {
			fitnessComputed = true;
			
			fitnessProbabilitySpace = new Array;
			var sum:Number = 0;
			var max:Number = 0;
			var min:Number = 1;
			for(var i:uint = 0; i< population.length; i++){
				var bs:Individual = population[i] as Individual;
				sum += bs.fitness;
				fitnessProbabilitySpace.push(new Array(sum, bs));
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