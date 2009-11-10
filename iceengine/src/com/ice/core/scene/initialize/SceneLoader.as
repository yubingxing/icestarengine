package com.ice.core.scene.initialize {
	
	// Imports
	
	/**
	 * This is the simplest scene retriever class. Loads an scene definition from an external file
	 */
	public class SceneLoader implements fEngineSceneRetriever {
		
		// Private vars
		private var xml:XML								// Definition data
		private var src:String
		
		// Constructor
		public function SceneLoader(src:String):void {
			this.src = src
		}
		
		/**
		 * @private 
		 * The scene will call this when it is ready to receive an scene. Then the engine will listen for a COMPLETE event
		 * before retrieving the final xml
		 */
		public function start():EventDispatcher {
			
			// Start xml load process
			var url:URLRequest = new URLRequest(this.src)
			var loadUrl:URLLoader = new URLLoader(url)
			loadUrl.load(url)
			loadUrl.addEventListener(Event.COMPLETE, this.loadListener)
			return loadUrl
			
		}
		
		private function loadListener(evt:Event):void {
			this.xml = new XML(evt.target.data)
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
			return this.src
		}
		
	}
	
}