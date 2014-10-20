package RBTree {
	public class NodeInt {
		public var left:NodeInt;
		public var right:NodeInt;
		public var parent:NodeInt;
		public var red:int;
		
		// setting the key to type '*' is twice as slow
		public var key:int;   
		public var data:*;
		
		public function NodeInt( key:int=0, data:*=null ) {
			this.key = key;
			this.data = data;
		}
		
	}
}