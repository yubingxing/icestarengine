// SCENE INITIALIZER
package com.ice.core.scene.initialize {
	import com.ice.core.scene.initialize.SceneCollisionParser;
	
	// Imports
	
	
	/**
	 * <p>The fSceneInitializer class does all the job of creating an scene from an XML file.
	 * It uses all the classes in this package</p>
	 *
	 * @private
	 */
	public class SceneInitializer {		
		
		// Private properties
		private var scene:fScene
		private var retriever:fEngineSceneRetriever
		private var xmlObj:XML
		private var waitFor:EventDispatcher
		private var myTimer:Timer
		private var sceneGridSorter:SceneGridSorter
		
		// Constructor
		public function SceneInitializer(scene:fScene,retriever:*) {
			
			this.scene = scene
			this.retriever = retriever
			
		}					
		
		// Start initialization process
		public function start(): void {
			
			if(this.retriever) {
				this.waitFor = this.retriever.start()
				this.waitFor.addEventListener(Event.COMPLETE, this.loadListener)
				this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,fScene.LOADINGDESCRIPTION,0,this.scene.stat))
			}
			
		}
		
		
		// LOAD: Scene xml load event
		private function loadListener(evt:Event):void {
			
			this.waitFor.removeEventListener(Event.COMPLETE, this.loadListener)
			this.waitFor = null
			this.xmlObj = this.retriever.getXML()
			this.initialization_Part1()
			
		}
		
		// Part 1 of scene initialization is loading definitions
		private function initialization_Part1() {
			
			this.scene.resourceManager = new SceneResourceManager(this.scene)
			this.scene.resourceManager.addEventListener(fScene.LOADPROGRESS,this.part1Progress)
			this.scene.resourceManager.addEventListener(Event.COMPLETE,this.part1Complete)
			this.scene.resourceManager.addEventListener(ErrorEvent.ERROR,this.part1Error)
			
			if(this.retriever) this.scene.resourceManager.addResourcesFrom(this.xmlObj.head[0],this.retriever.getBasePath())
			else this.scene.resourceManager.addResourcesFrom(this.xmlObj.head[0],"")
			
		}
		
		private function part1Error(evt:ErrorEvent):void {
			
			this.scene.resourceManager.removeEventListener(fScene.LOADPROGRESS,this.part1Progress)
			this.scene.resourceManager.removeEventListener(Event.COMPLETE,this.part1Complete)
			this.scene.resourceManager.removeEventListener(ErrorEvent.ERROR,this.part1Error)
			
			this.scene.dispatchEvent(evt)
			
		}
		
		private function part1Progress(evt:fProcessEvent):void {
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,evt.overall >> 1,fScene.LOADINGDESCRIPTION,evt.overall,evt.currentDescription))
		}
		
		private function part1Complete(evt:Event):void {
			
			this.scene.resourceManager.removeEventListener(fScene.LOADPROGRESS,this.part1Progress)
			this.scene.resourceManager.removeEventListener(Event.COMPLETE,this.part1Complete)
			this.scene.resourceManager.removeEventListener(ErrorEvent.ERROR,this.part1Error)
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,50,fScene.LOADINGDESCRIPTION,50,"Parsing XML"))
			
			// Next step
			this.myTimer = new Timer(200, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part2)
			this.myTimer.start()
			
		}
		
		// Part 2 of scene initialization is parsing the global parameters and geometry of the scene
		private function initialization_Part2(e:Event) {
			
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part2)
			
			try {
				SceneXMLParser.parseSceneGeometryFromXML(this.scene,this.xmlObj)
			} catch(e:Error) {
				this.scene.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Scene error in geometry: "+e))
			}
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,50,fScene.LOADINGDESCRIPTION,0,"Parsing XML. Done."))
			
			// Next step
			this.myTimer = new Timer(200, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part3)
			this.myTimer.start()
			
		}
		
		// Part 3 of scene initialization is zSorting
		private function initialization_Part3(e:Event) {
			
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part3)
			
			// Build RTrees
			SceneRTreeBuilder.buildTrees(this.scene)
			
			// Start zSort
			this.sceneGridSorter = new SceneGridSorter(this.scene)
			this.sceneGridSorter.addEventListener(fScene.LOADPROGRESS,this.part3Progress)
			this.sceneGridSorter.addEventListener(Event.COMPLETE,this.part3Complete)
			this.sceneGridSorter.createGrid()
			this.sceneGridSorter.start()
			
		}
		
		private function part3Progress(evt:fProcessEvent):void {
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,50+30*evt.overall/100,fScene.LOADINGDESCRIPTION,evt.overall,evt.overallDescription))
		}
		
		private function part3Complete(evt:Event):void {
			
			this.sceneGridSorter.removeEventListener(fScene.LOADPROGRESS,this.part3Progress)
			this.sceneGridSorter.removeEventListener(Event.COMPLETE,this.part3Complete)
			this.sceneGridSorter = null
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,80,fScene.LOADINGDESCRIPTION,100,"Z sorting done."))
			
			// Next step
			this.myTimer = new Timer(200, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part4)
			this.myTimer.start()
			
		}
		
		// Collision and occlusion
		private function initialization_Part4(event:TimerEvent):void {
			
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part4)
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,90,fScene.LOADINGDESCRIPTION,100,"Calculating collision and occlusion grid."))
			
			SceneCollisionParser.calculate(this.scene)
			SceneOcclusionParser.calculate(this.scene)
			
			// Next step
			this.myTimer = new Timer(200, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part5)
			this.myTimer.start()
			
		}
		
		// Setup initial lights, render everything
		private function initialization_Part5(event:TimerEvent):void {
			
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part5)
			
			// Environment and lights
			try {
				SceneXMLParser.parseSceneEnvironmentFromXML(this.scene,this.xmlObj)
			} catch(e:Error) {
				this.scene.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Scene error in environment: "+e))
			}
			
			// Events
			try {
				SceneXMLParser.parseSceneEventsFromXML(this.scene,this.xmlObj)
			} catch(e:Error) {
				this.scene.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Scene error in event definition: "+e))
			}
			
			// Prepare characters
			var cl:int = this.scene.characters.length
			for(var j:Number=0;j<cl;j++) {
				this.scene.characters[j].cell = this.scene.translateToCell(this.scene.characters[j].x,this.scene.characters[j].y,this.scene.characters[j].z)
				this.scene.characters[j].addEventListener(fElement.NEWCELL,this.scene.processNewCell)			   
				this.scene.characters[j].addEventListener(fElement.MOVE,this.scene.renderElement)			   
			}
			
			// Create controller for this scene, if any was specified in the XML
			try {
				SceneXMLParser.parseSceneControllerFromXML(this.scene,this.xmlObj)
			} catch(e:Error) {
				//this.scene.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Scene contains an invalid controller definition. "+e))
				trace("Scene contains an invalid controller definition. "+e)
			}
			
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,95,fScene.LOADINGDESCRIPTION,100,"Rendering..."))
			
			// Next step
			this.myTimer = new Timer(200, 1)
			this.myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.initialization_Complete)
			this.myTimer.start()
			
		}
		
		// Complete process, mark scene as ready. We are done !
		private function initialization_Complete(event:TimerEvent):void {
			
			this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Complete)
			
			// Update status
			this.scene.stat = "Ready"
			this.scene.ready = true
			
			// Dispatch completion event
			this.scene.dispatchEvent(new fProcessEvent(fScene.LOADCOMPLETE,100,fScene.LOADINGDESCRIPTION,100,this.scene.stat))
			
			// Free all resources allocated by this Object, to help the Garbage collector
			this.dispose()
			
		}
		
		// Stops all processes and frees resources
		public function dispose():void {
			
			if(this.waitFor) {
				this.waitFor.removeEventListener(Event.COMPLETE, this.loadListener)
				this.waitFor = null
			}
			
			if(this.scene && this.scene.resourceManager) {
				this.scene.resourceManager.removeEventListener(fScene.LOADPROGRESS,this.part1Progress)
				this.scene.resourceManager.removeEventListener(Event.COMPLETE,this.part1Complete)
				this.scene.resourceManager.removeEventListener(ErrorEvent.ERROR,this.part1Error)
			}
			
			if(this.myTimer) {
				this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part2)
				this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part3)
				this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part4)
				this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Part5)
				this.myTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.initialization_Complete)
				this.myTimer = null
			}
			
			if(this.sceneGridSorter) {
				this.sceneGridSorter.removeEventListener(fScene.LOADPROGRESS,this.part3Progress)
				this.sceneGridSorter.removeEventListener(Event.COMPLETE,this.part3Complete)
				this.sceneGridSorter = null
			}
			
			this.scene = null
			this.retriever = null
			this.xmlObj = null
			
		}
		
		
	}
	
}
