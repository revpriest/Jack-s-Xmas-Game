var screenWidth = 700;
var screenHeight = 600;
var maxspeed=0.01;
var acceleration=0.001;
var deceleration=0.9;
var santaScale=20;
var collisionDiameter = 0.078;
var score=0;
_root.canAdd = true;

//We define the coordinates of the geometric display.
//and work out the slope of the lines.
//419 198
var bottomLeftX = 0-500;  var bottomLeftY = 554;
var topLeftX=910-500;       var topLeftY=350;
var bottomRightX = 890-500; var bottomRightY = 662;
var leftLinedx = topLeftX-bottomLeftX;
var leftLinedy = topLeftY-bottomLeftY;
var bottomLinedx = bottomRightX-bottomLeftX;
var bottomLinedy = bottomRightY-bottomLeftY;
var bottleShatter = new Sound(this);
bottleShatter.attachSound("shatter");
var bottleBounce = new Sound(this);
bottleBounce.attachSound("glassbounce");
var bashDesk = new Sound(this);
bashDesk.attachSound("banging");
var claps = new Sound(this);
claps.attachSound("claps");
var gameEnded=false;
var startedAlready=false;
var throwFrame=-1;
var np=0;
var walkAnimFrames = [2,3,4,5,6,7,8,7,6,5,4,3];
var throwFrames = [9,10,11,12,13,14,15];
var walkAnimFrame=0;
var throwPressed=false;
var userMessagePause = 0;

var objects = new Array();
var numobjects=0;
var newLayer=100;
var screenWidth_2 = screenWidth/2;  //Half the width of the screen
var screenHeight_2 = screenHeight/2;    //Half the height of the screen


/*********************************
* Listen for the video to end
*/
var listenerObject:Object = new Object();
listenerObject.complete = function(eventObject:Object):Void {
    trace("Clip Ending");
//    endGame();
};
_root.videoClip.addEventListener("complete", listenerObject);


_root.replayButton.onRelease = function(){
    trace("Replay");
    setup();
}


/***************************************************
* Set the user-message and start the credit rolling
*/
function userMessage(s){
    trace("Setting mess");
    _root.userMessageText._y = 50;
    _root.userMessageShadow._y = 52;
    userMessagePause = 100;
    if(s==""){
        trace("Mess emptying");
        _root.userMessageShadow.htmlText = _root.userMessageText.htmlText = "";
        return;
    }
    _root.userMessageShadow.htmlText = 
    _root.userMessageText.htmlText = "<p align=\"center\"><font size=\"30\">"+s+"</font>"+credits+"</p>";
}
var credits = "<font size=\"20\"><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"+
"<br/><font size=\"30\"><b>Handsome Jack's Showband</b></font>"+
"<br/>Vocals And Guitar - Adam"+
"<br/>Lead Guitar - Paul"+
"<br/>Bass - Andi"+
"<br/>Drums - Dom"+
"<br/>Special Guest Vocals - Sammy"+
"<br/><a href=\"http://handsomejacks.co.uk/\">http://handsomejacks.co.uk/</a>"+
"<br/>"+
"<br/>Covering a song by The Pogues"+
"<br/><a href=\"http://pogues.com/\">http://pogues.com/</a>"+
"<br/>"+
"<br/><font size=\"30\"><b>Game</b></font>"+
"<br/>Programming - Adam Priest"+
"<br/><a href=\"http://dalliance.net/\">http://dalliance.net/</a>"+
"<br/>"+
"<br/>Santa - Gordon Goodwin, Feelgoodcomics"+
"<br/><a href=\"http://www.blendswap.com/3D-models/characters/santa-clause/\">http://www.blendswap.com/3D-models/characters/santa-clause/</a>"+
"<br/>"+
"<br/>Pirate - Clint Bellanger"+
"<br/><a href=\"http://opengameart.org/content/pirate\">http://opengameart.org/content/pirate</a>"+
"<br/>"+
"<br/>Bottle - Clint Bellanger"+
"<br/><a href=\"http://opengameart.org/content/dinnerware\">http://opengameart.org/content/dinnerware</a>"+
"<br/>"+
"<br/>Table and chair - Airkel"+
"<br/><a href=\"http://opengameart.org/content/low-poly-furniture\">http://opengameart.org/content/low-poly-furniture</a>"+
"<br/>"+
"<br/>Room - Rui Teixeira"+
"<br/><a href=\"http://blender.ruijst.com/2011/04/24/realistic-interior-scene-bedroom-update2/\">http://blender.ruijst.com/2011/04/24/realistic-interior-scene-bedroom-update2/</a>"+
"<br/>"+
"<br/>Bottle Shatter Sound - Mike Koenig"+
"<br/><a href=\"http://soundbible.com/105-Light-Bulb-Breaking.html\">http://soundbible.com/105-Light-Bulb-Breaking.html</a>"+
"<br/>"+
"<br/>Other Sounds - Adam Priest"+
"<br/><a href=\"http://dallliance.net/\">http://dalliance.net/</a>"+
"<br/>"+
"<br/><font size=\"30\"><b>Copyright</b></font>"+
"<br/>The entire work is licensed under the Creative Commons"+
"<br/>Sharealike Attribute licence, 2011."+
"<br/><a href=\"http://creativecommons.org/licenses/by-sa/2.5/\">http://creativecommons.org/licenses/by-sa/2.5/</a>"+
"<br/>"+
"<br/>This is a Commons Hostage project for Handsome Jack's"+
"<br/>Showband. It's released freely, we'll do more similar"+
"<br/>stuff if our tip-jar goes high enough."+
"<br/>Click 'Donate' to see the fundraising page."+
"<br/><a href=\"http//jackgames.commonshostage.com/\">http//jackgames.commonshostage.com/</a>"+
"</font>";


