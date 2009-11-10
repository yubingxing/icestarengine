package test.demos.simple {
	import com.ice.core.bullet.LineBulletRenderer;
	import com.ice.core.events.ShotEvent;
	import com.ice.core.objects.fCharacter;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	
	/**
	 This class controls the hero in our demo
	 */	
	/** @private */
	public class poncho {
		
		// These are the Keys we use to move our character
		public static var UP:int = 87;
		public static var DOWN:int = 83;
		public static var LEFT:int = 65;
		public static var RIGHT:int = 68;
		public static var RUN:int = Keyboard.SHIFT;
		public static var JUMP:int = Keyboard.SPACE;
		
		// Bullet speed
		public static var bulletSpeed:Number = 150;
		
		// Properties
		public var character:fCharacter;
		private var timeline:MovieClip;
		private var keysDown:Object;
		private var bulletRenderer:LineBulletRenderer;
		private var gunS:Sound = new gunSound();
		private var ricochetS:Sound = new ricochetSound();
		
		
		// Status
		public var running:Boolean
		public var walking:Boolean
		public var crouching:Boolean
		public var shooting:Boolean
		public var jumping:Boolean
		public var rolling:Boolean
		public var cnt:Number
		public var angle:Number
		public var turnSpeed:Number
		public var vx:Number
		public var vy:Number
		public var vz:Number
		
		// Constructor
		public function poncho(char:fCharacter,timeline:MovieClip):void {
			
			this.bulletRenderer = new LineBulletRenderer(0xFFFFFF,2,0.5,"Ricochet","Blood","Ricochet")
			
			this.character = char
			this.timeline = timeline
			
			// Init position and speed
			this.angle = 0
			this.vx = 0
			this.vy = 0
			this.vz = 0
			this.character.orientation = this.angle
			
		}
		
		public function enable() {
			this.keysDown = new Object()
			this.timeline.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyPressed)
			this.timeline.stage.addEventListener(KeyboardEvent.KEY_UP, this.keyReleased)
			this.timeline.addEventListener('enterFrame', this.control)
			this.character.addEventListener(fCharacter.COLLIDE, this.collision)
			this.character.scene.container.addEventListener(MouseEvent.MOUSE_DOWN, this.clic)
		}
		
		public function disable() {
			this.timeline.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyPressed)
			this.timeline.stage.removeEventListener(KeyboardEvent.KEY_UP, this.keyReleased)
			this.timeline.removeEventListener('enterFrame', this.control)
			this.character.removeEventListener(fCharacter.COLLIDE, this.collision)
			this.stopRunning()		
			this.stopWalking()
			this.character.gotoAndPlay("Stand")
			this.vx = this.vy = this.vz = 0
			this.keysDown = null
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
							poncho.bulletSpeed*dx,poncho.bulletSpeed*dy,poncho.bulletSpeed*dz,
							this.bulletRenderer)		
						
						b.addEventListener(fBullet.SHOT,this.shotListener)																								 
						
						// Shoot animation
						this.shoot()						
						
					}
				}
			} else {
				trace("out")
			}
			
		}
		
		
		// Receives gunshots
		private function shotListener(evt:ShotEvent):void {
			evt.bullet.removeEventListener(fBullet.SHOT,this.shotListener)
			this.ricochetS.play()
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
				
				case poncho.JUMP: this.jump(); break;
				
				case poncho.RUN: this.run(); break;
				
				case poncho.UP: this.walk(); break;
				
				case poncho.DOWN: this.walk(); break;
				
				case poncho.LEFT: this.walk(); break;
				
				case poncho.RIGHT: this.walk(); break;
				
				
			} 
			
			
		}
		
		// Receives key releases
		private function keyReleased(evt:KeyboardEvent):void {
			
			delete this.keysDown[evt.keyCode]
			
			switch(evt.keyCode) {
				
				case poncho.RUN: this.stopRunning(); break;
				
				case poncho.UP: this.stopWalking(); break;
				
				case poncho.RIGHT: this.stopWalking(); break;
				
				case poncho.LEFT: this.stopWalking(); break;
				
				case poncho.DOWN: this.stopWalking(); break;
				
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
			if(this.rolling || this.jumping) {
				
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
			} else if(this.walking){
				this.vx = 8*Math.cos(angleRad)
				this.vy = 8*Math.sin(angleRad)
			} else return
				
				this.rolling = true
			this.cnt = 25
			this.character.gotoAndPlay("Roll")
			
			this.timeline.addEventListener('enterFrame', this.controlDodge)			
			
		}
		
		public function controlDodge(evt:Event):void {
			this.cnt--
			if(this.cnt==0) {
				this.timeline.removeEventListener('enterFrame', this.controlDodge)
				this.doneDodging()
			}
		}
		
		public function doneDodging():void {
			
			this.rolling = false
			if(this.walking) {
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
			if(this.walking) return
				
				this.walking = true
			
			// If dodging, ignore
			if(this.rolling || this.jumping) return
			
			if(this.running) this.character.gotoAndPlay("Run")
			else this.character.gotoAndPlay("Walk")
			
		}
		
		public function stopWalking():void {
			this.updateAngle()
			if(this.keysDown[poncho.UP] == true || this.keysDown[poncho.DOWN] == true || this.keysDown[poncho.LEFT] == true || this.keysDown[poncho.RIGHT] == true) 
				return
				this.walking = false
			if(!this.rolling && !this.jumping) this.character.gotoAndPlay("Stand")
		}
		
		private function updateAngle():void {
			if(this.keysDown[poncho.UP] == true) {
				if(this.keysDown[poncho.LEFT] == true) this.angle = 270
				else if(this.keysDown[poncho.RIGHT] == true) this.angle = 0
				else this.angle = 315
			} else if(this.keysDown[poncho.DOWN] == true) {
				if(this.keysDown[poncho.LEFT] == true) this.angle = 180
				else if(this.keysDown[poncho.RIGHT] == true) this.angle = 90
				else this.angle = 135
			} else if(this.keysDown[poncho.RIGHT] == true) {
				this.angle = 45
			}	else if(this.keysDown[poncho.LEFT] == true) {
				this.angle = 225
			}
			if(!this.rolling) this.character.orientation = this.angle
		}
	}
}

