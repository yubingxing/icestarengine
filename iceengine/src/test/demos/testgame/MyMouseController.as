package test.demos.testgame {

	// Imports
	import flash.display.*
	import flash.events.*
	import flash.ui.Keyboard
	import org.ffilmation.utils.*
	import org.ffilmation.engine.core.*
	import org.ffilmation.engine.datatypes.*
	import org.ffilmation.engine.elements.*
	import org.ffilmation.engine.events.*
	import org.ffilmation.engine.interfaces.*

	/** 
	* This is a sample of a character controller that listens to mouse events
	* @private
	*/
	public class MyMouseController implements fEngineElementController {
	
		// Properties
		public var character:fCharacter

		// Status
		public var walking:Boolean
		public var angle:Number
		public var dx:Number
		public var dy:Number
		public var dz:Number
		public var vx:Number
		public var vy:Number
		public var currentPath:Array
		public var lastDistance:Number
		public var stuck:Number = 0
		
		// Constructor
		public function MyMouseController():void { 
		}
		
		// Implements interface
		public function assignElement(element:fElement):void {

			this.character = element as fCharacter
			
			// Init position and destiny
			this.angle = this.character.orientation
			this.dx = this.character.x
			this.dy = this.character.y
			this.dz = this.character.z
			this.walking = false

		}

		// Implements interface
		public function enable():void {
			this.character.scene.container.addEventListener(MouseEvent.CLICK, this.clic,false,0,true)
			fEngine.stage.addEventListener('enterFrame', this.control,false,0,true)
			this.character.addEventListener(fCharacter.COLLIDE, this.collision,false,0,true)
			this.walking = false

		}

		// Implements interface
		public function disable():void {
			this.character.scene.container.removeEventListener(MouseEvent.CLICK, this.clic)
			fEngine.stage.removeEventListener('enterFrame', this.control)
			this.character.removeEventListener(fCharacter.COLLIDE, this.collision)
		  this.stopWalking()
			this.dx = this.character.x
			this.dy = this.character.y
			this.dz = this.character.z
		}

		// Process Mouse clic
		public function clic(evt:MouseEvent):void {
			var ret:Array = this.character.scene.translateStageCoordsToElements(evt.stageX,evt.stageY)
			if(ret) {
				for(var i:Number=0;i<ret.length;i++) {
					if(ret[i].element is fFloor) {
						this.currentPath = this.character.scene.AI.findPath(new fPoint3d(this.character.x,this.character.y,this.character.z),ret[i].coordinate)
						if(this.currentPath && this.currentPath.length>0) this.walkTo(this.currentPath.shift())
						break;
					}
				}
			} else {
				trace("out")
			}
			
		}
		
		// Makes our character walk towards a given point
		public function walkTo(where:fPoint3d):void {
			
			this.dx = where.x
			this.dy = where.y
			this.dz = where.z
			this.angle = mathUtils.getAngle(this.character.x,this.character.y,this.dx,this.dy)
			this.character.orientation = this.angle
			this.walk()
			
		}


		// Main loop
		public function control(evt:Event) {
			
			if(this.walking) {

					var angleRad:Number = this.angle*Math.PI/180
					this.vx = 5*Math.cos(angleRad)
					this.vy = 5*Math.sin(angleRad)
					
					// In a perfect world, I would program a jump animation for this. Now our hero just flies around
					var vz:Number = (this.dz-this.character.z)/2
					
					if(vx!=0 || vy!=0 || vz!=0) this.character.moveTo(this.character.x+this.vx,this.character.y+this.vy,this.character.z+vz)			
					
					// We reached our destination ?
					var d:Number=mathUtils.distance3d(this.character.x,this.character.y,this.character.z,this.dx,this.dy,this.dz)
					
					// Are we stuck ?
					if(Math.abs(d-this.lastDistance)<2 || d>this.lastDistance) {
						this.stuck+=3
					} else {
						this.stuck--
					}
					
					if(d<this.character.radius || this.stuck>60) {
						  if(this.currentPath && this.currentPath.length>0) this.walkTo(this.currentPath.shift())
							else this.stopWalking()
							this.stuck = 0
					}
					
					this.lastDistance = d
			}

		}

		// Collision listener
		public function collision(evt:fCollideEvent):void {
			
				// The character is smart enought to climb small walls
				if(evt.victim is fWall) {
					var w:fWall = evt.victim as fWall
					//trace(this.character.z+" "+w.top)
					if(w.top<=(this.character.z+20)) {
						trace("Climb")
						this.character.moveTo(this.character.x+this.vx,this.character.y+this.vy,Math.min(this.character.z+10,w.top))
					}
				}
				
				// Don't walk down floors
				if(evt.victim is fFloor) {
					var f:fFloor = evt.victim as fFloor
					this.character.moveTo(this.character.x+this.vx,this.character.y+this.vy,f.top)
				}
		}

		
		public function walk():void {
			
			// If already walking, don't reset animation
			if(this.walking) return
			
			this.walking = true
			this.character.gotoAndPlay("Walk")
		
		}
		
		public function stopWalking():void {
		
			this.walking = false
			this.character.gotoAndStop("Stand")
		
		}
		
	}

}

