//started July 7th, 2016
//last updated July 9th, 2016
//By Geekman9097

//Magic Numbers
int magSize = 20; //Number of rounds in a mag
int playerHealthMax = 100; //Maximum player health
int playerSize = 10; //Size of player character dot
int playerGunDamage = 25; //Damage dealt by player's gun
int playerBowDamage = 50; // Damage dealt by player's bow
int playerMeleeDamage = 70; //  Damage dealt by player's melee
int gunshotsPerMinute = 120; //ROF of player's gun in RPM
int arrowsPerMinute = 40; //ROF of player's bow in APM
int swingsPerMinute = 70; //How many times the player can hit with melee in one minute
int playerSpeed = 4; //Movement speed of player in pixels per frame
int playerReloadTime = 60; //Time it takes the player to reload one bullet in milliseconds
int playerMagSwapTime = 250; //Amount of time the player can't fire or move while swapping mags
int enemySize = 15; //Size of enemy character dots
int enemyDamage = 1; //Damage dealt by enemy attacks in damage per attack
int enemyAttackRate = 60; //how often an enemy attacks in attacks per minute
int enemyHealthMax = 50; //Health of each enemy
int enemySpeed = 6; //Enemy movement speed in pixels per frame
int enemySpawnRate = 5000; //Spawn rate of enemies in milliseconds between spawns
int projectileGunSpeed = 15; //Bullet speed in pixels per frame
int projectileBowSpeed = 10; //Arrow speed in pixels per frame
int projectileMeleeSpeed = 0; //Because the melee weapon will spawn 0 travel projectiles for 1 frame
int gunDrawLength = 25; //Size of the gun in pixels
int bowDrawLength = 20; //Size of the bow in pixels
int meleeDrawLength = 30; //Size of the melee in pixels
int gunFireRange = 900; //distance the gun's bullets can go in pixels
int bowFireRange = 500; // distance the bow's arrows can go in pixels
int meleeRange = 0; // again, because backend the melee spawns projectiles
int projectileSize = 1; //Size of the projectiles in pixels
int killScoreGain = 5;
color gunColor = color(66, 74, 80);
color bowColor = color(204, 110, 0);
color meleeColor = color(216, 171, 146);
PFont arialFont;

//data values
int enemySpawnX, enemySpawnY;
int magGunHolding = magSize;
int dumpPouchHeld = 100;
int enemyLastSpawn = 0;
int playerCurrentScore;
int weaponLastUsed;
int timeToReload;
int lastMagSwap;
int lastMagRefill;
String inabilityType = null;
String healthDisplay;
String scoreDisplay;
String ammoDisplay;
boolean playerAble;

//clasess that need Creating
Player playerCharacter;
Weapon gun;
Weapon bow;
Weapon melee;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Magazine> magazines = new ArrayList<Magazine>();
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<AmmoDrop> ammoDrops = new ArrayList<AmmoDrop>();
ArrayList<Obstacle> walls = new ArrayList<Obstacle>();

void setup() {
  frameRate(30); //set the framerate to a little bit slower
  //size(500, 500); //set the playing field size
  fullScreen(); //make the playing field the entire screen
  println(width + ":" + height);
  //translate(width/2, height/2);
  playerCharacter = new Player(width/2, height/2, playerHealthMax); // spawn the player
  gun = new Weapon(gunDrawLength, playerGunDamage, projectileGunSpeed, gunshotsPerMinute, gunFireRange, gunColor);
  //bow = new Weapon(bowDrawLength, playerBowDamage, projectileBowSpeed, arrowsPerMinute, bowFireRange, bowColor);
  //melee = new Weapon(meleeDrawLength, playerMeleeDamage, projectileMeleeSpeed, swingsPerMinute, meleeRange, meleeColor);
  magazines.add(new Magazine(magSize, int(random(0,21))));
  arialFont = createFont("Arial", 16, true); //creating an arial font, 16 pt, with antialiaising
  textFont(arialFont); // declare the font
  fill(0); //set the fill to black
  //text("Hello",250,250); //a bit of debugging code
  textAlign(LEFT); // make sure text is set to align left
  cursor(CROSS);
  ellipseMode(RADIUS); // set everything to use radii
  //pushMatrix();
}

void draw() {
  background(255); //reset the background to white
  checkHealths();
  handleAbilities();
  moveEntities();
  drawEntities();
  handleInputs();
  if (millis() >= enemyLastSpawn + enemySpawnRate) { //spawn an enemy at a set interval
    spawnEnemy();
  } 
  updateHUD();
  doCollisions();
}

