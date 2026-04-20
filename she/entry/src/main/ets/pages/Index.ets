// SnakeGame.ets
@Entry
@Component
struct SnakeGame {
  // 游戏配置
  private readonly GRID_SIZE: number = 20;
  private readonly GRID_COLS: number = 20;
  private readonly GRID_ROWS: number = 20;
  private readonly MOVE_INTERVAL: number = 200;

  @State snake: Array<[number, number]> = [[10, 10], [9, 10], [8, 10]];
  @State food: [number, number] = [15, 10];
  @State snakeDirection: string = 'RIGHT';
  @State nextSnakeDirection: string = 'RIGHT';
  @State score: number = 0;
  @State gameOver: boolean = false;

  // 正确初始化 Canvas 上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private gameTimer: number = -1;

  private readonly directions: Map<string, [number, number]> = new Map([
    ['UP', [0, -1]],
    ['DOWN', [0, 1]],
    ['LEFT', [-1, 0]],
    ['RIGHT', [1, 0]]
  ]);
  private readonly oppositeDir: Map<string, string> = new Map([
    ['UP', 'DOWN'],
    ['DOWN', 'UP'],
    ['LEFT', 'RIGHT'],
    ['RIGHT', 'LEFT']
  ]);

  aboutToAppear(): void {
    this.initGame();
  }

  initGame(): void {
    this.snake = [[10, 10], [9, 10], [8, 10]];
    this.snakeDirection = 'RIGHT';
    this.nextSnakeDirection = 'RIGHT';
    this.score = 0;
    this.gameOver = false;
    this.generateFood();
    this.startGameLoop();
  }

  generateFood(): void {
    const maxAttempts = 1000;
    for (let i = 0; i < maxAttempts; i++) {
      const x = Math.floor(Math.random() * this.GRID_COLS);
      const y = Math.floor(Math.random() * this.GRID_ROWS);
      if (!this.snake.some(segment => segment[0] === x && segment[1] === y)) {
        this.food = [x, y];
        return;
      }
    }
    for (let y = 0; y < this.GRID_ROWS; y++) {
      for (let x = 0; x < this.GRID_COLS; x++) {
        if (!this.snake.some(segment => segment[0] === x && segment[1] === y)) {
          this.food = [x, y];
          return;
        }
      }
    }
    this.gameOver = true;
  }

