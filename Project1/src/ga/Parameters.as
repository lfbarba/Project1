package ga
{
	import fl.events.SliderEvent;
	
	import flash.events.Event;

	public class Parameters extends ParametersBase
	{	
		public function Parameters()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedStageHandler);
			super();
			populationSizeSlideBar.minimum = 100;
			populationSizeSlideBar.maximum = 1000;
			populationSizeSlideBar.snapInterval = 25;
			this.populationSizeSlideBar.addEventListener(SliderEvent.CHANGE, changeHappened);
			populationSizeSlideBar.value = 300;
			
			
			this.mutationProbabilitySlideBar.minimum = .02;
			this.mutationProbabilitySlideBar.maximum = 1;
			this.mutationProbabilitySlideBar.snapInterval = .02
			mutationProbabilitySlideBar.addEventListener(SliderEvent.CHANGE, changeHappened);
			mutationProbabilitySlideBar.value = 1;
			
			crossoverProbabilitySlideBar.minimum = .02;
			crossoverProbabilitySlideBar.maximum = 1;
			crossoverProbabilitySlideBar.snapInterval = .02;
			crossoverProbabilitySlideBar.addEventListener(SliderEvent.CHANGE, changeHappened);
			this.crossoverProbabilitySlideBar.value = .8;
		}
		
		private function addedStageHandler(e:Event):void {
			this.changeHappened();
		}
		
		public function updateNumGenerations(round:uint):void {
			this.roundNumber.text = ""+round;
		}
		
		public function getPopulationSize():uint {
			return this.populationSizeSlideBar.value;
		}
		
		public function getMutationProbability():Number {
			return this.mutationProbabilitySlideBar.value;
		}
		
		public function getCrossoverProbability():Number {
			return this.crossoverProbabilitySlideBar.value;
		}
		
		
		
		private function changeHappened(e:Event = null):void {
			this.populationSize.text = String(this.populationSizeSlideBar.value);
			this.mutationProbability.text = String(this.mutationProbabilitySlideBar.value);
			this.crossoverProbability.text = String(this.crossoverProbabilitySlideBar.value);
			notifyChanges();
		}
		
		private function notifyChanges():void {
			var e:ParametersChangeEvent = new ParametersChangeEvent(ParametersChangeEvent.PARAMETERS_CHANGE, this);
			this.stage.dispatchEvent(e);
		}
		
		public function updateStatistics(max:Number, min:Number, avg:Number, best:Number, current:Number){
			this.maxFitness.text  = String(max);
			this.minFitness.text = String(min);
			this.avgFitness.text = String(avg);
			this.bestFitness.text = String(best);
			this.currentFitness.text = String(current);
			
		}
	}
}