void handleInputs() {
  if (mousePressed) {
    gun.useWeapon();
    //bow.useWeapon();
    //melee.useWeapon();
  }
  if (keyPressed && (key == 'r' || key == 'R')) {
    lastMagSwap = millis();
    playerAble = false;
    //if (dumpPouchHeld >= magSize) {
    //  int ammoReloaded = magSize - magGunHolding;
    //  magGunHolding = magSize;
    //  dumpPouchHeld = dumpPouchHeld - ammoReloaded;
    //} else if (dumpPouchHeld > 0) {
    //  magGunHolding = dumpPouchHeld;
    //  dumpPouchHeld = 0;
    //} else {
    //  playerAble = true;
    //}
    magazines.add(new Magazine(magSize,magGunHolding));
    magGunHolding = magazines.get(0).getHolding();
    magazines.remove(magazines.get(0));
    inabilityType = "SWAP";
  }
  if (keyPressed && (key == 'q' || key == 'Q')) {
    
    for (Magazine thisMagazine : magazines) {
      thisMagazine.reload();
      playerAble = false;
    }
  }
}

void spawnEnemy() { //spawn an enemy at a random location on the screen
  enemies.add(new Enemy(int(random(width)), int(random(height)), enemyHealthMax));
  enemyLastSpawn = millis();
}

void handleAbilities() {
  if (millis() >= lastMagSwap + playerMagSwapTime && inabilityType == "SWAP") {
    playerAble = true;
  }
  if (millis() >= lastMagRefill + timeToReload && inabilityType == "REFILL") {
    playerAble = true;
  }
  inabilityType = null;
}

void moveEntities() { //move the entities to where they need to be
  for (Enemy thisEnemy : enemies) {
    thisEnemy.move();
  }
  for (Projectile thisProjectile : projectiles) {
    thisProjectile.move();
  }
  playerCharacter.move();
}

void drawEntities() { //draw the entities where they are
  for (Enemy thisEnemy : enemies) {
    thisEnemy.drawEnemy();
  }
  for (Projectile thisProjectile : projectiles) {
    thisProjectile.drawProjectile();
  }
  playerCharacter.drawPlayer();
  gun.drawWeapon();
  //bow.drawWeapon();
  //melee.drawWeapon();
}


void updateHUD() { //draw the HUD to reflect possible new Values
  healthDisplay = "Health - " + str(playerCharacter.getHealth());
  text(healthDisplay, 10, 20);
  scoreDisplay = "Score - " + str(playerCurrentScore);
  text(scoreDisplay, 10, 40);
  ammoDisplay = "Ammo  - " + str(magGunHolding) + "/" + str(dumpPouchHeld);
  text(ammoDisplay, 10, 60);
}

void doCollisions() { // lets see if stuff is touching
  ArrayList<Projectile> collided = new ArrayList<Projectile>();
  for (Projectile thisProjectile : projectiles) { //let's do the Projectiles
    for (Enemy thisEnemy : enemies) { //against the enemies
      float collideDistance = enemySize + projectileSize;
      if (dist(thisProjectile.getX(), thisProjectile.getY(), thisEnemy.getX(), thisEnemy.getY()) <= collideDistance) {
        collided.add(thisProjectile);
        thisEnemy.doDamage(thisProjectile.getDamage());
        //println("Enemy Hit");
      }
    }
  }
  for (Projectile thisCollidedProjectile : collided) { //delete the projectiles that we marked as having hit something
    projectiles.remove(thisCollidedProjectile);
  }
  for (Enemy thisEnemy : enemies) {
    float collideDistance = enemySize + playerSize;
    if (dist(thisEnemy.getX(), thisEnemy.getY(), playerCharacter.getX(), playerCharacter.getY()) <= collideDistance && thisEnemy.canAttack()) {
      playerCharacter.doDamage(enemyDamage);
    }
  }
}

void checkHealths() {
  ArrayList<Enemy> deadEnemies = new ArrayList<Enemy>();
  for (Enemy thisEnemy : enemies) {
    if (thisEnemy.getHealth() <= 0) {
      deadEnemies.add(thisEnemy);
    }
  }
  for (Enemy thisDeadEnemy : deadEnemies) {
    enemies.remove(thisDeadEnemy);
    playerCurrentScore = playerCurrentScore + killScoreGain;
  }
  ArrayList<Projectile> expiredProjectiles = new ArrayList<Projectile>();
  for (Projectile thisProjectile : projectiles) {
    if (thisProjectile.getExpired()) {
      expiredProjectiles.add(thisProjectile);
      //println("projectile too old, Removing");
    }
  }
  for (Projectile thisExpiredProjectile : expiredProjectiles) {
    projectiles.remove(thisExpiredProjectile);
  }
  if (playerCharacter.getHealth() <= 0) {
    gameLost();
  }
}

void gameLost() {
  noLoop();
  background(255);
  text("GAME OVER", width/2, height/2);
  text("Score - " + str(playerCurrentScore), width/2, (height/2)+16);
}

