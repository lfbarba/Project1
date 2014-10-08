package
{
	public class Individual
	{
		public var genome:Array = new Array;
		public var length:uint;
		public var fitness:Number;
		
		
		public function Individual(l:uint, asCopy:Boolean = false, genomeToCopy:Array = null)
		{
			this.length = l;
			if(asCopy){
				this.genome = genomeToCopy.slice();
			}else{
				initializeRandomly();
			}
			computeFitness();
		}
		
		
		private function computeFitness():void {
			var sum:uint = 0;
			for(var i:uint = 0; i< this.length; i++){
				sum += this.genome[i];
			}
			this.fitness =  sum/this.length;
		}
		
		private function initializeRandomly():void {
			//generate random binary string of given length
			for(var i:uint = 0; i< this.length; i++){
				this.genome[i] = (Math.random() > .5) ? 1 : 0;
			}
		}
		//returns an array with the children
		public function partiallyMappedCrossOver(bs:Individual):Array {
			//create an interval to exchange
			var a:Number = Math.random();
			var b:Number = Math.random();
			var min:Number = Math.floor(Math.min(a,b)* this.length);
			var max:Number = Math.ceil(Math.max(a,b)* this.length);
			
			var copy1:Array = this.genome.slice();
			var copy2:Array = bs.genome.slice();
			for(var i:uint = min; i <= max; i++){
				var h:Boolean = copy1[i] as Boolean;
				copy1[i] = copy2[i];
				copy2[i] = h ? 1 : 0;
			}
			var bs1:Individual = new Individual(length, true, copy1);
			var bs2:Individual = new Individual(length, true, copy2);
			
			return new Array(bs1, bs2);
		}
		
		//mutates with probability p
		public function mutate(entryMutationProbability:Number = .5):void {
			for(var i:uint = 0; i< this.length; i++){
				if(Math.random() < entryMutationProbability)
					this.genome[i] = 1 - this.genome[i];
			}
			computeFitness();
		}
		
		public function toString():String {
			return this.genome.join("")+"\nFitness="+this.fitness;
		}
	}
}