  startGameLoop(): void {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer);
    }
    this.gameTimer = setInterval(() => {
      if (!this.gameOver) {
        this.moveSnake();
        this.drawCanvas();
      }
    }, this.MOVE_INTERVAL);
  }

  moveSnake(): void {
    if (this.nextSnakeDirection && this.oppositeDir.get(this.nextSnakeDirection) !== this.snakeDirection) {
      this.snakeDirection = this.nextSnakeDirection;
    }

    const delta = this.directions.get(this.snakeDirection);
    if (!delta) return;

    const head = this.snake[0];
    const newHead: [number, number] = [head[0] + delta[0], head[1] + delta[1]];

    const isEating = (newHead[0] === this.food[0] && newHead[1] === this.food[1]);

    let newSnake = [newHead, ...this.snake];
    if (!isEating) {
      newSnake.pop();
    }

    if (this.checkCollision(newSnake)) {
      this.gameOver = true;
      clearInterval(this.gameTimer);
      this.gameTimer = -1;
      this.drawCanvas();
      return;
    }

    this.snake = newSnake;

    if (isEating) {
      this.score++;
      this.generateFood();
    }

    this.drawCanvas();
  }

  checkCollision(snake: Array<[number, number]>): boolean {
    const head = snake[0];
    if (head[0] < 0 || head[0] >= this.GRID_COLS || head[1] < 0 || head[1] >= this.GRID_ROWS) {
      return true;
    }
    for (let i = 1; i < snake.length; i++) {
      if (snake[i][0] === head[0] && snake[i][1] === head[1]) {
        return true;
      }
    }
    return false;
  }

  drawCanvas(): void {
    const ctx = this.canvasContext;
    const width = this.GRID_COLS * this.GRID_SIZE;
    const height = this.GRID_ROWS * this.GRID_SIZE;

    ctx.clearRect(0, 0, width, height);

    // 网格线
    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= this.GRID_COLS; i++) {
      ctx.beginPath();
      ctx.moveTo(i * this.GRID_SIZE, 0);
      ctx.lineTo(i * this.GRID_SIZE, height);
      ctx.stroke();
    }
    for (let i = 0; i <= this.GRID_ROWS; i++) {
      ctx.beginPath();
      ctx.moveTo(0, i * this.GRID_SIZE);
      ctx.lineTo(width, i * this.GRID_SIZE);
      ctx.stroke();
    }

    // 食物
    ctx.fillStyle = '#FF4444';
    ctx.beginPath();
    ctx.arc(
      this.food[0] * this.GRID_SIZE + this.GRID_SIZE / 2,
      this.food[1] * this.GRID_SIZE + this.GRID_SIZE / 2,
      this.GRID_SIZE / 2 - 2,
      0,
      2 * Math.PI
    );
    ctx.fill();

    // 蛇身
    for (let i = 0; i < this.snake.length; i++) {
      const x = this.snake[i][0];
      const y = this.snake[i][1];
      ctx.fillStyle = i === 0 ? '#66BB6A' : '#4CAF50';
      ctx.fillRect(
        x * this.GRID_SIZE + 1,
        y * this.GRID_SIZE + 1,
        this.GRID_SIZE - 2,
        this.GRID_SIZE - 2
      );
    }

    // 游戏结束遮罩
    if (this.gameOver) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
      ctx.fillRect(0, 0, width, height);
      ctx.font = 'bold 24px sans-serif';
      ctx.fillStyle = '#FFFFFF';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('游戏结束', width / 2, height / 2 - 20);
      ctx.font = '18px sans-serif';
      ctx.fillText(`得分: ${this.score}`, width / 2, height / 2 + 20);
    }
  }

  changeDirection(newDir: string): void {
    if (this.gameOver) return;
    if (this.oppositeDir.get(newDir) !== this.snakeDirection) {
      this.nextSnakeDirection = newDir;
    }
  }

  restartGame(): void {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer);
      this.gameTimer = -1;
    }
    this.initGame();
    this.drawCanvas(); // 立即重绘
  }

  handleSwipe(event: GestureEvent): void {
    if (this.gameOver) return;
    const angle = event.angle;
    if (angle >= 45 && angle < 135) {
      this.changeDirection('UP');
    } else if (angle >= 135 && angle < 225) {
      this.changeDirection('LEFT');
    } else if (angle >= 225 && angle < 315) {
      this.changeDirection('DOWN');
    } else {
      this.changeDirection('RIGHT');
    }
  }

  build() {
    Column() {
      Row() {
        Text('贪吃蛇')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        Text(`得分: ${this.score}`)
          .fontSize(20)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 使用已初始化的 canvasContext 直接绑定
      Canvas(this.canvasContext)
        .width(this.GRID_COLS * this.GRID_SIZE)
        .height(this.GRID_ROWS * this.GRID_SIZE)
        .backgroundColor('#F5F5F5')
        .onReady(() => {
          // 确保画布准备好后绘制一次
          this.drawCanvas();
        })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            PanGesture({ direction: PanDirection.All, distance: 5 })
              .onActionEnd((event: GestureEvent) => {
                this.handleSwipe(event);
              })
          )
        )

      Column() {
        Row() {
          Button('↑')
            .width(80)
            .height(60)
            .fontSize(28)
            .onClick(() => this.changeDirection('UP'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row({ space: 20 }) {
          Button('←')
            .width(80)
            .height(60)
            .fontSize(28)
            .onClick(() => this.changeDirection('LEFT'))
          Button('↓')
            .width(80)
            .height(60)
            .fontSize(28)
            .onClick(() => this.changeDirection('DOWN'))
          Button('→')
            .width(80)
            .height(60)
            .fontSize(28)
            .onClick(() => this.changeDirection('RIGHT'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })
      }
      .margin({ top: 20 })

      Button('重新开始')
        .width(160)
        .height(48)
        .fontSize(18)
        .margin({ top: 20, bottom: 20 })
        .onClick(() => this.restartGame())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}