/******************************************************
* What do we tell the user at the end?
*/
function getMessageFromScore(){
    if(_root.piratesHappy<1){
        return "I just failed to impress any pirates in Handsome Jack's xmas game!  Can you do better?";
    }else if(_root.piratesHappy<8){
        return "Woo!, I kept "+_root.piratesHappy+"/"+length(pirates)+" pirates happy in Handsome Jack's xmas game.  Can you do better?";
    }else{
        return "Woo! I rock! I impressed ALL the pirates in Handsome Jack's xmas game. Try and beat me!";
    }
}




/**********************************************
* Add a physics object to the world.
*/
function addObject(name,faceDir,x,y,z,dx,dy,dz,t,moveFunction,scale,collision){
    var obj =_root.attachMovie(name,"object"+newLayer,newLayer);
    objects[numobjects++] = obj;
    obj.name=name+newLayer;
    obj.layer=newLayer++;
    obj.x=x;
    obj.y=y;
    obj.z=z;
    obj.faceDirection=faceDir;
    obj.dx=dx;
    obj.dy=dy;
    obj.dz=dz;
    obj._xscale=scale;
    obj._yscale=scale;
    obj.timeLeft=t;
    obj.moveFunction=moveFunction;
    obj.collision=collision;
    return obj;
}

/**********************************************
* Remove object from the stack
*/
function removeObject(n){
    objects[n].removeMovieClip();
    for(;n<numobjects-1;n++){
      objects[n]=objects[n+1];
    }
    numobjects--;
}


/*********************************************
* Set up the pirate
*/
function setupPirate(self){
    self.setup=true;
    self.thirst=int(Math.random()*300);
    self.drinking=0;
    if(self.drinkLeft!=null){
        self.drinkLeft=3;
    }else{
        //First time, randomly full.
        self.drinkLeft=int(Math.random()*3);
    }
    self.throwBottle=0;
    self.hasBottle=true;
    self.anger=0;
    self.clapping=0;
    self.happiness=0;
    self.piratePause=0;
}



/**********************************************
* We build maps using this fake pirate move routine
*/
function newPirate(self){
  if(Key.isDown(65)){  //A
    self.x-=0.01;
  }
  if(Key.isDown(68)){  //D
    self.x+=0.01;
  }
  if(Key.isDown(87)){   //W
    self.y+=0.01;
  }
  if(Key.isDown(83)){  //S
    self.y-=0.01;
  }
  if(Key.isDown(69)){  //E
    self.moveFunction = movePirate;
    setupPirate(self);
    _root.canAdd = true;
  }
  if(Key.isDown(81)){  //Q
    self.faceDirection+=1;
    if(self.faceDirection>3){self.faceDirection=0;}
  }
  self.gotoAndStop(50*self.faceDirection+1);
}



