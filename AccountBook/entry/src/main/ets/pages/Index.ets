import { billDataManager } from '../common/BillDataSource';
import { BillInfo, BillType } from '../model/BillModel';
import { breakpointSystem, BreakpointType } from '../common/BreakpointSystem';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State bills: BillInfo[] = [];
  @State currentMonth: string = '';
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;
  @State currentIndex: number = 0;
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;

  aboutToAppear(): void {
    this.updateCurrentMonth();
    this.loadBills();
    billDataManager.addListener(() => {
      this.loadBills();
    });
  }

  aboutToDisappear(): void {
    billDataManager.removeListener(() => {});
  }

  updateCurrentMonth(): void {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    this.currentMonth = `${year}-${month}`;
  }

  loadBills(): void {
    this.bills = billDataManager.getBillsByMonth(this.currentMonth);
    this.monthExpense = billDataManager.getTotalExpense(this.bills);
    this.monthIncome = billDataManager.getTotalIncome(this.bills);
  }

  prevMonth(): void {
    const parts: string[] = this.currentMonth.split('-');
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const date = new Date(year, month - 2, 1);
    this.currentMonth = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
    this.loadBills();
  }

  nextMonth(): void {
    const parts: string[] = this.currentMonth.split('-');
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const date = new Date(year, month, 1);
    this.currentMonth = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
    this.loadBills();
  }

  getGroupedBills(): Map<string, BillInfo[]> {
    const grouped = new Map<string, BillInfo[]>();
    this.bills.forEach(bill => {
      const list = grouped.get(bill.date) || [];
      list.push(bill);
      grouped.set(bill.date, list);
    });
    return grouped;
  }

  getDayTotal(bills: BillInfo[], type: BillType): number {
    return bills.filter(b => b.type === type).reduce((sum, b) => sum + b.amount, 0);
  }

  build() {
    Row() {
      if (this.currentBreakpoint === BreakpointType.LG) {
        this.SideNav();
      }

      Column() {
        this.MonthHeader();
        this.MonthSummary();

        if (this.bills.length === 0) {
          this.EmptyView();
        } else {
          this.BillList();
        }

        if (this.currentBreakpoint !== BreakpointType.LG) {
          this.BottomNav();
        }
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      const width = Number(newValue.width);
      this.currentBreakpoint = breakpointSystem.updateBreakpoint(width);
    })
  }

  @Builder SideNav() {
    Column() {
      Text('记账本')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 40, bottom: 30 })

      Column() {
        Text('🏠 账单')
          .fontSize(16)
          .fontColor(this.currentIndex === 0 ? '#E74C3C' : '#666666')
          .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Normal)
          .padding(12)
          .borderRadius(8)
          .backgroundColor(this.currentIndex === 0 ? '#FFF0F0' : Color.Transparent)
          .width('80%')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentIndex = 0;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text('📊 统计')
          .fontSize(16)
          .fontColor(this.currentIndex === 1 ? '#E74C3C' : '#666666')
          .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Normal)
          .padding(12)
          .borderRadius(8)
          .backgroundColor(this.currentIndex === 1 ? '#FFF0F0' : Color.Transparent)
          .width('80%')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Statistics' });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 8 })

      Blank()

      Column() {
        Text('+ 记一笔')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .borderRadius(20)
          .backgroundColor('#E74C3C')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddBill' });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })
    }
    .width(200)
    .height('100%')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#1F000000', offsetX: 2 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder MonthHeader() {
    Row() {
      Text('<')
        .fontSize(20)
        .fontColor('#333333')
        .padding({ left: 15, right: 10 })
        .onClick(() => this.prevMonth())

      Text(this.currentMonth)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('>')
        .fontSize(20)
        .fontColor('#333333')
        .padding({ left: 10, right: 15 })
        .onClick(() => this.nextMonth())
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .alignItems(VerticalAlign.Center)
  }

  @Builder MonthSummary() {
    Column() {
      Row() {
        Column() {
          Text('支出')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${this.monthExpense.toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E74C3C')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('收入')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${this.monthIncome.toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#27AE60')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('结余')
            .fontSize(12)
            .fontColor('#999999')
          Text(`¥${(this.monthIncome - this.monthExpense).toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 1 })
  }

  @Builder EmptyView() {
    Column() {
      Text('📋')
        .fontSize(48)
        .margin({ top: 80 })
      Text('暂无账单记录')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
      Text('点击下方 + 开始记账')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder BillList() {
    Scroll() {
      Column() {
        ForEach(Array.from(this.getGroupedBills().entries()), (item: [string, BillInfo[]]) => {
          this.DateGroup(item[0], item[1]);
        })
      }
      .width('100%')
      .constraintSize({ maxWidth: breakpointSystem.getContentMaxWidth() })
    }
    .layoutWeight(1)
    .width('100%')
    .margin({ top: 8 })
  }

  @Builder DateGroup(date: string, bills: BillInfo[]) {
    Column() {
      Row() {
        Text(date)
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)

        Blank()

        Text(`支出 ¥${this.getDayTotal(bills, BillType.EXPENSE).toFixed(2)}`)
          .fontSize(12)
          .fontColor('#E74C3C')
          .margin({ right: 12 })

        Text(`收入 ¥${this.getDayTotal(bills, BillType.INCOME).toFixed(2)}`)
          .fontSize(12)
          .fontColor('#27AE60')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      ForEach(bills, (bill: BillInfo) => {
        this.BillItem(bill);
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ left: 12, right: 12, top: 6 })
    .clip(true)
  }

  @Builder BillItem(bill: BillInfo) {
    Row() {
      Text(bill.categoryIcon)
        .fontSize(28)
        .margin({ right: 12 })

      Column() {
        Text(bill.category)
          .fontSize(15)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        if (bill.note) {
          Text(bill.note)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(`${bill.type === BillType.EXPENSE ? '-' : '+'}¥${bill.amount.toFixed(2)}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(bill.type === BillType.EXPENSE ? '#E74C3C' : '#27AE60')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .onClick(() => {
      billDataManager.deleteBill(bill.id);
    })
  }

  @Builder BottomNav() {
    Row() {
      Column() {
        Text('🏠')
          .fontSize(22)
        Text('账单')
          .fontSize(12)
          .fontColor(this.currentIndex === 0 ? '#E74C3C' : '#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 6, bottom: 6 })
      .onClick(() => {
        this.currentIndex = 0;
      })

      Column() {
        Text('+')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor('#E74C3C')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: -20 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/AddBill' });
      })

      Column() {
        Text('📊')
          .fontSize(22)
        Text('统计')
          .fontSize(12)
          .fontColor(this.currentIndex === 1 ? '#E74C3C' : '#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 6, bottom: 6 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/Statistics' });
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1F000000', offsetY: -1 })
    .alignItems(VerticalAlign.Center)
  }
}
