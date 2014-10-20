package RBTree {
	public class TreeInt {
		public var root:NodeInt;
		public var nil:NodeInt;
		
		public function TreeInt() {
			nil = new NodeInt();
			nil.left = nil;
			nil.right = nil;
			nil.parent = nil;
			nil.red = 0;
			
			root = new NodeInt();
			root.left = nil;
			root.right = nil;
			root.parent = nil;
			root.red = 0;
		}
		
		public function Delete( z:NodeInt ):void {
			var x:NodeInt;
			var y:NodeInt;
			
			y = ( (z.left == nil) || (z.right == nil) ) ? z : Next( z );
			x = (y.left == nil) ? y.right : y.left;
			
			if( root == (x.parent = y.parent) ) {
				root.left = x;
			} else {
				if( y == y.parent.left ) {
					y.parent.left = x;
				} else {
					y.parent.right = x;
				}
			}
			
			if( y != z ) {
				y.left = z.left;
				y.right = z.right;
				y.parent = z.parent;
				z.left.parent = z.right.parent = y;
				if( z == z.parent.left ) {
					z.parent.left = y;
				} else {
					z.parent.right = y;
				}
				if( y.red == 0 ) {
					y.red = z.red;
					DeleteFixUp( x );
				} else {
					y.red = z.red;
				}
			} else {
				if( y.red == 0 ) DeleteFixUp( x );
			}
		}
		
		public function Insert( z:NodeInt ) {
			var x:NodeInt;
			var y:NodeInt;
			
			z.left = z.right = nil;
			
			// ordinary binary tree insert
			y = root;
			x = root.left;
			while( x != nil ) {
				y = x;
				if( x.key > z.key ) {
					x = x.left;
					/* Not sure what to do about duplicate keys
					} else if( x.key < z.key ) {
					x = x.right;
					*/
				} else {
					x = x.right;
				}
			}
			z.parent = y;
			if( ( y == root ) || ( y.key > z.key ) ) {
				y.left = z;
			} else {
				y.right = z;
			}
			
			x = z;
			x.red = 1;
			while( x.parent.red ) {
				if( x.parent == x.parent.parent.left ) {
					y = x.parent.parent.right;
					if( y.red ) {
						y.red = 0;
						x.parent.red = 0;
						x.parent.parent.red = 1;
						x = x.parent.parent;
					} else {
						if( x == x.parent.right ) {
							x = x.parent;
							LeftRotate( x );
						}
						x.parent.red = 0;
						x.parent.parent.red = 1;
						RightRotate( x.parent.parent );
					}
				} else {
					y = x.parent.parent.left;
					if( y.red ) {
						y.red = 0;
						x.parent.red = 0;
						x.parent.parent.red = 1;
						x = x.parent.parent;
					} else {
						if( x == x.parent.left ) {
							x = x.parent;
							RightRotate( x );
						}
						x.parent.red = 0;
						x.parent.parent.red = 1;
						LeftRotate( x.parent.parent );
					}
				}
			}
			root.left.red = 0;
			return( z );
		} // Insert()
		
		public function Next( x:NodeInt ):NodeInt {
			var y:NodeInt = x.right;
			
			if( y != nil ) {
				while( y.left != nil ) y = y.left;
				return( y );
			}
			// else
			y = x.parent;
			while( x == y.right ) {
				x = y;
				y = y.parent;
			}
			if( y == root ) return( nil );
			return( y );
		}
		
		public function Prev( x:NodeInt ):NodeInt {
			var y:NodeInt = x.left;
			
			if( y != nil ) {
				while( y.right != nil ) y = y.right;
				return( y );
			}
			// else
			y = x.parent;
			while( x == y.left ) {
				if( y == root ) return( nil );
				x = y;
				y = y.parent;
			}
			return( y );
		}
		
		public function Find( key:int ):NodeInt {
			var x:NodeInt = root.left;
			
			while( x != nil ) {
				if( key < x.key ) x = x.left;
				else if( key > x.key ) x = x.right;
				else return( x );
			}
			return( null );
		}
		
		public function FindRange( low:int, high:int ):Array {
			var ret:Array = new Array();
			var x:NodeInt = root.left;
			var lastBest:NodeInt = nil;
			
			while( x != nil ) {
				if( x.key > high ) {
					x = x.left;
				} else {
					lastBest = x;
					x = x.right;
				}
			}
			while( (lastBest != nil) && (low <= lastBest.key) ) {
				ret.push( lastBest );
				lastBest = Prev( lastBest );
			}
			return( ret );
		}
		
		private function LeftRotate( x:NodeInt ):void {
			var y:NodeInt;
			
			y = x.right;
			x.right = y.left;
			
			if( y.left != nil ) y.left.parent = x;
			y.parent = x.parent;
			
			if( x == x.parent.left ) {
				x.parent.left = y;
			} else {
				x.parent.right = y;
			}
			y.left = x;
			x.parent = y;
		}
		
		private function RightRotate( y:NodeInt ):void {
			var x:NodeInt;
			
			x = y.left;
			y.left = x.right;
			
			if( x.right != nil ) x.right.parent = y;
			
			x.parent = y.parent;
			if( y == y.parent.left ) {
				y.parent.left = x;
			} else {
				y.parent.right = x;
			}
			
			x.right = y;
			y.parent = x;
		}
		
		private function DeleteFixUp( x:NodeInt ):void {
			var w:NodeInt;
			var rootLeft:NodeInt = root.left;
			
			while( (x.red == 0) && (x != rootLeft) ) {
				if( x == x.parent.left ) {
					w = x.parent.right;
					if( w.red ) {
						w.red = 0;
						x.parent.red = 1;
						LeftRotate( x.parent );
						w = x.parent.right;
					}
					if( (w.right.red == 0) && (w.left.red == 0) ) {
						w.red = 1;
						x = x.parent;
					} else {
						if( w.right.red == 0 ) {
							w.left.red = 0;
							w.red = 1;
							RightRotate( w );
							w = x.parent.right;
						}
						w.red = x.parent.red;
						x.parent.red = 0;
						w.right.red = 0;
						LeftRotate( x.parent );
						x = rootLeft; // this is to exit while loop
					}
				} else {
					// same as above but with left and right switched
					w = x.parent.left;
					if( w.red ) {
						w.red = 0;
						x.parent.red = 1;
						RightRotate( x.parent );
						w = x.parent.left;
					}
					if( (w.right.red == 0) && (w.left.red == 0) ) {
						w.red = 1;
						x = x.parent;
					} else {
						if( w.left.red == 0 ) {
							w.right.red = 0;
							w.red = 1;
							LeftRotate( w );
							w = x.parent.left;
						}
						w.red = x.parent.red;
						x.parent.red = 0;
						w.left.red = 0;
						RightRotate( x.parent );
						x = rootLeft; // this is to exit while loop
					}
				}
			}
			x.red = 0;
		} // DeleteFixUp
	}
}