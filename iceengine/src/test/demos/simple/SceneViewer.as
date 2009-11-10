package test.demos.simple {

	// Imports
	import flash.display.*
	import flash.events.*
	import org.ffilmation.engine.core.*
	import org.ffilmation.engine.events.*
	import org.ffilmation.utils.*
	import org.ffilmation.engine.core.sceneInitialization.*
	import org.ffilmation.engine.elements.*
	
	/** @private */
	public class SceneViewer {
		
		// Variables
		public var timeline:MovieClip
		public var container:Sprite
		public var engine:fEngine	
		public var scene:fScene
		public var hero:poncho
		public var scenes:Object
		public var controllers:Object
		public var cameras:Object
		public var path:String
		public var destination:XML
		
		// Init demo
		public function SceneViewer(mainTimeline:MovieClip,container:Sprite,src:String) {
			
				this.timeline = mainTimeline
				this.container = container
				
				this.container.y = 25
	
				this.timeline.stage.quality = "low"
				
				this.scenes = new Object
				this.controllers = new Object
				this.cameras = new Object

				// Create engine
				this.engine = new fEngine(this.container)
				
				// Goto first scene
				this.gotoScene(src)
				
		}
	
		// Load scene start
		public function gotoScene(path:String):void {
			
				this.path = path
				
				// Stop control loop		
				this.timeline.removeEventListener('enterFrame', this.control)
				
				// Disable current
				if(this.hero) this.hero.disable()
				
				if(this.scene) this.engine.hideScene(this.scene)
	
				// Scene already loaded or not ?
				if(this.scenes[this.path]) {
					this.scene = this.scenes[this.path]
					this.hero = this.controllers[this.path]
					this.activateScene()
				} else {
					this.timeline.stage.quality = "high"
					this.timeline.gotoAndStop("Load")
					this.scenes[this.path] = this.scene = this.engine.createScene(new fSceneLoader(path),700,450)
					this.scene.addEventListener(fScene.LOADPROGRESS, this.loadProgressHandler)
					this.scene.addEventListener(fScene.LOADCOMPLETE, this.loadCompleteHandler)
				}
				
		}
	
		public function loadProgressHandler(evt:fProcessEvent):void {
				this.timeline.progres.update(evt.current,evt.currentDescription,evt.overall,evt.overallDescription)
		}
	
		public function loadCompleteHandler(evt:fProcessEvent):void {
				this.timeline.gotoAndStop("Play")
				this.timeline.stage.quality = "low"

				// Create camera
				this.cameras[this.path] = this.scene.createCamera()
				this.scene.setCamera(this.cameras[this.path])

				// Create controller
				this.controllers[this.path] = this.hero = new poncho(this.scene.all["Poncho"],this.timeline)
				this.scene.all["Poncho"].addEventListener(fCharacter.EVENT_IN, this.INlistener)

				// Activate
				this.activateScene()

		}
	
		// Load scene complete
		public function activateScene():void {
		
			// Render
			this.engine.showScene(this.scene)

			// Init keyboard
			this.hero.enable()
			
			// Start control loop		
			this.timeline.addEventListener('enterFrame', this.control)
			
			// Destination ?
			if(this.destination) {
				
				this.hero.character.moveTo(new Number(destination.enterx),new Number(destination.entery),new Number(destination.enterz))
				this.hero.character.orientation = new Number(destination.enterOrientation)
			}
			
			this.cameras[this.path].moveTo(this.hero.character.x,this.hero.character.y,this.hero.character.z)
			this.cameras[this.path].follow(this.hero.character,5)

	
		}	
	
		public function INlistener(evt:fEventIn):void {
				if(evt.name=="TELEPORT") {
					this.destination = evt.xml
					this.gotoScene(evt.xml.destination)
				}
		}	
	
	
		// Main control loop
		public function control(evt:Event) {
		}
	
	}

}
