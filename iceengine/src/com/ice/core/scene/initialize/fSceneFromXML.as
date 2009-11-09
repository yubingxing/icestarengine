package com.ice.core.scene.initialize{
	
	// Imports
	
	/**
	 * This is a retriever used to pass an XML object directly as scene constructor
	 */
	public class fSceneFromXML extends EventDispatcher implements fEngineSceneRetriever {
		
		// Private vars
		private var xml:XML								// Definition data
		private var path:String
		private var myTimer:Timer
		
		// Constructor
		public function fSceneFromXML(xml:XML,path:String):void {
			this.xml = xml
			this.path = path
		}
		
		/**
		 * @private 
		 * The scene will call this when it is ready to receive an scene. Then the engine will listen for a COMPLETE event
		 * before retrieving the final xml
		 */
		public function start():EventDispatcher {
			
			this.myTimer = new Timer(20, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.done)
			this.myTimer.start()
			return this
			
		}
		
		private function done(e:Event) {
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.done)
			this.dispatchEvent(new Event(Event.COMPLETE))
		}
		
		/** 
		 * @private 
		 * When this class dispatches a COMPLETE event, the scene will use this method to retrieve the XML definition
		 */
		public function getXML():XML {
			return this.xml
		}
		
		/** 
		 * @private 
		 * The scene will use this method to retrieve the basepath for this XML. This basepath will be used to resolve paths inside this XML
		 */
		public function getBasePath():String {
			return this.path
		}
		
	}
	
}