import { BillType, EXPENSE_CATEGORIES, INCOME_CATEGORIES, CategoryInfo } from '../model/BillModel';
import { AddBillParam, billDataManager } from '../common/BillDataSource';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct AddBill {
  @State currentType: BillType = BillType.EXPENSE;
  @State selectedCategory: CategoryInfo = EXPENSE_CATEGORIES[0];
  @State amount: string = '';
  @State note: string = '';
  @State date: string = '';

  aboutToAppear(): void {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    this.date = `${year}-${month}-${day}`;
  }

  getCategories(): CategoryInfo[] {
    return this.currentType === BillType.EXPENSE ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
  }

  switchType(type: BillType): void {
    this.currentType = type;
    const categories = this.getCategories();
    this.selectedCategory = categories[0];
  }

  saveBill(): void {
    const amountNum = parseFloat(this.amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      return;
    }

    const param: AddBillParam = {
      type: this.currentType,
      category: this.selectedCategory.name,
      categoryIcon: this.selectedCategory.icon,
      amount: amountNum,
      note: this.note,
      date: this.date
    };
    billDataManager.addBill(param);

    router.back();
  }

  build() {
    Column() {
      this.TopBar();
      this.TypeSwitch();
      this.AmountInput();
      this.CategoryGrid();
      this.ExtraInfo();
      this.SaveButton();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder TopBar() {
    Row() {
      Text('取消')
        .fontSize(16)
        .fontColor('#666666')
        .padding({ left: 16 })
        .onClick(() => {
          router.back();
        })

      Text('记一笔')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('   ')
        .fontSize(16)
        .padding({ right: 16 })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  @Builder TypeSwitch() {
    Row() {
      Text('支出')
        .fontSize(16)
        .fontWeight(this.currentType === BillType.EXPENSE ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentType === BillType.EXPENSE ? '#FFFFFF' : '#E74C3C')
        .backgroundColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#FFFFFF')
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .onClick(() => this.switchType(BillType.EXPENSE))

      Text('收入')
        .fontSize(16)
        .fontWeight(this.currentType === BillType.INCOME ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentType === BillType.INCOME ? '#FFFFFF' : '#27AE60')
        .backgroundColor(this.currentType === BillType.INCOME ? '#27AE60' : '#FFFFFF')
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .onClick(() => this.switchType(BillType.INCOME))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 1 })
  }

  @Builder AmountInput() {
    Row() {
      Text('¥')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#27AE60')
        .margin({ right: 8 })

      TextInput({ placeholder: '0.00', text: this.amount })
        .type(InputType.Number)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.amount = value;
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder CategoryGrid() {
    Column() {
      Text('选择分类')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.getCategories(), (category: CategoryInfo) => {
          Column() {
            Text(category.icon)
              .fontSize(28)
            Text(category.name)
              .fontSize(12)
              .fontColor(this.selectedCategory.name === category.name ? '#E74C3C' : '#666666')
              .margin({ top: 4 })
          }
          .width('20%')
          .padding({ top: 8, bottom: 8 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(8)
          .backgroundColor(this.selectedCategory.name === category.name ? '#FFF0F0' : Color.Transparent)
          .border({
            width: this.selectedCategory.name === category.name ? 1 : 0,
            color: '#E74C3C',
            radius: 8
          })
          .onClick(() => {
            this.selectedCategory = category;
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
  }

  @Builder ExtraInfo() {
    Column() {
      Row() {
        Text('日期')
          .fontSize(15)
          .fontColor('#666666')
          .width(50)

        TextInput({ text: this.date })
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.date = value;
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .borderWidth({ bottom: 0.5 })
      .borderColor('#EEEEEE')

      Row() {
        Text('备注')
          .fontSize(15)
          .fontColor('#666666')
          .width(50)

        TextInput({ placeholder: '添加备注', text: this.note })
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.note = value;
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
  }

  @Builder SaveButton() {
    Button('保存')
      .width('90%')
      .height(48)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#27AE60')
      .borderRadius(24)
      .margin({ top: 24 })
      .onClick(() => this.saveBill())
  }
}
