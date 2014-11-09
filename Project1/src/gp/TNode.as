package gp
{
	import flash.utils.*; 
	
	public class TNode
	{
		
		public var children:Array;
		private var _numChildren:uint = 0;
		
		private var _parent:TNode;
		
		private var _size:uint = 0;
		
		public function TNode()
		{
			children = new Array;
		}
		
		public function replaceChild(old:TNode, nuevo:TNode):void {
			for(var i:uint = 0; i< children.length; i++){
				if(children[i] === old){
					children[i] = nuevo;
					nuevo.setParent(this);
				}
			}
		}
		
		public function setParent(n:TNode):void {
			this._parent = n;
		}
		
		public function get parent():TNode {
			return this._parent;
		}
		
		public function get size():uint {
			throw new Error("size Needs to be override");
		}
		
		public function get maxDepth():uint {
			throw new Error("depth Needs to be override");
		}
		
		public function get depth():uint {
			var d:uint = 0;
			var current:TNode = this;
			while(current.parent != null){
				current = current.parent;
				d++;
			}
			return d;
		}
		
		
		public function addChild(n:TNode):void {
			this.children.push(n);
			n.setParent(this);
			_numChildren++;
		}
		
		public function replaceChildAt(index:uint, n:TNode):void {
			if(this.children[index] != undefined){
				this.children[index] = n;
			}else{
				throw(new Error("Index our of reach in children array"));
			}
		}
		
		public function get numChildren():uint {
			return _numChildren;
		}
		
		public function get value():*{
			
		}
		
		public function getClass():Class {
			return Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		public function toString():String {
			return "empty";
		}
	}
}