/**********************************************
* Pirate AI
*/
function movePirate(self){
    score+=self.happiness;


    if(self.piratePause>0){
        self.piratePause--;
        return;
    }
    
    if(self.hasBottle){
        if((self.thirst--==0)&&(!gameEnded)){
            self.thirst=200+int(Math.random()*1000);
            self.drinking=1;
        }
        if(self.throwBottle>0){
            if(self.throwBottle<7){
                self.gotoAndStop(self.faceDirection*50+11+(self.throwBottle))
            }else if(self.throwBottle<13){
                self.gotoAndStop(self.faceDirection*50+7-(self.throwBottle-7));
                if(self.throwBottle==7){
                    self.hasBottle=false;
                    var b = throwBottle(self,Math.random()*0.01,Math.random()*0.01,0,0,0,0);
                    b.empty=true;
                }
            }else{
                self.throwBottle=-1;
            }
            self.throwBottle++;
        }else if(self.clapping>0){
            if(self.clapping<6){
                //lifting hands up
                self.gotoAndStop(self.faceDirection*50+18+self.clapping)
            }else if(self.clapping<40){
                if(self.clapping==6){
                    claps.start();
                }
                var f = self.clapping%6;
                if(f<3){
                    self.gotoAndStop(self.faceDirection*50+25+f)
                }else{
                    self.gotoAndStop(self.faceDirection*50+25+3-f)
                }
            }else if(self.clapping<48){
                self.gotoAndStop(self.faceDirection*50+27-(self.clapping-40))
                if(gameEnded){
                    self.clapping=5;
                }
            }else{
                self.clapping=-1;
            }
            self.clapping++
        }else if(self.drinking>0){
          if(self.drinking<10){
              self.gotoAndStop(self.faceDirection*50+7+int(self.drinking/2))
          }else if(self.drinking<20){
              self.gotoAndStop(self.faceDirection*50+11)
          }else if(self.drinking<30){
              self.gotoAndStop(self.faceDirection*50+11-(int((self.drinking-20)/2)))
          }else{
              if(self.drinkLeft--<=0){
                  self.throwBottle=1;
              }else{
                  //Sometimes the booze makes 'em very happy
                  if(Math.random()<0.2){
                      self.clapping=1;
                  }
              }
              self.drinking=-1;
              self.gotoAndStop(self.faceDirection*50+7);
          }
          self.drinking++;
        }else{
            self.gotoAndStop(self.faceDirection*50+7);
        }
        
        
    }else{
        //No Booze!
        if(self.anger++>200){
            self.happiness-=20;
            self.gotoAndStop(self.faceDirection*50+int((self.anger%12)/2));
            if(self.anger%12==0){
                bashDesk.start();
            }
        }else{
            self.gotoAndStop(self.faceDirection*50+2);
        }
    }
    self.happiness+=1;
    
}


/*********************************************
* Throw a bottle
*/
function throwBottle(from,dx,dy,dz,offsetx,offsety,offsetz){
    var b=addObject("Bottle",0,from.x+offsetx,from.y+offsety,from.z+offsetz,from.dx*3+dx,from.dy*3+dy,0.1+dz,30,moveBottle,20,false)
    b.bounced=0;
    b.empty=false;
    return b;   
}


/******************************************
* Move an object under gravity
*/
function moveBottle(self){
    self._rotation+=10;
    self.dz-=0.01;
    if(self.dz<-0.4){self.dz=-0.4;}
    
    //Bottles feed hungary pirates! If they're low enough.
    if(self.z<0.2){
        if(self.empty==false){
            for(var n=0;n<numobjects;n++){
                var obj=objects[n];
                if(obj.hasBottle==false){
                    if(objectNear(obj,self.x,self.y)){
                        obj.hasBottle=true;
                        obj.thirst=int(Math.random()*300);
                        obj.drinking=0;
                        self.anger=0;
                        obj.drinkLeft=3;
                        obj.throwBottle=0;
                        self.time=1;
                    }
                }
            }
        }
    }
    
    //Bottle bounce, and smash!
    if(self.z+self.dz<0){
        self.bounced++;
        if(self.bounced>2){
            //Destory this bottle!
            self.time=1;
            bottleShatter.start();
        }else{
            bottleBounce.start();
            self.dz=-self.dz/2;
        }
    }
}


