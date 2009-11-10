package test.demos.test {

	// Imports
	
		
	/** 
	* This is a sample game engine
	* @private
	*/
	public class game extends MovieClip {
		
		// Controller type
		public static const MOUSE:int = 1
		public static const KEYBOARD:int = 2
		
		// Variables
		public var timeline:MovieClip
		public var container:Sprite
		public var snapshot:Sprite
		public var engine:fEngine	
		public var scene:fScene
		public var hero:fEngineElementController
		public var camera:fCamera
		public var controllerType = game.KEYBOARD
		public var path:String
		public var destination:XML
		public var money:Number = 0
		private var prof:fProfiler = null
		//public var filmationTest:MovieClip
		//public var profilerClip:MovieClip
		
		// Init demo
		public function game():void {
			
				// Profiler init
				ProfilerConfig.Width = 650
				this.prof = new fProfiler()
				profilerClip.addChild( this.prof )
				this.prof.y = 5
				this.timeline = this
				this.container = new Sprite()
				filmationTest.addChild(this.container)

			  // Force controller classes to be included in the compiled SWF. I know there must be a nicer way to achieve this...
			  var c1:org.ffilmation.demos.mynameisponcho.controllers.forest

				// Create engine
				fEngine.shadowQuality = fShadowQuality.GOOD
				this.engine = new fEngine(this.container)
				
				// Goto first scene
				this.gotoScene("scenes/test.xml")
				
		}
	
		// Changes controller type
		public function setControllerType(t:int):void {		
			  this.controllerType = t
				if(controllerType == game.MOUSE) this.hero = new ponchoMouseController()
				else this.hero = new ponchoKeyboardController()
				
				this.scene.all["Poncho"].controller = this.hero
				this.hero.enable()
				
		}
		
		// Load scene start
		public function gotoScene(path:String):void {
			
				// Disable current. Use snapshot for smoother transitions
				if(this.scene) this.scene.disable()
	
				// Stop control loop		
				this.timeline.removeEventListener('enterFrame', this.control)

				// Start transition
				this.path = path
				this.timeline.gotoAndPlay("Load")
		}
		
		// This allows me to animate transitions in the timeline. Call me oldschool, but I like the timeline
		public function loadTransitionDone():void {

				// Scene already loaded or not ?
				this.timeline.stage.quality = "high"
				this.scene = this.engine.createScene(new fSceneLoader(path),1000,650,null,this.prof)
				this.scene.addEventListener(fScene.LOADPROGRESS, this.loadProgressHandler,false,0,true)
				this.scene.addEventListener(fScene.LOADCOMPLETE, this.loadCompleteHandler,false,0,true)
			
		}
	
		// This allows me to animate transitions in the timeline. Call me oldschool, but I like the timeline
		public function playTransitionDone():void {
				// Activate
				this.activateScene()
		}


		public function loadProgressHandler(evt:fProcessEvent):void {
				this.timeline.progres.update(evt.current,evt.currentDescription,evt.overall,evt.overallDescription)
		}
	
		public function loadCompleteHandler(evt:fProcessEvent):void {

				this.scene.removeEventListener(fScene.LOADPROGRESS, this.loadProgressHandler)
				this.scene.removeEventListener(fScene.LOADCOMPLETE, this.loadCompleteHandler)
				this.timeline.stage.quality = "low"

				// Create camera
				this.camera = this.scene.createCamera()
				this.scene.setCamera(this.camera)

				// Create controller
				if(controllerType == game.MOUSE) this.hero = new ponchoMouseController()
				else this.hero = new ponchoKeyboardController()
				if(this.scene.all["Poncho"]) var poncho:fCharacter =  this.scene.all["Poncho"]
			  else poncho = this.scene.createCharacter("Poncho","FFCharacters_poncho",this.scene.width/2,this.scene.depth/2,this.scene.height-200)
			  poncho.occlusion = 60
				poncho.addEventListener(fCharacter.EVENT_IN, this.INlistener,false,0,true)
				poncho.addEventListener(fCharacter.WALKOVER, this.walkOverListener,false,0,true)
				
				// Scene must be shown before its graphic assets can be accessed
				this.showScene()

				this.timeline.gotoAndPlay("Play")
				
		}
	
	
		public function showScene():void {
		
			// Destination ?
			if(this.destination) {
				this.scene.all["Poncho"].moveTo(new Number(destination.enterx),new Number(destination.entery),new Number(destination.enterz))
				this.scene.all["Poncho"].orientation = new Number(destination.enterOrientation)
			}
 
 			// Place camera on hero
			this.camera.moveTo(this.scene.all["Poncho"].x,this.scene.all["Poncho"].y,this.scene.all["Poncho"].top-30)
    	this.timeline.cRollover.visible = false

			// This creates the graphics
			var mem:String = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb'
			if(this.engine.current) this.engine.destroyScene(this.engine.current)
			this.engine.showScene(this.scene)
			mem = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb'
			
			// Doors will be open when clicked
			for(var p:Number=0;p<this.scene.walls.length;p++) {
				var w:fWall = this.scene.walls[p]

				for(var h:Number=0;h<w.holes.length;h++) {
					var hole:fHole = w.holes[h]
					if(hole.block) {
						hole.block.addEventListener(MouseEvent.ROLL_OVER,this.rolloverDoor,false,0,true)
						hole.block.addEventListener(MouseEvent.ROLL_OUT,this.rolloutDoor,false,0,true)
						hole.block.addEventListener(MouseEvent.CLICK,this.clickDoor,false,0,true)
						hole.block.buttonMode = true
						hole.block.ref = hole
					}
				}
			}

			// Add specific mouse behaviours to objects. This is done here so it is aplied to all allScenes.
			// Scene-specific behavous should be done via scene controllers
			for(var i:Number=0;i<this.scene.objects.length;i++) {
				var obj:fObject = this.scene.objects[i]
				if(obj.definitionID=="MNIP_MoneyBag") {
					obj.enableMouseEvents()
					obj.container.addEventListener(MouseEvent.ROLL_OVER,this.rolloverBag,false,0,true)
					obj.container.addEventListener(MouseEvent.ROLL_OUT,this.rolloutAny,false,0,true)
				}
				if(obj.definitionID=="MNIP_Info") {
					obj.enableMouseEvents()
					obj.container.addEventListener(MouseEvent.ROLL_OVER,this.rolloverInfo,false,0,true)
					obj.container.addEventListener(MouseEvent.ROLL_OUT,this.rolloutAny,false,0,true)
				}
			}
			

		}	
		
		public function activateScene():void {

			// Init controllers
			this.scene.all["Poncho"].controller = this.hero
			this.scene.enable()
			
			// Start control loop		
			this.timeline.addEventListener('enterFrame', this.control)
			this.camera.follow(this.scene.all["Poncho"],5)

		}	


		// Mouse Event handlers for Money Bags and Info
    private function rolloverBag(evt:MouseEvent) {
    	this.timeline.cRollover.visible = true
    	this.timeline.cRollover.setText("Walk over money to collect it.")
  	}

    private function rolloverInfo(evt:MouseEvent) {
    	this.timeline.cRollover.visible = true
    	this.timeline.cRollover.setText("Walk over sign to read it.")
  	}

    private function rolloutAny(evt:MouseEvent) {
    	this.timeline.cRollover.visible = false
  	}

		// Mouse Event handlers for doors
    public function rolloverDoor(evt:MouseEvent) {
    	this.timeline.cRollover.visible = true
    	this.timeline.cRollover.setText("Click door to open it")
  	}

    public function rolloutDoor(evt:MouseEvent) {
    	this.timeline.cRollover.visible = false
  	}

    public function clickDoor(evt:MouseEvent) {
				var h:fHole = evt.target.ref as fHole
				h.open = true   
    		this.timeline.cRollover.visible = false
				
				//Restore keyboard focus
				fEngine.stage.focus = fEngine.stage 	
    }
	
		// Event handlers for our hero
		public function INlistener(evt:fEventIn):void {
				if(evt.name=="TELEPORT") {
					this.destination = evt.xml
					this.gotoScene(evt.xml.destination)
				}
		}	
	
		public function walkOverListener(evt:fWalkoverEvent):void {
			
				if(evt.victim is fObject) {
					var victim:fObject = evt.victim as fObject
					
					// When you walk on a money Bag, you collect it
					if(victim.definitionID=="MNIP_MoneyBag") {
						victim.hide()
						this.money++
						this.timeline.score.setScore(this.money)
					}
					
					// When you walk on an Info item, you read it
					if(victim.definitionID=="MNIP_Info") {
						victim.hide()
						this.scene.disable()
						this.timeline.info.visible = true
						this.timeline.info.info.text = victim.xmlObj.info
					}
					
					
				}
		}	
		
		// The info panel calls this when closed
		public function continueInfo():void {
			this.scene.enable()
		}
		
	
		// Main control loop
		public function control(evt:Event) {
			this.timeline.cRollover.x = fEngine.stage.mouseX
			this.timeline.cRollover.y = fEngine.stage.mouseY
		}
	
	}

}
