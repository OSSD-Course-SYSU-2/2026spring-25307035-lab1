import { ExpenseRecord, CategoryColors, CategoryIcons } from '../model/ExpenseRecord'
import { ExpenseDatabase } from '../model/ExpenseDatabase'
import { DateUtils } from '../common/DateUtils'
import { ExpenseDialog } from '../components/ExpenseDialog'
import router from '@ohos.router'

@Entry
@Component
struct Index {
  // 数据库实例
  private db: ExpenseDatabase = ExpenseDatabase.getInstance()
  // 当前选中的月份
  @State currentMonth: string = DateUtils.getCurrentYearMonth()
  // 当月消费记录列表
  @State expenseList: ExpenseRecord[] = []
  // 当月总支出
  @State monthTotal: number = 0
  // 弹窗控制器
  private dialogController: CustomDialogController | null = null
  // 当前编辑的记录
  @State editingRecord: ExpenseRecord | null = null

  // 添加记录弹窗
  addDialogController: CustomDialogController = new CustomDialogController({
    builder: ExpenseDialog({
      editRecord: null,
      onSave: (record: ExpenseRecord) => {
        this.handleSave(record)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  aboutToAppear() {
    // 初始化数据库并加载数据
    this.db.init(getContext(this))
    this.loadData()
  }

  // 加载当月数据
  async loadData() {
    const records = await this.db.queryByMonth(this.currentMonth)
    this.expenseList = records
    this.calculateTotal()
  }

  // 计算当月总支出
  calculateTotal() {
    let total = 0
    for (const record of this.expenseList) {
      total += record.amount
    }
    this.monthTotal = total
  }

  // 处理保存（新增或编辑）
  async handleSave(record: ExpenseRecord) {
    if (record.id === 0) {
      // 新增
      await this.db.insert(record)
    } else {
      // 编辑
      await this.db.update(record)
    }
    this.loadData()
  }

  // 删除记录
  async handleDelete(id: number) {
    await this.db.delete(id)
    this.loadData()
  }

  // 切换到上个月
  prevMonth() {
    this.currentMonth = DateUtils.getPrevMonth(this.currentMonth)
    this.loadData()
  }

  // 切换到下个月
  nextMonth() {
    this.currentMonth = DateUtils.getNextMonth(this.currentMonth)
    this.loadData()
  }

  // 打开编辑弹窗
  openEditDialog(record: ExpenseRecord) {
    this.editingRecord = record
    const editDialog = new CustomDialogController({
      builder: ExpenseDialog({
        editRecord: this.editingRecord,
        onSave: (r: ExpenseRecord) => {
          this.handleSave(r)
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    })
    editDialog.open()
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('消费日历')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)

        // 跳转统计页面
        Button('统计')
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .height(36)
          .borderRadius(18)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Statistics',
              params: { month: this.currentMonth }
            })
          })
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
        Text('当月支出')
          .fontSize(16)
          .fontColor('#666666')
        Text(`¥ ${this.monthTotal.toFixed(2)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4444')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 10 })

      // 消费记录列表
      if (this.expenseList.length === 0) {
        Column() {
          Text('暂无消费记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
        }
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.expenseList, (item: ExpenseRecord) => {
            ListItem() {
              this.ExpenseItem(item)
            }
            .swipeAction({ end: this.deleteButton(item.id) })
          }, (item: ExpenseRecord) => item.id.toString())
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .divider({ strokeWidth: 1, color: '#F1F3F5' })
      }

      // 底部添加按钮
      Button('+ 添加消费')
        .width('90%')
        .height(48)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .fontSize(18)
        .borderRadius(24)
        .margin({ top: 10, bottom: 20 })
        .onClick(() => {
          this.addDialogController.open()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 消费记录项
  @Builder
  ExpenseItem(record: ExpenseRecord) {
    Row() {
      // 分类图标
      Text(CategoryIcons[record.category] ?? '📌')
        .fontSize(28)
        .margin({ right: 12 })

      // 分类和备注
      Column() {
        Text(record.category)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        if (record.note) {
          Text(record.note)
            .fontSize(13)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 日期
      Text(record.date.substring(5))
        .fontSize(13)
        .fontColor('#999999')
        .margin({ right: 12 })

      // 金额
      Text(`-¥${record.amount.toFixed(2)}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF4444')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ top: 6, bottom: 6 })
    .onClick(() => {
      this.openEditDialog(record)
    })
  }

  // 左滑删除按钮
  @Builder
  deleteButton(id: number) {
    Button('删除')
      .backgroundColor('#FF4444')
      .fontColor('#FFFFFF')
      .width(70)
      .height('100%')
      .borderRadius(0)
      .onClick(() => {
        this.handleDelete(id)
      })
  }
}
