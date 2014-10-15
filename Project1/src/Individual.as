package
{
	import flash.display.Sprite;
	
	import ga.TspPoint;

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
			var totalLength:Number = 0;
			for(var i:uint = 0; i< this.length; i++){
				//get the ith point according to the permutation in genome 
				var current:TspPoint = SimpleTSP.CURRENT_POINTSET.points[genome[i]] as TspPoint;
				var next:TspPoint = SimpleTSP.CURRENT_POINTSET.points[genome[(i+1) % length]] as TspPoint;
				//summ the distance between current and next
				totalLength += Math.sqrt(Math.pow(next.x - current.x, 2) + Math.pow(next.y - current.y, 2));
			}
			this.fitness =  totalLength;
		}
		
		public function drawIndividual():Sprite {
			var draw:Sprite = new Sprite;
			draw.graphics.lineStyle(2, 0);
			
			var first:TspPoint = SimpleTSP.CURRENT_POINTSET.points[genome[0]] as TspPoint;
			draw.graphics.moveTo(first.x, first.y);
			for(var i:uint = 1; i<= this.length; i++){
				//get the ith point according to the permutation in genome 
				var current:TspPoint = SimpleTSP.CURRENT_POINTSET.points[genome[i % length]] as TspPoint;
				draw.graphics.lineTo(current.x, current.y);
			}
			return draw;
		}
		
		
		private function initializeRandomly():void {
			//generate a permutation of 1 to length
			for(var i:uint = 0; i< this.length; i++){
				this.genome[i] = i;
			}
			//randomly permute elements
			for (i = 0 ; i < this.length ; i++){
				var temp:uint = genome[i];
				var randomIndex:uint = Math.floor(Math.random() * this.length);
				genome[i] = genome[randomIndex];
				genome[randomIndex] = temp;
			}
		}
		//returns an array with the children
		public function orderPartiallyMappedCrossover(bs:Individual):Array {
			//create an interval to exchange
			var a:Number = Math.random();
			var b:Number = Math.random();
			var min:Number = Math.floor(Math.min(a,b)* this.length);
			var max:Number = Math.ceil(Math.max(a,b)* this.length);
			//copy
			var child1:Array = new Array;
			var child2:Array = new Array;
			
			//create hash maps for the existing coppied values
			var copiedInto1:Array = new Array;
			var copiedInto2:Array = new Array;
			//
			for(var i:uint = min; i <= max; i++){
				child1[i] = genome[i];
				copiedInto1[genome[i]] = true;
				child2[i] = bs.genome[i];
				copiedInto2[bs.genome[i]] = true;
			}
			
			var counterGenome:uint = 0;
			var counterBS:uint = 0;
			for(i = 0; i < this.length; i++){
				if(child1[i] == undefined){
					while(counterBS < length && copiedInto1[bs.genome[counterBS]] != undefined){
						counterBS ++;
					}
					child1[i] = bs.genome[counterBS];
					counterBS++;
				}
				
				if(child2[i] == undefined){
					while(counterGenome < length && copiedInto2[genome[counterGenome]] != undefined){
						counterGenome ++;
					}
					child2[i] = genome[counterGenome];
					counterGenome++;
				}
			}
			var bs1:Individual = new Individual(length, true, child1);
			var bs2:Individual = new Individual(length, true, child2);
			
			return new Array(bs1, bs2);
		}
		
		public function positionBasedCrossOver(bs:Individual):Array {
			var child1:Array = new Array;
			var child2:Array = new Array;
			//create hash maps for the existing coppied values
			var copiedInto1:Array = new Array;
			var copiedInto2:Array = new Array;
			//copy into arrays with probability .5
			for(var i:uint = 0; i < this.length; i++){
				if(Math.random() < .5){
					child1[i] =  genome[i];
					copiedInto1[genome[i]] = true;
				}
				if(Math.random() < .5){
					child2[i] = bs.genome[i];
					copiedInto2[bs.genome[i]] = true;
				}
			}		
			
			var counterGenome:uint = 0;
			var counterBS:uint = 0;
			for(i = 0; i < this.length; i++){
				if(child1[i] == undefined){
					while(counterBS < length && copiedInto1[bs.genome[counterBS]] != undefined){
						counterBS ++;
					}
					child1[i] = bs.genome[counterBS];
					counterBS++;
				}
				
				if(child2[i] == undefined){
					while(counterGenome < length && copiedInto2[genome[counterGenome]] != undefined){
						counterGenome ++;
					}
					child2[i] = genome[counterGenome];
					counterGenome++;
				}
			}
			var bs1:Individual = new Individual(length, true, child1);
			var bs2:Individual = new Individual(length, true, child2);
			
			return new Array(bs1, bs2);
		}
		
		//mutates with probability p
		public function mutate(entryMutationProbability:Number = .5):void {
			for(var i:uint = 0; i< this.length; i++){
				if(Math.random() < entryMutationProbability){
					//swap randomly
					var temp:uint = genome[i];
					var randomIndex:uint = Math.floor(Math.random() * this.length);
					genome[i] = genome[randomIndex];
					genome[randomIndex] = temp;
				}
			}
			computeFitness();
		}
		
		public function toString():String {
			return this.genome.join(",")+"\nFitness="+this.fitness;
		}
	}
}