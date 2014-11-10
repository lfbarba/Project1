package gp
{
	import flash.media.Camera;
	
	import gp.functions.CosineFunction;
	import gp.functions.DivisionFunction;
	import gp.functions.ExpFunction;
	import gp.functions.ProductFunction;
	import gp.functions.SineFunction;
	import gp.functions.SubstractFunction;
	import gp.functions.SumFunction;
	import gp.terminals.EphemeralTerminal;
	import gp.terminals.VariableTerminal;

	public class FunctionTree implements FuncionEvaluable
	{
		public var root:TNode;
		private var _functionsClasses:Array;
		private var _fitness:Number;
		private var _fitnessComputed:Boolean = false;
		
		public function FunctionTree()
		{
			_functionsClasses = new Array(SumFunction, SubstractFunction, DivisionFunction, 
				ProductFunction, SineFunction, CosineFunction, ExpFunction);
		}
		
		public function get fitness():void {
			if(!_fitnessComputed)
				this.computeFitness();
			return this._fitness;
		}
		
		private function computeFitness():void {
			
			_fitnessComputed = true;
		}
	
		public function mutate():void {
			var rn:TNode = this.chooseRandomNode();
			var t:FunctionTree = new FunctionTree;
			if(Math.random() < .5){
				t.generateRandomly(Math.floor(Math.random()*3)*(this.maxDepth - rn.depth), true);
			}else{
				t.generateRandomly(Math.floor(Math.random()*3)*(this.maxDepth - rn.depth), false);
			}
			if(rn.depth > 0){
				rn.parent.replaceChild(rn, t.root);
			}else{
				this.root = t.root;
			}
			_fitnessComputed = false;
		}
		
		public function crossOver(t:FunctionTree, sizeFair:Boolean = true):void {
			var rn1:TNode = this.chooseRandomNode();
			var rn2:TNode;
			if(sizeFair){
				rn2 = t.chooseRandomNode(2*rn1.size);
			}else{
				rn2 = t.chooseRandomNode();
			}
			var p1:TNode = (rn1.depth > 0) ? rn1.parent : null;
			var p2:TNode = (rn2.depth > 0) ? rn2.parent : null;
			if(p1 == null){//if rn1 is the root
				//if rn2 is also the root then do nothing
				if(p2 != null) {
					p2.replaceChild(rn2, rn1);
					this.root = rn2;
				}
			}else{
				p2.replaceChild(rn2, rn1);
				p1.replaceChild(rn1, rn2);
			}
			_fitnessComputed = false;
		}
		
		public function get size():uint {
			return this.root.size;
		}
		
		//returns the depth of the deepest node in the tree
		public function get maxDepth():uint {
			return this.root.maxDepth;
		}
		
		private function chooseRandomNode(sizeAtMost:Number = Number.POSITIVE_INFINITY):TNode {
			var log:Array = new Array;
			var current:TNode = root;
			var counter:uint = 0;
			var nodesWithRightSize:Array = new Array;
			if(root.size <= sizeAtMost)
				nodesWithRightSize.push(root);
			while(current.parent != null || counter != this.size-1) {
				log[current.identifier] = (log[current.identifier] == undefined) ? 0 : log[current.identifier];
				if(log[current.identifier] < current.numChildren){
					log[current.identifier]++;
					current = current.children[log[current.identifier]-1];
					counter ++;
					if(current.size <= sizeAtMost)
						nodesWithRightSize.push(current);
				}else{//return to parent
					current = current.parent;
				}
			}
			var index:uint = Math.floor(Math.random() * nodesWithRightSize.length);
			return nodesWithRightSize[index];
		}
		
		public function evaluate(x:Number):Number {
			VariableTerminal.XVALUE = x;
			return this.root.value;
		}
		
		//generate randomly with half and half ramp
		public function initializeRandomly(maxDepth:uint, full:Boolean):void {
			if(full){
				this.root = this.generateFull(maxDepth);
			}else{
				this.root = this.generateGrow(maxDepth);
			}
			_fitnessComputed = false;
		}
	
		
		public function getRandomFunctionNode():TFunction {
			var c:Class = this._functionsClasses[Math.floor(Math.random() * _functionsClasses.length)];
			return new c;
		}
		
		public function getRandomTerminal():TTerminal {
			if(Math.random() < .5){
				return new EphemeralTerminal;
			}else{
				return new VariableTerminal;
			}
		}
		
		public function getRandomNode():TNode {
			if(Math.random() < .6){
				return this.getRandomFunctionNode() as TNode;
			}else{
				return this.getRandomTerminal() as TNode;
			}
		}
		
		private function generateFull(maxDepth:uint):TNode{ 
			var r:TNode;
			//If we are not at the max depth, choose a function
			if(maxDepth > 0) 
				r = this.getRandomFunctionNode() as TNode;
				//Otherwise, choose a terminal  
			else  
				r = getRandomTerminal() as TNode;  
			
			//fill it if it is a terminal
			if(r is TFunction){
				var func:TFunction = r as TFunction;
				for(var i:uint = 0; i < func.numArguments; i++)  {
					var newNode:TNode = generateFull(maxDepth - 1);
					r.addChild(newNode);
				}
			}
			return r;  
		}  
		
		private function generateGrow(maxDepth:uint):TNode{ 
			var r:TNode;
			//If we are not at the max depth, choose a function
			var randomNode:TNode = this.getRandomNode();
			if(maxDepth > 0) 
				r =   randomNode;
				//Otherwise, choose a terminal  
			else  
				r = getRandomTerminal() as TNode;  
			
			if(r is TFunction){
				var func:TFunction = r as TFunction;
				for(var i:uint = 0; i < func.numArguments; i++) {
					r.addChild(generateGrow(maxDepth - 1));
				}
			}
			
			return r;  
		}  
		
		public function toString():String {
			return this.root.toString();
		}
	}
}