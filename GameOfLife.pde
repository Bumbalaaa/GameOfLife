//Java Processing implementation of Conway's Game of Life
//Created by Ethan Coulthurst
//Rules: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

Button restart; //regenerate cells in case of dead end
Button pause; //pause generation
Button step; //step through 1 generation, only appears if sim is paused

int cellNumber = 25;
int[][] cells;
int area;
boolean playing = true;

void setup() {
  colorMode(HSB, 255);
  size(1200, 800);
  area = height;
  background(255);
  frameRate(10);
  //generate initial random config of cells. Sometimes leads to dead ends quickly, use restart button.
  cells = new int[cellNumber][cellNumber];
  for (int i = 0; i < cellNumber; i++) {
    for (int j = 0; j < cellNumber; j++) {
      cells[i][j] = floor(random(2));
      for (int d = 0; d < 2; d++) {
        if (cells[i][j] != 0) cells[i][j] = floor(random(2));
      }
    }
  }
  
  //menu buttons
  restart = new Button(area + (width - area) / 2 - 50, height / 4 - 25, "Restart", #FF0000);
  pause = new Button(area + (width - area) / 2 - 50, 2 * (height / 4) - 25, "Pause", #00FF00);
  step = new Button(area + (width - area) / 2 - 50, 3 * (height / 4) - 25, "Step", #FF9900);
  step.show = false;
}

void draw() {
  background(100);
  int cellSize = area / cellNumber;
  noFill();
  strokeWeight(2);
  for (int i = 0; i < cellNumber; i++) {
    for (int j = 0; j < cellNumber; j++) {
      if (cells[i][j] != 0) {
        //fill color based on number of neighbors
        fill(map(checkNeighbors(i, j), 0, 8, 0, 255), 255, 255);
      } else noFill();
      rect(i * cellSize, j * cellSize, cellSize, cellSize);
    }
  }
  
  if (playing) { 
    generate(); 
    pause.c = #00FF00;
  } else pause.c = #FF0000; 
  menu();
}

//creates new generation - checks neighbors of all cells and "kills/revives" cells based on GOL parameters (lowerLimit & upperLimit)
//copies array to temp array, calculates, then pushes temp array to real array as to not change neighbor count of cells mid-generation
void generate() {
  int[][] tempCells = cells;
  int lowerLimit = 2;
  int upperLimit = 3;
  for (int i = 0; i < cellNumber; i++) {
    for (int j = 0; j < cellNumber; j++) {

      int neighbors = checkNeighbors(i, j);
      if (cells[i][j] == 0) {
        if (neighbors == upperLimit) tempCells[i][j] = 1;
      } else {
        if (neighbors < lowerLimit || neighbors > upperLimit) tempCells[i][j] = 0;
      }
    }
  }
  cells = tempCells;
}

//check and return number of active neighbor cells (8 surrounding cells)
int checkNeighbors(int i, int j) {
  int neighbors = 0;

  for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
      //ignore out of bounds cell indices
      if ((i == 0 && x == -1) || (i == cellNumber - 1 && x == 1) || (j == 0 && y == -1) || (j == cellNumber - 1 && y == 1)) continue;
      neighbors += cells[i+x][j+y];
    }
  }
  //subtract own cell
  neighbors -= cells[i][j];

  return neighbors;
}

void menu() {
  //button format: update button (update state and show), check button state, button function
  restart.update();
  if (restart.pressed) regenerate();

  pause.update();
  if (pause.pressed) {
    playing = !playing;
    step.show = !step.show;
  }
  
  step.update();
  if (step.pressed) generate();
}

//regen all cells as done in setup()
void regenerate() {
  for (int i = 0; i < cellNumber; i++) {
    for (int j = 0; j < cellNumber; j++) {
      cells[i][j] = floor(random(2));
      for (int d = 0; d < 2; d++) {
        if (cells[i][j] != 0) cells[i][j] = floor(random(2));
      }
    }
  }
}

//button class
class Button {
  public int x;
  public int y;
  public int h = 50;
  public int w = 100;
  public String label;
  public color c;
  boolean pressed;
  boolean show = true;

  public Button(int x, int y, String label, color c) {
    this.x = x;
    this.y = y;
    this.label = label;
    this.c = c;
    pressed = false;
  }

  //show button, check if mouse is pressed and within button bounds
  public void update() {
    if (show) {
      stroke(0);
      strokeWeight(3);
      fill(c);
      rect(x, y, w, h); 
      fill(0);
      textSize(20);
      text(label, x + 17, y + h/2 + 7);

      if (mousePressed && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
        pressed = true;
        println("Button \"" + label + "\" pressed");
      } else pressed = false;
    }
  }
}
