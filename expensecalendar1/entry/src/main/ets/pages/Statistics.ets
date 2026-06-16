import { ExpenseRecord, CategoryColors, CategoryIcons, getAllCategories } from '../model/ExpenseRecord'
import { ExpenseDatabase } from '../model/ExpenseDatabase'
import { DateUtils } from '../common/DateUtils'
import router from '@ohos.router'

// 分类统计数据
interface CategoryStat {
  category: string
  amount: number
  percentage: number
}

@Entry
@Component
struct Statistics {
  private db: ExpenseDatabase = ExpenseDatabase.getInstance()
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private pieCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State currentMonth: string = DateUtils.getCurrentYearMonth()
  @State records: ExpenseRecord[] = []
  @State categoryStats: CategoryStat[] = []
  @State monthTotal: number = 0
  @State chartType: number = 0  // 0: 饼图, 1: 柱状图

  aboutToAppear() {
    // 从路由参数获取月份
    const params = router.getParams() as Record<string, string>
    if (params && params.month) {
      this.currentMonth = params.month
    }
    this.loadData()
  }

  async loadData() {
    this.records = await this.db.queryByMonth(this.currentMonth)
    this.calculateCategoryStats()
  }

  // 计算分类统计
  calculateCategoryStats() {
    const categoryMap: Record<string, number> = {}
    let total = 0

    for (const record of this.records) {
      if (!categoryMap[record.category]) {
        categoryMap[record.category] = 0
      }
      categoryMap[record.category] += record.amount
      total += record.amount
    }

    this.monthTotal = total
    this.categoryStats = []

    const categories = getAllCategories()
    for (const cat of categories) {
      if (categoryMap[cat] && categoryMap[cat] > 0) {
        this.categoryStats.push({
          category: cat,
          amount: categoryMap[cat],
          percentage: total > 0 ? (categoryMap[cat] / total) * 100 : 0
        })
      }
    }

    // 按金额降序排列
    this.categoryStats.sort((a, b) => b.amount - a.amount)
  }

  prevMonth() {
    this.currentMonth = DateUtils.getPrevMonth(this.currentMonth)
    this.loadData()
  }

  nextMonth() {
    this.currentMonth = DateUtils.getNextMonth(this.currentMonth)
    this.loadData()
  }

  // 绘制饼图
  drawPieChart() {
    const ctx = this.pieCtx
    const centerX = 140
    const centerY = 140
    const radius = 110
    let startAngle = -Math.PI / 2

    ctx.clearRect(0, 0, 280, 280)

    for (const stat of this.categoryStats) {
      const sweepAngle = (stat.percentage / 100) * 2 * Math.PI
      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.arc(centerX, centerY, radius, startAngle, startAngle + sweepAngle)
      ctx.closePath()
      ctx.fillStyle = CategoryColors[stat.category] ?? '#C9C9C9'
      ctx.fill()

      // 绘制百分比标签
      if (stat.percentage > 5) {
        const labelAngle = startAngle + sweepAngle / 2
        const labelX = centerX + (radius * 0.65) * Math.cos(labelAngle)
        const labelY = centerY + (radius * 0.65) * Math.sin(labelAngle)
        ctx.fillStyle = '#FFFFFF'
        ctx.font = '12px sans-serif'
        ctx.textAlign = 'center'
        ctx.textBaseline = 'middle'
        ctx.fillText(`${stat.percentage.toFixed(1)}%`, labelX, labelY)
      }

      startAngle += sweepAngle
    }
  }

  // 获取柱状图高度（按比例）
  getBarHeight(amount: number): number {
    if (this.monthTotal === 0) return 0
    const maxAmount = this.categoryStats.length > 0 ? this.categoryStats[0].amount : 1
    return Math.max(10, (amount / maxAmount) * 140)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.back()
          })

        Text('消费统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('    ')
          .fontSize(16)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#007DFF')

      // 月份选择器
      Row() {
        Text('<')
          .fontSize(20)
          .padding(10)
          .onClick(() => this.prevMonth())

        Text(DateUtils.getMonthDisplay(this.currentMonth))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('>')
          .fontSize(20)
          .padding(10)
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 10, bottom: 10 })

      // 当月总支出
      Row() {
        Text('当月总支出')
          .fontSize(16)
          .fontColor('#666666')
        Text(`¥ ${this.monthTotal.toFixed(2)}`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4444')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 15 })

      // 图表类型切换
      Row() {
        Text('饼图')
          .fontSize(15)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor(this.chartType === 0 ? '#007DFF' : '#E8E8E8')
          .fontColor(this.chartType === 0 ? '#FFFFFF' : '#333333')
          .onClick(() => { this.chartType = 0 })

        Text('柱状图')
          .fontSize(15)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor(this.chartType === 1 ? '#007DFF' : '#E8E8E8')
          .fontColor(this.chartType === 1 ? '#FFFFFF' : '#333333')
          .margin({ left: 10 })
          .onClick(() => { this.chartType = 1 })
      }
      .margin({ bottom: 15 })

      // 图表区域
      if (this.categoryStats.length === 0) {
        Column() {
          Text('暂无数据')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 60 })
        }
        .layoutWeight(1)
      } else {
        if (this.chartType === 0) {
          // 饼图
          Column() {
            Canvas(this.pieCtx)
              .width(280)
              .height(280)
              .onReady(() => {
                this.drawPieChart()
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 10, bottom: 10 })
        } else {
          // 柱状图
          Scroll() {
            Row() {
              ForEach(this.categoryStats, (stat: CategoryStat, index: number) => {
                Column() {
                  // 金额标签
                  Text(`¥${stat.amount.toFixed(0)}`)
                    .fontSize(11)
                    .fontColor('#666666')
                    .margin({ bottom: 4 })

                  // 柱子
                  Row()
                    .width(30)
                    .height(this.getBarHeight(stat.amount))
                    .backgroundColor(CategoryColors[stat.category] ?? '#C9C9C9')
                    .borderRadius({ topLeft: 4, topRight: 4 })

                  // 分类名
                  Text(CategoryIcons[stat.category] ?? '📌')
                    .fontSize(16)
                    .margin({ top: 4 })

                  Text(stat.category)
                    .fontSize(11)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .margin({ left: 12, right: 12 })
              }, (stat: CategoryStat) => stat.category)
            }
            .padding({ left: 10, right: 10 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .width('100%')
          .height(220)
          .padding({ top: 10, bottom: 10 })
        }
      }

      // 分类明细列表
      Column() {
        Text('分类明细')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        ForEach(this.categoryStats, (stat: CategoryStat) => {
          Row() {
            Text(CategoryIcons[stat.category] ?? '📌')
              .fontSize(20)
              .margin({ right: 8 })

            Text(stat.category)
              .fontSize(15)
              .width(50)

            // 进度条
            Row()
              .width(`${stat.percentage}%`)
              .height(16)
              .backgroundColor(CategoryColors[stat.category] ?? '#C9C9C9')
              .borderRadius(8)
              .layoutWeight(1)
              .margin({ left: 8, right: 8 })

            Text(`¥${stat.amount.toFixed(2)}`)
              .fontSize(14)
              .fontColor('#333333')
              .width(70)
              .textAlign(TextAlign.End)

            Text(`${stat.percentage.toFixed(1)}%`)
              .fontSize(13)
              .fontColor('#999999')
              .width(50)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        }, (stat: CategoryStat) => stat.category)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 12, topRight: 12 })
      .margin({ top: 10 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
