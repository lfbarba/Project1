package gp
{
	import ants.GridPixel;
	import ants.Simulator;
	
	import flash.media.Camera;
	import flash.utils.*;
	
	import gp.functions.*;
	import gp.terminals.*;
	
	public class FunctionTree implements FuncionEvaluable
	{
		public var root:TNode;
		private var _functionsClasses:Array;
		private var _terminalClasses:Array;
		private var _fitness:Number;
		private var _fitnessComputed:Boolean = false;
		
		public function FunctionTree(copyFrom:FunctionTree = null)
		{

			_functionsClasses = new Array(IfCarryingFood, IfFood, IfNest, IfPherormone, DropFood);
			_terminalClasses = new Array(MoveRandomly, MoveToNest, MoveToPherormone);
			
			if(copyFrom != null){
				this.root = copyFrom.root.copy();
			}
		}
		
		
		public function get fitness():Number {
			if(!_fitnessComputed)
				this.computeFitness();
			return this._fitness;
		}
		
		private function computeFitness():void {
			var s:Simulator = new Simulator(16, 2, false, 40);
			s.dropPileOfFood(0, 1, 2);
			s.dropPileOfFood(16, 1, 2);
			s.setNest(8, 1);
			s.numAnts = 40;
			GridPixel.dropInPherormonePerTick = .01;
			s.setAntFunction(this);
			s.changeTickTime(0);
			this._fitness = s.startSimulation();
			
			_fitnessComputed = true;
		}
		
		public function subTreeReplacementMutation():void {
			var rn:TNode = this.chooseRandomNode();
			var t:FunctionTree = new FunctionTree;
			if(Math.random() < .5){
				t.initializeRandomly(Math.floor(Math.random()*1.1*rn.maxDepth), true);
			}else{
				t.initializeRandomly(Math.floor(Math.random()*1.1*rn.maxDepth), false);
			}
			if(rn.depth > 0){
				rn.parent.replaceChild(rn, t.root);
			}else{
				this.root = t.root;
			}
			_fitnessComputed = false;
		}
		
		public function crossOver(t:FunctionTree, sizeFair:Boolean = true):Array {
			//copy and crossover the copies
			var child1:FunctionTree = new FunctionTree(this);
			var child2:FunctionTree = new FunctionTree(t);
			//
			var rn1:TNode = child1.chooseRandomNode();
			var rn2:TNode;
			if(sizeFair){
				rn2 = child2.chooseRandomNode(2*rn1.size);
			}else{
				rn2 = child2.chooseRandomNode();
			}
			var p1:TNode = (rn1.depth > 0) ? rn1.parent : null;
			var p2:TNode = (rn2.depth > 0) ? rn2.parent : null;
			if(p1 == null){//if rn1 is the root
				//if rn2 is also the root then do nothing
				if(p2 != null) {
					p2.replaceChild(rn2, rn1);
					this.root = rn2;
				}
			}else if(p2 == null){
			 	p1.replaceChild(rn1, rn2);
				t.root = rn1;
			}else {
				p2.replaceChild(rn2, rn1);
				p1.replaceChild(rn1, rn2);
			}
			return new Array(child1, child2);
		}
		
		public function get size():uint {
			return this.root.size;
		}
		
		//returns the depth of the deepest node in the tree
		public function get maxDepth():uint {
			return this.root.maxDepth;
		}
		
		private function chooseRandomNode(sizeAtMost:Number = Number.POSITIVE_INFINITY):TNode {
			try{
				var log:Array = new Array;
				var current:TNode = root;
				var nodesWithRightSize:Array = new Array;
				if(root.size <= sizeAtMost)
					nodesWithRightSize.push(root);
				while(current != null) 
				{
					log[current.identifier] = (log[current.identifier] == undefined) ? 0 : log[current.identifier];
					if(log[current.identifier] < current.numChildren){
						log[current.identifier]++;
						current = current.children[log[current.identifier]-1];
						if(current.size <= sizeAtMost)
							nodesWithRightSize.push(current);
					}else{//return to parent
						current = current.parent;
					}
				}
				var index:uint = Math.floor(Math.random() * nodesWithRightSize.length);
			}catch(e:Error){
				trace(e);
				trace(this);
				trace("nodesWithRightSize", nodesWithRightSize);
				trace("current", current);
				throw e;
			}
			return nodesWithRightSize[index];
		}
		
		public function evaluate():void {
			this.root.evaluate;
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
			var c:Class = this._terminalClasses[Math.floor(Math.random() * _terminalClasses.length)];
			return new c;
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