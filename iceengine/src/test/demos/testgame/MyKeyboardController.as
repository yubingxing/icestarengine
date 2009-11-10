package test.demos.testgame {

	// Imports
	import flash.display.*
	import flash.events.*
	import flash.media.*
	import flash.ui.Keyboard
	import org.ffilmation.utils.*
	import org.ffilmation.engine.core.*
	import org.ffilmation.engine.elements.*
	import org.ffilmation.engine.datatypes.*
	import org.ffilmation.engine.events.*
	import org.ffilmation.engine.interfaces.*
	import org.ffilmation.engine.bulletRenderers.*

	/** 
	* This is a sample of a character controller that listens to keyboard events
	* @private
	*/
	public class MyKeyboardController implements fEngineElementController {
		
		// These are the Keys we use to move our character
		public static var UP:int = 87
		public static var DOWN:int = 83
		public static var LEFT:int = 65
		public static var RIGHT:int = 68
		public static var RUN:int = Keyboard.SHIFT
		public static var JUMP:int = Keyboard.SPACE
		public static var CROUCH:int = Keyboard.CONTROL
		
		// Bullet speed
		public static var bulletSpeed:Number = 150
	
		// Properties
		public var character:fCharacter
		private var keysDown:Object
		private var bulletRenderer:fLineBulletRenderer
		private var gunS:Sound = new gunSound()
		private var ricochetS:Sound = new ricochetSound()

		// Status
		public var running:Boolean = false
		public var walking:Boolean = false
		public var crouching:Boolean = false
		public var shooting:Boolean = false
		public var jumping:Boolean = false
		public var rolling:Boolean = false
		public var cnt:Number
		public var angle:Number
		public var vx:Number
		public var vy:Number
		public var vz:Number
		
		
		// Constructor
		public function MyKeyboardController():void { 
			this.bulletRenderer = new fLineBulletRenderer(0xFFFFFF,2,1,"Ricochet","Blood","Ricochet")
		}
		
		// Implements interface
		public function assignElement(element:fElement):void {

			this.character = element as fCharacter
			
			// Init position and speed
			this.angle = this.character.orientation
			this.vx = 0
			this.vy = 0
			this.vz = 0

		}

		// Implements interface
		public function enable():void {
			this.keysDown = new Object()
			fEngine.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyPressed,false,0,true)
			fEngine.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyReleased,false,0,true)
			fEngine.stage.addEventListener('enterFrame', this.control,false,0,true)
			this.character.addEventListener(fCharacter.COLLIDE, this.collision,false,0,true)
			this.character.scene.container.addEventListener(MouseEvent.MOUSE_DOWN, this.clic,false,0,true)
		}

		// Implements interface
		public function disable():void {
			fEngine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyPressed)
			fEngine.stage.removeEventListener(KeyboardEvent.KEY_UP, this.keyReleased)
			fEngine.stage.removeEventListener('enterFrame', this.control)
			this.character.removeEventListener(fCharacter.COLLIDE, this.collision)
		  this.keysDown = {}
			this.stopRunning()		
		  this.stopWalking()
		  this.character.gotoAndPlay("Stand")
		  this.vx = this.vy = this.vz = 0
			this.character.scene.container.removeEventListener(MouseEvent.MOUSE_DOWN, this.clic)
		}

		// Process Mouse clic
		private function clic(evt:MouseEvent):void {
			var ret:Array = this.character.scene.translateStageCoordsToElements(evt.stageX,evt.stageY)
			if(ret) {
				var some:Boolean = false
				for(var i:Number=0;!some && i<ret.length;i++) {
					if(ret[i].element!=this.character) {
						some = true
						var destiny:fPoint3d = ret[i].coordinate
						if(this.rolling || this.jumping) return
						
						// Real gun height
						if(this.crouching) var gunZ:Number = this.character.z+45
						else gunZ = this.character.z+80
						
						var angle:Number = mathUtils.getAngle(this.character.x,this.character.y,destiny.x,destiny.y)
						this.character.orientation = this.angle = angle 

						// Generate bullet
						var dx:Number = destiny.x-this.character.x
						var dy:Number = destiny.y-this.character.y
						var dz:Number = destiny.z-gunZ
						
						var dtotal:Number = Math.abs(dx)+Math.abs(dy)+Math.abs(dz)
						dx/=dtotal
						dy/=dtotal
						dz/=dtotal
						
						var b:fBullet = this.character.scene.createBullet(this.character.x+60*dx,this.character.y+60*dy,gunZ,
																														 MyKeyboardController.bulletSpeed*dx,MyKeyboardController.bulletSpeed*dy,MyKeyboardController.bulletSpeed*dz,
																														 this.bulletRenderer)		
																														 
						b.addEventListener(fBullet.SHOT,this.shotListener,false,0,true)																								 
						
						// Shoot animation
						this.shoot()						
						
					}
				}
			} else {
				trace("out")
			}
			
		}


		// Receives gunshots
	  private function shotListener(evt:fShotEvent):void {
	  	evt.bullet.removeEventListener(fBullet.SHOT,this.shotListener)
	  	this.ricochetS.play()
	  	
	  	// Kill other characters
	  	if(evt.element is fCharacter) {
	  		var c:fCharacter = evt.element as fCharacter
	  		if(c!=this.character) c.scene.removeCharacter(c)
	  	}
	  	/*if(evt.element is fWall) {
	  		evt.element.hide()
			}*/

	  }

		public function shoot():void {
		
			// If dodging, ignore
			if(this.shooting) return
			if(this.walking) this.stopWalking()
			if(this.crouching) this.character.gotoAndPlay("CrouchFire")
			else this.character.gotoAndPlay("StandFire")			
			
			this.gunS.play()
			
			this.vx = this.vy = 0
			this.shooting = true
			this.cnt = 6
			fEngine.stage.addEventListener('enterFrame', this.controlShoot)			
			
		}

		public function controlShoot(evt:Event):void {
			this.cnt--
			if(this.cnt==0) {
				fEngine.stage.removeEventListener('enterFrame', this.controlShoot)
				this.doneShooting()
			}
		}
		
		public function doneShooting():void {
			this.shooting = false
			if(this.walking) {
				if(this.running) this.character.gotoAndPlay("Run")
				else this.character.gotoAndPlay("Walk")
			}
		}



		// Receives keypresses		
	  private function keyPressed(evt:KeyboardEvent):void {
		    
				// Ignore auto key repeats
				if(this.keysDown[evt.keyCode] == true) return
				this.keysDown[evt.keyCode] = true
				
		    switch(evt.keyCode) {
		
		    	case MyKeyboardController.CROUCH: if(this.running || this.walking) {
		    																					this.dodge()
		    																				} else {
		    																					if(!this.crouching) this.crouch()
		    																					else this.stopCrouching()
		    																				}
		    																				break;
		
		    	case MyKeyboardController.JUMP: if(this.crouching) this.dodge(); else this.jump(); break;
		
		    	case MyKeyboardController.RUN: this.run(); break;
		
		    	case MyKeyboardController.UP: this.walk(); break;

		    	case MyKeyboardController.DOWN: this.walk(); break;

		    	case MyKeyboardController.LEFT: this.walk(); break;

		    	case MyKeyboardController.RIGHT: this.walk(); break;
		    } 


		}
				
		// Receives key releases
		private function keyReleased(evt:KeyboardEvent):void {
		
				delete this.keysDown[evt.keyCode]

		    switch(evt.keyCode) {
		
		    	case MyKeyboardController.RUN: this.stopRunning(); break;
		
		    	case MyKeyboardController.UP: this.stopWalking(); break;

		    	case MyKeyboardController.DOWN: this.stopWalking(); break;

		    	case MyKeyboardController.LEFT: this.stopWalking(); break;
		    	
		    	case MyKeyboardController.RIGHT: this.stopWalking(); break;
		    	
		    } 
		
		}
		
		// Main control loop
		public function control(evt:Event) {
			
				var x:Number = this.character.x
				var y:Number = this.character.y
				var z:Number = this.character.z
				var angleRad:Number = this.angle*Math.PI/180
				
				// Gravity
				this.vz-=1
				
				// Speed from status
				if(this.rolling || this.jumping || this.crouching || this.shooting) {
				
				} else if(this.walking) {
					
					if(this.running) {
						this.vx = 10*Math.cos(angleRad)
						this.vy = 10*Math.sin(angleRad)
					} else {
						this.vx = 5*Math.cos(angleRad)
						this.vy = 5*Math.sin(angleRad)
					}
					
				} else {
					
					this.vx = 0
					this.vy = 0
					
				}
				
				if(this.vx!=0 || this.vy!=0 || this.vz!=0) this.character.moveTo(x+this.vx,y+this.vy,z+this.vz)
				
		}

		// Collision listener
		public function collision(evt:fCollideEvent):void {
			
				// The character is smart enought to climb small walls
 				if(evt.victim is fWall) {
 					var w:fWall = evt.victim as fWall
 					if(w.top<=(this.character.z+20)) {
 						this.vz = 4 //This is kind of eye-balling it
						if(w.top<(this.character.z+10)) this.character.moveTo(this.character.x+this.vx,this.character.y+this.vy,Math.min(this.character.z+10,w.top))
					}
 				}			
			
				if(evt.victim is fFloor || (evt.victim is fObject && this.character.z>evt.victim.top)) {
					this.vz = 0
					
					if(this.jumping) {
						if(this.walking) {
							if(this.running) this.character.gotoAndPlay("Run")
							else this.character.gotoAndPlay("Walk")
						} 
						else this.character.gotoAndPlay("Land")
					}
					this.jumping = false
				}
				
		}

		// Movement methods
		public function crouch():void {
			this.crouching = true
			this.character.gotoAndPlay("Crouch")
		}
		
		public function stopCrouching():void {
			this.crouching = false
			if(!this.rolling) this.character.gotoAndPlay("Rise")
		}
		
		public function jump():void {
			
			// If dodging, ignore
			if(this.rolling || this.jumping) return

			this.vz = 15
			this.jumping = true
			this.character.gotoAndPlay("Jump")
			
	  }


		public function dodge():void {
		
			// If dodging, ignore
			if(this.rolling) return
		
			var angleRad:Number = this.angle*Math.PI/180
			

			if(this.running) {
				this.vx = 12*Math.cos(angleRad)
				this.vy = 12*Math.sin(angleRad)
			} else if(this.walking || this.crouching){
				this.vx = 8*Math.cos(angleRad)
				this.vy = 8*Math.sin(angleRad)
			} else return
			
			this.rolling = true
			if(this.crouching) {
				this.cnt = 21
				this.character.gotoAndPlay("Roll2")
			} else {
				this.cnt = 25
				this.character.gotoAndPlay("Roll")
			}
		
			fEngine.stage.addEventListener('enterFrame', this.controlDodge)			
			
		}

		public function controlDodge(evt:Event):void {
			this.cnt--
			if(this.cnt==0) {
				fEngine.stage.removeEventListener('enterFrame', this.controlDodge)
				this.doneDodging()
			}
		}
		
		public function doneDodging():void {
	
			this.rolling = false
			if(this.crouching) {
				this.character.gotoAndStop("Down")
				this.vx = this.vy = 0
		  } else if(this.walking) {
				if(this.running) this.character.gotoAndPlay("Run")
				else this.character.gotoAndPlay("Walk")
			} 
			else this.character.gotoAndPlay("Stand")

			this.character.orientation = this.angle

		}
		
		
		public function run():void {
				
			this.running = true
		
			// If dodging, ignore
			if(this.rolling) return
		
			if(this.walking) {
				this.character.gotoAndPlay("runLoop")
			}
					
		}
		
		public function stopRunning():void {
		
			this.running = false
		
			// If dodging, ignore
			if(this.rolling) return
		
			if(this.walking) {
				this.character.gotoAndPlay("walkLoop")
			}
		
		}
		
		
		public function walk():void {
			
			this.updateAngle()
		
			// If already walking, don't reset animation
			if(this.walking || this.crouching) return
			
			this.walking = true

			// If dodging, ignore
			if(this.rolling || this.jumping ) return

			if(this.running) this.character.gotoAndPlay("Run")
			else this.character.gotoAndPlay("Walk")
		
		}
		
		public function stopWalking():void {
		
			this.updateAngle()
			if(this.keysDown[MyKeyboardController.UP] == true || this.keysDown[MyKeyboardController.DOWN] == true || this.keysDown[MyKeyboardController.LEFT] == true || this.keysDown[MyKeyboardController.RIGHT] == true) return

			this.walking = false
			if(!this.rolling && !this.jumping && !this.crouching) this.character.gotoAndPlay("Stand")
		
		}


		private function updateAngle():void {
			
			if(this.keysDown[MyKeyboardController.UP] == true) {
				
				if(this.keysDown[MyKeyboardController.LEFT] == true) this.angle = 270
				else if(this.keysDown[MyKeyboardController.RIGHT] == true) this.angle = 0
				else this.angle = 315
				
			} else if(this.keysDown[MyKeyboardController.DOWN] == true) {
				
				if(this.keysDown[MyKeyboardController.LEFT] == true) this.angle = 180
				else if(this.keysDown[MyKeyboardController.RIGHT] == true) this.angle = 90
				else this.angle = 135
				
			} else if(this.keysDown[MyKeyboardController.RIGHT] == true) {
				
				this.angle = 45
			
			}	else if(this.keysDown[MyKeyboardController.LEFT] == true) {
				
				this.angle = 225
			
			}
			
			if(!this.rolling) this.character.orientation = this.angle
			
		}
		
		
	}

}

