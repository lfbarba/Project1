package grapher
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gp.TNode;
	import gp.functions.*;

	public class FunctionChooser extends FunctionChooserBase
	{
		private var functionPool:Array;
		public var selectedFunctions:Array;
		
		public function FunctionChooser()
		{
			super();
			this.x = 225;
			this.y = 85;
			functionPool = new Array(SineFunction, CosineFunction, SqrtFunction, ExpFunction);
			selectedFunctions = new Array(SumFunction, SubstractFunction, DivisionFunction, 
				ProductFunction);
			displayFunctions();
			this.closeButton.addEventListener(MouseEvent.CLICK, this.close);
		}
		
		private function findIndex(a:Object, array:Array):int {
			for(var i:uint = 0; i< array.length; i++){
				if(a == array[i].icon)
					return i;
			}	
			return -1;
		}
		
		private function exchange(e:MouseEvent):void {
			var icon:Sprite = e.target as Sprite;
			if(findIndex(icon, functionPool) != -1){
				selectedFunctions.push(functionPool[findIndex(icon, functionPool)]);
				functionPool.splice(findIndex(icon, functionPool), 1);
			}else{
				functionPool.push(selectedFunctions[findIndex(icon, selectedFunctions)]);
				selectedFunctions.splice(findIndex(icon, selectedFunctions), 1);
			}
			displayFunctions();
		}
		
		private function displayFunctions():void {
			for(var i:uint = 0; i< functionPool.length; i++){
				var icon:Sprite = functionPool[i].icon as Sprite;
				if(icon != null && !this.contains(icon)){
					this.addChild(icon);
					icon.addEventListener(MouseEvent.CLICK, exchange);
				}
				Tweener.addTween(icon, {x:488+ (i%3)*100, y:50 + Math.floor(i/3) *100, time:.5}); 
			}
			
			for(i = 0; i< selectedFunctions.length; i++){
				icon = selectedFunctions[i].icon as Sprite;
				if(icon != null && !this.contains(icon)){
					this.addChild(icon);
					icon.addEventListener(MouseEvent.CLICK, exchange);
				}
				Tweener.addTween(icon, {x:18+ (i%3)*100, y:50 + Math.floor(i/3) *100, time:.5}); 
			}
		}
		
		public function open(e:Event = null):void {
			this.alpha = 0;
			this.visible = true;
			Tweener.addTween(this, {alpha:1, time:.5});
		}
		
		public function close(e:Event = null):void {
			Tweener.addTween(this, {alpha:0, visible:false, time:.5});
		}
		
		
	}
}