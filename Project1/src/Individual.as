package
{
	public class Individual
	{
		public var genome:Array = new Array;
		//genome length
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
			var top:Number = 1;
			var bottom:Number = 1;
			for(var i:uint = 0; i< this.length/2; i++){
				top *= this.genome[i];
				bottom *= this.genome[this.length/2+i];
			}
			this.fitness =  (top/bottom) / Math.pow(10, 5);
		}
		
		private function initializeRandomly():void {
			//generate random binary string of given length
			for(var i:uint = 0; i< this.length; i++){
				//create integers from 1 to 10
				this.genome[i] = 1+Math.floor(Math.random() * 10);
			}
		}
		//returns an array with the children
		public function partiallyMappedCrossOver(bs:Individual):Array {
			//create an interval to exchange
			var a:Number = Math.random();
			var b:Number = Math.random();
			var min:uint = Math.floor(Math.min(a,b)* this.length);
			var max:uint = Math.ceil(Math.max(a,b)* this.length);
			
			var copy1:Array = this.genome.slice();
			var copy2:Array = bs.genome.slice();
			for(var i:uint = min; i <= max; i++){
				var h:Number = copy1[i] as Number;
				copy1[i] = copy2[i];
				copy2[i] = h;
			}
			var bs1:Individual = new Individual(length, true, copy1);
			var bs2:Individual = new Individual(length, true, copy2);
			
			return new Array(bs1, bs2);
		}
		
		//mutates with probability p
		public function mutate(entryMutationProbability:Number = .5):void {
			for(var i:uint = 0; i< this.length; i++){
				if(Math.random() < entryMutationProbability)
					this.genome[i] = 1 + Math.floor(Math.random() * 10);
			}
			computeFitness();
		}
		
		public function toString():String {
			
			var str:String = "("+ genome.slice(0, 5).join(",") + ") /" +"("+genome.slice(5, 10).join(",")+")\nFitness="+this.fitness;
			return str;
		}
	}
}