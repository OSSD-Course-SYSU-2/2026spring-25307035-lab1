import { billDataManager } from '../common/BillDataSource';
import { BillInfo, BillType, EXPENSE_CATEGORIES, CategoryInfo } from '../model/BillModel';
import { router } from '@kit.ArkUI';

class CategoryStat {
  name: string = '';
  icon: string = '';
  amount: number = 0;
  percent: number = 0;
}

@Entry
@Component
struct Statistics {
  @State currentMonth: string = '';
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;
  @State categoryStats: CategoryStat[] = [];

  aboutToAppear(): void {
    this.updateCurrentMonth();
    this.loadStats();
    billDataManager.addListener(() => {
      this.loadStats();
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

  loadStats(): void {
    const bills = billDataManager.getBillsByMonth(this.currentMonth);
    this.monthExpense = billDataManager.getTotalExpense(bills);
    this.monthIncome = billDataManager.getTotalIncome(bills);

    const statsMap = new Map<string, number>();
    bills.filter(b => b.type === BillType.EXPENSE).forEach(bill => {
      const current = statsMap.get(bill.category) || 0;
      statsMap.set(bill.category, current + bill.amount);
    });

    const stats: CategoryStat[] = [];
    statsMap.forEach((amount: number, name: string) => {
      const category: CategoryInfo | undefined = EXPENSE_CATEGORIES.find(c => c.name === name);
      const stat = new CategoryStat();
      stat.name = name;
      stat.icon = category !== undefined ? category.icon : '📝';
      stat.amount = amount;
      stat.percent = this.monthExpense > 0 ? (amount / this.monthExpense * 100) : 0;
      stats.push(stat);
    });

    stats.sort((a, b) => b.amount - a.amount);
    this.categoryStats = stats;
  }

  prevMonth(): void {
    const parts: string[] = this.currentMonth.split('-');
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const date = new Date(year, month - 2, 1);
    this.currentMonth = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
    this.loadStats();
  }

  nextMonth(): void {
    const parts: string[] = this.currentMonth.split('-');
    const year: number = Number(parts[0]);
    const month: number = Number(parts[1]);
    const date = new Date(year, month, 1);
    this.currentMonth = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
    this.loadStats();
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor('#666666')
          .padding({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text('统计')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('   ')
          .padding({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('<')
          .fontSize(18)
          .fontColor('#333333')
          .padding({ left: 15, right: 10 })
          .onClick(() => this.prevMonth())

        Text(this.currentMonth)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('>')
          .fontSize(18)
          .fontColor('#333333')
          .padding({ left: 10, right: 15 })
          .onClick(() => this.nextMonth())
      }
      .width('100%')
      .height(44)
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 1 })

      this.OverviewCard();
      this.CategoryList();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder OverviewCard() {
    Column() {
      Row() {
        Column() {
          Text('总支出')
            .fontSize(13)
            .fontColor('#999999')
          Text(`¥${this.monthExpense.toFixed(2)}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E74C3C')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('总收入')
            .fontSize(13)
            .fontColor('#999999')
          Text(`¥${this.monthIncome.toFixed(2)}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#27AE60')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      Row() {
        Row()
          .width(this.monthExpense + this.monthIncome > 0 ?
            `${this.monthExpense / (this.monthExpense + this.monthIncome) * 100}%` : '50%')
          .height('100%')
          .backgroundColor('#E74C3C')
          .borderRadius({ topLeft: 4, bottomLeft: 4 })
        Row()
          .layoutWeight(1)
          .height('100%')
          .backgroundColor('#27AE60')
          .borderRadius({ topRight: 4, bottomRight: 4 })
      }
      .width('100%')
      .height(8)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
    .borderRadius(8)
  }

  @Builder CategoryList() {
    Column() {
      Text('支出分类排行')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      if (this.categoryStats.length === 0) {
        Text('暂无支出数据')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 40 })
      } else {
        ForEach(this.categoryStats, (stat: CategoryStat) => {
          this.CategoryItem(stat);
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8, left: 12, right: 12 })
    .borderRadius(8)
    .layoutWeight(1)
  }

  @Builder CategoryItem(stat: CategoryStat) {
    Row() {
      Text(stat.icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(stat.name)
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          Blank()

          Text(`¥${stat.amount.toFixed(2)}`)
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')

        Row() {
          Row()
            .width(`${stat.percent}%`)
            .height('100%')
            .backgroundColor('#E74C3C')
            .borderRadius(2)
        }
        .width('100%')
        .height(4)
        .backgroundColor('#F0F0F0')
        .borderRadius(2)
        .margin({ top: 6 })

        Text(`${stat.percent.toFixed(1)}%`)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }
}