/*********************************************
* Function to end the game. Called when the
* clip finishes I guess. For now we cheat with
* just presing "END"
*/
function endGame(){
    _root.piratesHappy=0;
    for(var n=0;n<length(pirates);n++){
       var pirate = pirates[n];
       if(pirate.happiness>0){
           _root.piratesHappy++;
           pirate.piratePause=Math.random()*40;
           if(pirate.clapping<=0){
               pirate.clapping=1;
           }
       }
    }
    if(_root.piratesHappy<1){
        userMessage("<b>Oh No!</b><br/><br/>You failed to impress any pirates.<br/>All of them hate Santa's new video.");
    }else if(_root.piratesHappy<8){
        userMessage("<b>Well done!</b><br/><br/>You kept "+_root.piratesHappy+" pirates happy.<br/>They love santa's movie!");
    }else{
        userMessage("<b>Excellent!</b><br/><br/>You impressed ALL the pirates.<br/>Santa's movie is a hit!");
    }
    this.fb._visible=true;
    this.tb._visible=true;
    this.db._visible=true;
    trace("Loader "+this.fb+" send ShowButtons");
    _root.replayButton._visible=true;
    gameEnded=1;
}


/*************************************************
* Set the functions for the link buttons
*/
function setButtons(f,t,d){
  trace("Setting Button Functions "+f);
  this.tb = t;
  this.fb = f;
  this.db = d;
  if(gameEnded==false){
    t._visible=false;
    f._visible=false;
    d._visible=false;
  } 
  
  t.onRelease = function(){
    var mess = getMessageFromScore();
    var url="http://twitter.com/intent/tweet?text="+escape(mess+" - http://handsomejacks.co.uk/index.php/xmas-game");
    trace("Fetched "+url);
    getURL(url);
    _parent._parent._parent.getURL(url);
    _parent._parent.getURL(url);
    _parent.getURL(url);
    getURL(url);
    _root.getURL(url);
    _root._parent.getURL(url);
  }

  d.onRelease = function(){
    var url="http://jackgames.commonshostage.com/";
    trace("Fetched "+url);
    getURL(url);
    d._parent.getURL(url);
  }

  f.onRelease = function(){
    var mess = getMessageFromScore();
    var url="http://www.facebook.com/share.php?u=http://handsomejacks.co.uk/index.php/xmas-game";
    trace("Fetched "+url);
    f._parent.getURL(url);
  }
}


