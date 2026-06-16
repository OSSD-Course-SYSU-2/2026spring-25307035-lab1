import { ExpenseRecord, ExpenseCategory, getAllCategories, CategoryIcons } from '../model/ExpenseRecord'
import { DateUtils } from '../common/DateUtils'

// 添加/编辑消费记录弹窗组件
@CustomDialog
export struct ExpenseDialog {
  controller: CustomDialogController
  // 回调：保存记录
  onSave: (record: ExpenseRecord) => void = () => {}
  // 编辑时传入的已有记录（null 表示新增）
  editRecord: ExpenseRecord | null = null

  // 表单状态
  @State amount: string = ''
  @State category: string = ExpenseCategory.FOOD
  @State date: string = DateUtils.getToday()
  @State note: string = ''
  @State categories: string[] = getAllCategories()

  aboutToAppear() {
    if (this.editRecord) {
      this.amount = this.editRecord.amount.toString()
      this.category = this.editRecord.category
      this.date = this.editRecord.date
      this.note = this.editRecord.note
    }
  }

  build() {
    Column() {
      // 标题
      Text(this.editRecord ? '编辑消费记录' : '添加消费记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      // 金额输入
      Row() {
        Text('金额')
          .fontSize(16)
          .width(60)
        TextInput({ placeholder: '请输入金额', text: this.amount })
          .type(InputType.Number)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.amount = value
          })
      }
      .width('100%')
      .margin({ bottom: 15 })

      // 分类选择
      Row() {
        Text('分类')
          .fontSize(16)
          .width(60)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.categories, (cat: string) => {
            Text(`${CategoryIcons[cat]} ${cat}`)
              .fontSize(14)
              .padding({ left: 8, right: 8, top: 6, bottom: 6 })
              .margin({ right: 6, bottom: 6 })
              .borderRadius(16)
              .backgroundColor(this.category === cat ? '#007DFF' : '#F1F3F5')
              .fontColor(this.category === cat ? '#FFFFFF' : '#333333')
              .onClick(() => {
                this.category = cat
              })
          }, (cat: string) => cat)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 15 })

      // 日期选择
      Row() {
        Text('日期')
          .fontSize(16)
          .width(60)
        DatePicker({
          selected: new Date(this.date)
        })
          .onChange((value: DatePickerResult) => {
            const year = value.year?.toString() ?? new Date().getFullYear().toString()
            const month = ((value.month ?? 0) + 1).toString().padStart(2, '0')
            const day = (value.day ?? 1).toString().padStart(2, '0')
            this.date = `${year}-${month}-${day}`
          })
      }
      .width('100%')
      .margin({ bottom: 15 })

      // 备注输入
      Row() {
        Text('备注')
          .fontSize(16)
          .width(60)
        TextInput({ placeholder: '请输入备注(可选)', text: this.note })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.note = value
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 按钮行
      Row() {
        Button('取消')
          .backgroundColor('#E8E8E8')
          .fontColor('#333333')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })
          .margin({ right: 10 })

        Button('保存')
          .backgroundColor('#007DFF')
          .layoutWeight(1)
          .onClick(() => {
            const amountVal = parseFloat(this.amount)
            if (isNaN(amountVal) || amountVal <= 0) {
              // 金额无效，不做操作
              return
            }
            const record = new ExpenseRecord()
            if (this.editRecord) {
              record.id = this.editRecord.id
            }
            record.amount = amountVal
            record.category = this.category
            record.date = this.date
            record.note = this.note
            record.createTime = this.editRecord ? this.editRecord.createTime : DateUtils.getTimestamp()
            this.onSave(record)
            this.controller.close()
          })
      }
      .width('100%')
    }
    .padding({ left: 24, right: 24, bottom: 24 })
    .width('100%')
  }
}
