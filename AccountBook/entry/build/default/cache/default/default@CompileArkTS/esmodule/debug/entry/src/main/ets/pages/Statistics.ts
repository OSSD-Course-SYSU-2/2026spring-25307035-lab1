if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Statistics_Params {
    currentMonth?: string;
    monthExpense?: number;
    monthIncome?: number;
    categoryStats?: CategoryStat[];
}
import { billDataManager } from "@bundle:com.example.accountbook/entry/ets/common/BillDataSource";
import { BillType, EXPENSE_CATEGORIES } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import type { CategoryInfo } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import router from "@ohos:router";
class CategoryStat {
    name: string = '';
    icon: string = '';
    amount: number = 0;
    percent: number = 0;
}
class Statistics extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentMonth = new ObservedPropertySimplePU('', this, "currentMonth");
        this.__monthExpense = new ObservedPropertySimplePU(0, this, "monthExpense");
        this.__monthIncome = new ObservedPropertySimplePU(0, this, "monthIncome");
        this.__categoryStats = new ObservedPropertyObjectPU([], this, "categoryStats");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Statistics_Params) {
        if (params.currentMonth !== undefined) {
            this.currentMonth = params.currentMonth;
        }
        if (params.monthExpense !== undefined) {
            this.monthExpense = params.monthExpense;
        }
        if (params.monthIncome !== undefined) {
            this.monthIncome = params.monthIncome;
        }
        if (params.categoryStats !== undefined) {
            this.categoryStats = params.categoryStats;
        }
    }
    updateStateVars(params: Statistics_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentMonth.purgeDependencyOnElmtId(rmElmtId);
        this.__monthExpense.purgeDependencyOnElmtId(rmElmtId);
        this.__monthIncome.purgeDependencyOnElmtId(rmElmtId);
        this.__categoryStats.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentMonth.aboutToBeDeleted();
        this.__monthExpense.aboutToBeDeleted();
        this.__monthIncome.aboutToBeDeleted();
        this.__categoryStats.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentMonth: ObservedPropertySimplePU<string>;
    get currentMonth() {
        return this.__currentMonth.get();
    }
    set currentMonth(newValue: string) {
        this.__currentMonth.set(newValue);
    }
    private __monthExpense: ObservedPropertySimplePU<number>;
    get monthExpense() {
        return this.__monthExpense.get();
    }
    set monthExpense(newValue: number) {
        this.__monthExpense.set(newValue);
    }
    private __monthIncome: ObservedPropertySimplePU<number>;
    get monthIncome() {
        return this.__monthIncome.get();
    }
    set monthIncome(newValue: number) {
        this.__monthIncome.set(newValue);
    }
    private __categoryStats: ObservedPropertyObjectPU<CategoryStat[]>;
    get categoryStats() {
        return this.__categoryStats.get();
    }
    set categoryStats(newValue: CategoryStat[]) {
        this.__categoryStats.set(newValue);
    }
    aboutToAppear(): void {
        this.updateCurrentMonth();
        this.loadStats();
        billDataManager.addListener(() => {
            this.loadStats();
        });
    }
    aboutToDisappear(): void {
        billDataManager.removeListener(() => { });
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(56);
            Row.backgroundColor('#FFFFFF');
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('< 返回');
            Text.fontSize(16);
            Text.fontColor('#666666');
            Text.padding({ left: 16 });
            Text.onClick(() => {
                router.back();
            });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('统计');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('   ');
            Text.padding({ right: 16 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(44);
            Row.backgroundColor('#FFFFFF');
            Row.alignItems(VerticalAlign.Center);
            Row.margin({ top: 1 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('<');
            Text.fontSize(18);
            Text.fontColor('#333333');
            Text.padding({ left: 15, right: 10 });
            Text.onClick(() => this.prevMonth());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.currentMonth);
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('>');
            Text.fontSize(18);
            Text.fontColor('#333333');
            Text.padding({ left: 10, right: 15 });
            Text.onClick(() => this.nextMonth());
        }, Text);
        Text.pop();
        Row.pop();
        this.OverviewCard.bind(this)();
        this.CategoryList.bind(this)();
        Column.pop();
    }
    OverviewCard(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(20);
            Column.backgroundColor('#FFFFFF');
            Column.margin({ top: 8 });
            Column.borderRadius(8);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('总支出');
            Text.fontSize(13);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${this.monthExpense.toFixed(2)}`);
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#E74C3C');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('总收入');
            Text.fontSize(13);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${this.monthIncome.toFixed(2)}`);
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#27AE60');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(8);
            Row.margin({ top: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width(this.monthExpense + this.monthIncome > 0 ?
                `${this.monthExpense / (this.monthExpense + this.monthIncome) * 100}%` : '50%');
            Row.height('100%');
            Row.backgroundColor('#E74C3C');
            Row.borderRadius({ topLeft: 4, bottomLeft: 4 });
        }, Row);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.layoutWeight(1);
            Row.height('100%');
            Row.backgroundColor('#27AE60');
            Row.borderRadius({ topRight: 4, bottomRight: 4 });
        }, Row);
        Row.pop();
        Row.pop();
        Column.pop();
    }
    CategoryList(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.margin({ top: 8, left: 12, right: 12 });
            Column.borderRadius(8);
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('支出分类排行');
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.width('100%');
            Text.margin({ bottom: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.categoryStats.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无支出数据');
                        Text.fontSize(14);
                        Text.fontColor('#999999');
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                        Text.margin({ top: 40 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const stat = _item;
                            this.CategoryItem.bind(this)(stat);
                        };
                        this.forEachUpdateFunction(elmtId, this.categoryStats, forEachItemGenFunction);
                    }, ForEach);
                    ForEach.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    CategoryItem(stat: CategoryStat, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ top: 10, bottom: 10 });
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(stat.icon);
            Text.fontSize(24);
            Text.margin({ right: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(stat.name);
            Text.fontSize(15);
            Text.fontColor('#333333');
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${stat.amount.toFixed(2)}`);
            Text.fontSize(15);
            Text.fontColor('#333333');
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(4);
            Row.backgroundColor('#F0F0F0');
            Row.borderRadius(2);
            Row.margin({ top: 6 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width(`${stat.percent}%`);
            Row.height('100%');
            Row.backgroundColor('#E74C3C');
            Row.borderRadius(2);
        }, Row);
        Row.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${stat.percent.toFixed(1)}%`);
            Text.fontSize(11);
            Text.fontColor('#999999');
            Text.margin({ top: 2 });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Statistics";
    }
}
registerNamedRoute(() => new Statistics(undefined, {}), "", { bundleName: "com.example.accountbook", moduleName: "entry", pagePath: "pages/Statistics", pageFullPath: "entry/src/main/ets/pages/Statistics", integratedHsp: "false", moduleType: "followWithHap" });