/**********************************************
* Player Movement
*/
function moveSanta(self){
    if(Key.isDown(Key.END)){
        endGame();
    }
    if(Key.isDown(Key.INSERT)){
      if(_root.canAdd){
        _root.canAdd=false; //No more till that one's set.
        pirates[np] = addObject("pirateAtSeat",1,0.6,0.6,0,0,0,0,-1,newPirate,50,true);
        np++;
      }
    }
    if(Key.isDown(Key.HOME)){
      for(var n=0;n<np;n++){
         var pirate = pirates[n];
        trace('pirates[np] = addObject("PirateAtSeat",'+pirate.faceDirection+','+Math.round(pirate.x*100)/100+','+Math.round(pirate.y*100)/100+',0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);');
        trace("...");
        trace("...");
        trace("...");
      }
    }
    //Move santa in the X dimention
    if (Key.isDown(Key.RIGHT)){
      self.dx+=acceleration;
      if(self.dx>maxspeed){self.dx=maxspeed;}
    }else if (Key.isDown(Key.LEFT)){
      self.dx-=acceleration;
      if(self.dx<-maxspeed){self.dx=-maxspeed;}
    }else{
        self.dx*=deceleration;
    }
    
    //Move santa in the Y dimention
    if (Key.isDown(Key.UP)){
      self.dy+=acceleration;
      if(self.dy>maxspeed){self.dy=maxspeed;}
    }else if (Key.isDown(Key.DOWN)){
      self.dy-=acceleration;
      if(self.dy<-maxspeed){self.dy=-maxspeed;}
    }else{
        self.dy*=deceleration;
    }
    
    //Throw a bottle?
    if(Key.isDown(Key.SPACE)){
        if(!throwPressed){
            throwPressed=true;
            throwFrame=0
        }
    }else{
        throwPressed=false;
    }
    
    //Pick which animation frame to show.
    var absx=Math.abs(self.dx);
    var absy=Math.abs(self.dy);
    if(absx>absy){
        //Left/Right - but which?
        if(self.dx<-0.001){
            self.faceDirection = 1;  //left
        }else if(self.dx>0.001){
            self.faceDirection = 3;  //right
        }
    }else{
        //Up/Down - but which?
        if(self.dy<-0.001){
            self.faceDirection = 0;  //down
        }else if(self.dy>0.001){
            self.faceDirection = 2;  //up
        }
    }
    
    if(throwFrame>=0){
        //Throwing a bottle.
        if((absx+absy)>0.001){
            //Walk-throw
            self.gotoAndPlay(self.faceDirection*50+throwFrames[throwFrame++]+7);
        }else{
            //Stand-throw
            self.gotoAndPlay(self.faceDirection*50+throwFrames[throwFrame++]);
        }
        if(throwFrame>=throwFrames.length){
            throwFrame=-1;
        }
        if(throwFrame==int(throwFrames.length/2)+2){
            //Thow the bottle. Santa's hand is in a different
            //position each facedirect. Sigh.
            var offsetX=0;
            var offsetY=0;
            var offsetZ=0;
            switch(self.faceDirection){
                case 1:
                    offsetY+=0.01;
                    break;
                case 2:
                    offsetX+=0.07;
                    offsetY+=0.01;
                    break;
                case 3:
                    offsetX=+0.01;
                    offsetY-=0.01;
                    break;
                default:
                    offsetX=0.00;
                    offsetY=-0.055;
            }
            throwBottle(self,0,0,0,offsetX,offsetY,offsetZ);
        }
    }else{
        //Walking/standing then
        if((absx+absy)>0.001){
            walkAnimFrame++;
            if(walkAnimFrame>walkAnimFrames.length){
                walkAnimFrame=0;
            }
            self.gotoAndStop(self.faceDirection*50+walkAnimFrames[walkAnimFrame]);
        }else{
            walkAnimFrame=0;
            self.gotoAndStop(self.faceDirection*50+1);
        }
    }

}


/*************************************************
* Sort the layers by depth. We use a simple bubble
* sort coz flash's swapdepth needs us to use a sort
* that mostly swaps, and we'll usually be pretty
* ordered already.
*/
function sortLayersByDepth(objects){
    for(var n=0;n<numobjects;n++){
        var obj=objects[n];
        obj.depth = -(obj.x+100*obj.y);
    }
    var swapped=true;
    while(swapped){
        swapped=false;
        for(var n=0;n<numobjects-1;n++){
            if(objects[n].depth>objects[n+1].depth){
                objects[n].swapDepths(objects[n+1].layer);
                var t = objects[n].layer;
                objects[n].layer=objects[n+1].layer
                objects[n+1].layer=t;
                t = objects[n];
                objects[n]=objects[n+1];
                objects[n+1]=t;
                swapped=true;
            }
        }
    }

}





/********************************************
* Move the first object so it's just touching
* the edge of the second object. Which is what
* happens when you collide with it of course.
*/
function moveToEdge(mover,edge){
    var newX = (mover.x+mover.dx)
    var newY = (mover.y+mover.dy)
    var dx = newX-edge.x;
    var dy = newY-edge.y;
    var l = Math.sqrt(dx*dx+dy*dy);
    var sinalpha = Math.abs(dy)/l;
    var alpha = Math.asin(sinalpha);
    var nx = Math.cos(alpha)*collisionDiameter;
    var ny = Math.sin(alpha)*collisionDiameter;
    if(dx<0){
        mover.x=edge.x-nx;
    }else{
        mover.x=edge.x+nx;
    }
    if(dy<0){
        mover.y=edge.y-ny;
    }else{
        mover.y=edge.y+ny;
    }
}



