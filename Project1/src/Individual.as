package
{
	import fl.core.UIComponent;
	
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
			this.fitness =  100000-totalLength;
		}
		
		public function drawIndividual(color:Number = 0, thickness:Number = 1):Sprite {
			var draw:Sprite = new Sprite;
			draw.graphics.lineStyle(thickness, color);
			
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
		public function partiallyMappedCrossover(
			bs:Individual, orderedOrParallel:Boolean, itemsFromThis:Array = null, itemsFromBs:Array = null):Array
		{
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
			
			if(itemsFromThis != null){
				for(var t in copiedInto1){
					itemsFromThis[t] = copiedInto1[t];
				}
				for(t in copiedInto2){
					itemsFromBs[t] = copiedInto2[t];
				}
			}	
			
			if(orderedOrParallel){
				return this.orderedFillingEmptyEntries(bs, child1, child2, copiedInto1, copiedInto2);
			}else{
				return this.paralellFillingEmptyEntries(bs, child1, child2, copiedInto1, copiedInto2);
			}
		}
		
		public function randomInjectionBasedCrossOver(
			bs:Individual, orderedOrParallel:Boolean, itemsFromThis:Array = null, itemsFromBs:Array = null):Array 
		{
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
			
			if(itemsFromThis != null){
				for(var t in copiedInto1){
					itemsFromThis[t] = copiedInto1[t];
				}
				for(t in copiedInto2){
					itemsFromBs[t] = copiedInto2[t];
				}
			}	
			
			if(orderedOrParallel){
				return this.orderedFillingEmptyEntries(bs, child1, child2, copiedInto1, copiedInto2);
			}else{
				return this.paralellFillingEmptyEntries(bs, child1, child2, copiedInto1, copiedInto2);
			}
		}
		
		
		private function orderedFillingEmptyEntries(bs:Individual, child1:Array, 
												  child2:Array, copiedInto1:Array, copiedInto2:Array):Array {
			var counterGenome:uint = 0;
			var counterBS:uint = 0;
			for(var i:uint = 0; i < this.length; i++){
				if(child1[i] == undefined){
					while(counterBS < length && copiedInto1[bs.genome[counterBS]] != undefined){
						counterBS ++;
					}
					child1[i] = bs.genome[counterBS];
					counterBS  ++;
				}
				
				if(child2[i] == undefined){
					while(counterGenome < length && copiedInto2[genome[counterGenome]] != undefined){
						counterGenome  ++;
					}
					child2[i] = genome[counterGenome];
					counterGenome  ++;
				}
			}
			var bs1:Individual = new Individual(length, true, child1);
			var bs2:Individual = new Individual(length, true, child2);
			
			return new Array(bs1, bs2);
		}
		
		private function paralellFillingEmptyEntries(bs:Individual, child1:Array, 
													 child2:Array, copiedInto1:Array, copiedInto2:Array):Array {
			for(var i:uint = 0; i < this.length; i++){
				if(child1[i] == undefined){
					//if the element in bs at pos i is not yet in child 1 then add it
					if(copiedInto1[bs.genome[i]] != true){
						child1[i] = bs.genome[i];
						copiedInto1[bs.genome[i]] = true;
					}
				}
				
				if(child2[i] == undefined){
					//if the element in this at pos i is not yet in child 2 then add it
					if(copiedInto2[genome[i]] != true){
						child2[i] = genome[i];
						copiedInto2[genome[i]] = true;
					}
				}
			}
			
			var notInChild1:Array = new Array;
			var notInChild2:Array = new Array;
			//find the missing elements
			for( i = 0; i < length; i++){
				if(copiedInto1[bs.genome[i]] != true)
					notInChild1.push(bs.genome[i]);
				
				if(copiedInto2[genome[i]] != true)
					notInChild2.push(genome[i]);
			}
			
			for(i = 0; i < length; i++){
				var randomIndex:uint;
				var temp:Number;
				if(child1[i] == undefined){
					//add one elmeent at random from notInChild1
					randomIndex = Math.floor(Math.random() * notInChild1.length);
					temp = notInChild1[notInChild1.length-1];
					notInChild1[notInChild1.length-1] = notInChild1[randomIndex];
					notInChild1[randomIndex] = temp;
					child1[i] = notInChild1.pop();
				}
				if(child2[i] == undefined){
					//add one elmeent at random from notInChild1
					randomIndex = Math.floor(Math.random() * notInChild2.length);
					temp = notInChild2[notInChild2.length-1];
					notInChild2[notInChild2.length-1] = notInChild2[randomIndex];
					notInChild2[randomIndex] = temp;
					child2[i] = notInChild2.pop();
				}
			}
			
			var bs1:Individual = new Individual(length, true, child1);
			var bs2:Individual = new Individual(length, true, child2);
			
			return new Array(bs1, bs2);
		}
		
		//swaps each entry with probability p
		public function swapMutation(entryMutationProbability:Number = .5):void {
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
		
		public function insertMutation(entryMutationProbability:Number = .5):void {
			for(var i:uint = 0; i< this.length; i++){
				if(Math.random() < entryMutationProbability){
					//swap randomly
					var temp:uint = genome[i];
					genome.splice(i, 1);
					genome.splice(Math.floor(Math.random() * this.length), 0 , temp); 
				}
			}
			computeFitness();
		}
		
		public function reverseMutation(maxSectionLength:int = -1):void {
			
			var str:String = genome.length+", " +this.genome.join(",");
			var a:Number = Math.random();
			var b:Number = Math.random();
			var min:uint = Math.floor(Math.min(a,b)* this.length);
			var max:uint = Math.floor(Math.max(a,b)* this.length);
			
			if(maxSectionLength != -1 && max - min > maxSectionLength){
				max = min + maxSectionLength;
			}
			
			var toReverse:Array = new Array;
			for(var i:uint = min; i <= max; i++){
				toReverse.push(this.genome[i]);
			}
			for(var j:uint = min; j <= max; j++){
				this.genome[j] = toReverse.pop();
			}
			
			computeFitness();
		}
		
		public function toString():String {
			return this.genome.join(",")+"\nFitness="+(100000 -this.fitness);
		}
	}
}