class Enemy {
  float x, y, direction;
  int health;
  int lastAttack = 0;
  Enemy(int xPos, int yPos, int startHealth) {
    x = xPos;
    y = yPos;
    health = startHealth;
  }
  void move() {
    if(dist(x,y,playerCharacter.getX(),playerCharacter.getY()) >= playerSize + enemySize) {
      direction = atan2(playerCharacter.getY()-y, playerCharacter.getX()-x);
      //direction = atan2(height/2-y,width/2-y);
      //direction = atan2(-y,-x);
      x = x + cos(direction) * enemySpeed;
      y = y + sin(direction) * enemySpeed;
    }
  }

  void drawEnemy() {
    fill(255, 0, 0);
    ellipse(x, y, enemySize, enemySize);
    fill(0);
  }

  void doDamage(int damage) {
    health = health - damage;
  }

  float getX() {
    return x;
  }

  float getY() {
    return y;
  }

  int getHealth() {
    return health;
  }

  boolean canAttack() {
    if (millis() >= lastAttack + 60000/enemyAttackRate) {
      return true;
    } else {
      return false;
    }
  }
}

class Player {
  int x, y, health;
  Player(int xPos, int yPos, int startHealth) {
    x = xPos;
    y = yPos;
    health = startHealth;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }

  int getHealth() {
    return health;
  }
  
  void doDamage(int damage) {
    health = health - damage;
  }

  void move() { // let's move the player around with key input
    if(playerAble){
      if (keyPressed && ( key == 'w' || key == 'W')) { //up
        //translate(0, -playerSpeed);
        y = y - playerSpeed;
      } else if (keyPressed && ( key == 'a' || key == 'A')) { //left
        //translate(playerSpeed, 0);
        x = x - playerSpeed;
      } else if (keyPressed && ( key == 's' || key == 'S')) { //down
        //translate(0, playerSpeed);
        y = y + playerSpeed;
      } else if (keyPressed && ( key == 'd' || key == 'D')) { //right
        //translate(-playerSpeed, 0);
        x = x + playerSpeed;
      }
    }
  }

  void drawPlayer() {
    fill(0, 255, 0);
    ellipse(x, y, playerSize, playerSize);
    fill(0);
  }
}
class Weapon {
  float aimDirection, endX, endY;
  int weaponLength, damage, startX, startY, projectileSpeed, fireRate, range;
  color weaponColor;
  Magazine storedMagazine;
  Weapon(int _length, int _damage, int _projectileSpeed, int _firerate, int _range, color _color) {
    weaponLength = _length;
    damage = _damage;
    projectileSpeed = _projectileSpeed;
    fireRate = _firerate;
    range = _range;
    weaponColor = _color;
    //storedMagazine = new Magazine(magSize);
  }

  void drawWeapon() {
    startX = playerCharacter.getX();
    startY = playerCharacter.getY();
    aimDirection = atan2(mouseY-startY, mouseX-startX);
    endX = startX + cos(aimDirection) * weaponLength;
    endY = startY + sin(aimDirection) * weaponLength;
    stroke(weaponColor);
    line(startX, startY, endX, endY);
    stroke(0);
  }

  void useWeapon() {
    if (magGunHolding > 0 && millis() >= weaponLastUsed + 60000/fireRate) {
      projectiles.add(new Projectile(endX, endY, projectileSpeed, damage, range, aimDirection));
      magGunHolding = magGunHolding - 1;
      weaponLastUsed = millis();
    }
  }
}

class Projectile {
  float x, y, startX, startY, moveDirection;
  int speed, damage, range;
  Projectile(float xPos, float yPos, int _speed, int _damage, int _range, float startDirection) {
    x = startX = xPos;
    y = startY = yPos;
    speed = _speed;
    damage = _damage;
    range = _range;
    moveDirection = startDirection;
  }

  void move() {
    x = x + cos(moveDirection) * speed;
    y = y + sin(moveDirection) * speed;
  }

  int getDamage() {
    return damage;
  }

  float getX() {
    return x;
  }

  float getY() {
    return y;
  }
  
  boolean getExpired() {
    if (dist(x,y,startX,startY) >= range) {
      return true;
    } else {
      return false;
    }
  }

  void drawProjectile() {
      ellipse(x, y, projectileSize, projectileSize);
  }
}

class Magazine {
  int size;
  int storing;
  Magazine(int _size, int _storing) {
    size = _size;
    storing = _storing;
  }

  void reload() {
    for ( int spareAmmo = 0; spareAmmo <= dumpPouchHeld; spareAmmo++) {
      if (storing < size) {
        storing++;
        timeToReload = timeToReload + playerReloadTime;
      } else {
        break;
      }
      dumpPouchHeld = dumpPouchHeld - storing;
    }
  }

  int getHolding() {
    return storing;
  }
}

class Obstacle {
  
}

class HealthKit {
  
}

class AmmoDrop {
  
}