/************************************************
* Object Near - is this object near a given point
* to the point that it's touching it?
*/
function objectNear(obj,x,y){
    var dx=obj.x-x;
    var dy=obj.y-y;
    dist = Math.sqrt(dx*dx+dy*dy);
    if(dist<collisionDiameter){
        return true;
    }
    return false;   
}


/**********************************************
* Collision Detection. Does this object's movement
* put it in the same area as some other object
*/
function collides(o){
    var newX = o.x+o.dx;
    var newY = o.y+o.dy;
    for(var n=0;n<numobjects;n++){
        var obj = objects[n];
        if(obj==o){continue;}
        if(obj.collision){
            if(objectNear(obj,newX,newY)){
                return obj;
            }
        }
    }
    return false;
}



/*********************************************
* Set up
*/
function setup(){
  _root.replayButton.swapDepths(20000);

  for(var n=0;n<numobjects;n++){
    objects[n].removeMovieClip();
  }
  numobjects=0;
  userMessage("");
  this.fb._visible=false;
  this.tb._visible=false;
  this.db._visible=false;
  this.replayButton._visible=false;
  gameEnded=false;
  objects = new Array();
  numobjects=0;
  newLayer=100;

  santa = addObject("Santa",0,0,1,0,0,0,0,-1,moveSanta,santaScale,true);
  santa._yscale=30;
  santa.loadFrames();
  pirates = new Array();
  //Our lovely 'level editor' means we can hit HOME to print where the pirates are as a trace()
  //then paste it in here. Add pirates with 'insert' when that's not commented out. Move 
  //'em with ASDW and Q to turn, E to fix in place.
pirates[np] = addObject("PirateAtSeat",0,0.39,0.25,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",0,0.49,0.22,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",3,0.01,0.81,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",3,0.03,0.72,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",1,0.47,0.76,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",1,0.4,0.77,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",0,0.44,0.68,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",0,0.53,0.66,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",3,0.36,0.52,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",2,0.47,0.47,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",2,0.56,0.71,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);
pirates[np] = addObject("PirateAtSeat",1,0.14,0.88,0,0,0,0,-1,movePirate,50,true); setupPirate(pirates[np++]);


  //Restarting the clip crashes out if it's not loaded yet/
  if(startedAlready){
    _root.videoClip.play();
  }else{
      startedAlready=true;
  }
}
setup();


/*********************************************
* Each Frame
*/
_root.onEnterFrame = function(){
    
    if(userMessagePause>0){
        userMessagePause--;
    }else{
        _root.userMessageText._y--;
        _root.userMessageShadow._y--;
    }
    
    for(var n=0;n<numobjects;n++){
        var obj = objects[n];
        if(--obj.time==0){
            removeObject(n);
        }
    }
    if(!gameEnded){
        score=0;
    }
    //Move The objects
    for(var n=0;n<numobjects;n++){
        var obj = objects[n];
        if(obj.moveFunction!=null){
            obj.moveFunction(objects[n]);
        }
        if((obj.dx!=0)||(obj.dy!=0)){
            var o;
            if((obj.collision)&&(o=collides(obj))){
                moveToEdge(obj,o);
            }else{
                obj.x+=obj.dx;
                obj.y+=obj.dy;
            }
            if(obj.x<0){obj.x=0;}   if(obj.x>1){obj.x=1;}
            if(obj.y<0){obj.y=0;}   if(obj.y>1){obj.y=1;}
        }
        obj.z+=obj.dz;
        if(obj.z<0){obj.z=0;}   if(obj.z>1){obj.z=1;}
    }

    //We totted up the score during the movement...
    if(!gameEnded){
        score = "<font size=\"25\">Score: "+score+"</font>";
        _root.userScore.htmlText=score;
        _root.userScoreShadow.htmlText=score;
    }



    //Display the physics objects, their x,y and z should be between
    //zero and one, they represent how far along that axis we are,
    //so a simple interpolation should suffice. Maybe.
    for(var n=0;n<numobjects;n++){
        var obj=objects[n];
        obj._x = bottomLeftX + obj.y*leftLinedx + obj.x*bottomLinedx;
        obj._y = bottomLeftY + obj.y*leftLinedy + obj.x*bottomLinedy - obj._height/4 - obj.z*500;
    }
    
    sortLayersByDepth(objects);

}
