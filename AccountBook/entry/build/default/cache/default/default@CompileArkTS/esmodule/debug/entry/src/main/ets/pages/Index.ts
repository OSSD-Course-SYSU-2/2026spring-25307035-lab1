if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
    bills?: BillInfo[];
    currentMonth?: string;
    monthExpense?: number;
    monthIncome?: number;
    currentIndex?: number;
    currentBreakpoint?: BreakpointType;
}
import { billDataManager } from "@bundle:com.example.accountbook/entry/ets/common/BillDataSource";
import { BillType } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import type { BillInfo } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import { breakpointSystem, BreakpointType } from "@bundle:com.example.accountbook/entry/ets/common/BreakpointSystem";
import router from "@ohos:router";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__bills = new ObservedPropertyObjectPU([], this, "bills");
        this.__currentMonth = new ObservedPropertySimplePU('', this, "currentMonth");
        this.__monthExpense = new ObservedPropertySimplePU(0, this, "monthExpense");
        this.__monthIncome = new ObservedPropertySimplePU(0, this, "monthIncome");
        this.__currentIndex = new ObservedPropertySimplePU(0, this, "currentIndex");
        this.__currentBreakpoint = new ObservedPropertySimplePU(BreakpointType.SM, this, "currentBreakpoint");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.bills !== undefined) {
            this.bills = params.bills;
        }
        if (params.currentMonth !== undefined) {
            this.currentMonth = params.currentMonth;
        }
        if (params.monthExpense !== undefined) {
            this.monthExpense = params.monthExpense;
        }
        if (params.monthIncome !== undefined) {
            this.monthIncome = params.monthIncome;
        }
        if (params.currentIndex !== undefined) {
            this.currentIndex = params.currentIndex;
        }
        if (params.currentBreakpoint !== undefined) {
            this.currentBreakpoint = params.currentBreakpoint;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__bills.purgeDependencyOnElmtId(rmElmtId);
        this.__currentMonth.purgeDependencyOnElmtId(rmElmtId);
        this.__monthExpense.purgeDependencyOnElmtId(rmElmtId);
        this.__monthIncome.purgeDependencyOnElmtId(rmElmtId);
        this.__currentIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__currentBreakpoint.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__bills.aboutToBeDeleted();
        this.__currentMonth.aboutToBeDeleted();
        this.__monthExpense.aboutToBeDeleted();
        this.__monthIncome.aboutToBeDeleted();
        this.__currentIndex.aboutToBeDeleted();
        this.__currentBreakpoint.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __bills: ObservedPropertyObjectPU<BillInfo[]>;
    get bills() {
        return this.__bills.get();
    }
    set bills(newValue: BillInfo[]) {
        this.__bills.set(newValue);
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
    private __currentIndex: ObservedPropertySimplePU<number>;
    get currentIndex() {
        return this.__currentIndex.get();
    }
    set currentIndex(newValue: number) {
        this.__currentIndex.set(newValue);
    }
    private __currentBreakpoint: ObservedPropertySimplePU<BreakpointType>;
    get currentBreakpoint() {
        return this.__currentBreakpoint.get();
    }
    set currentBreakpoint(newValue: BreakpointType) {
        this.__currentBreakpoint.set(newValue);
    }
    aboutToAppear(): void {
        this.updateCurrentMonth();
        this.loadBills();
        billDataManager.addListener(() => {
            this.loadBills();
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height('100%');
            Row.backgroundColor('#F5F5F5');
            Row.onAreaChange((oldValue: Area, newValue: Area) => {
                const width = Number(newValue.width);
                this.currentBreakpoint = breakpointSystem.updateBreakpoint(width);
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.currentBreakpoint === BreakpointType.LG) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.SideNav.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.height('100%');
        }, Column);
        this.MonthHeader.bind(this)();
        this.MonthSummary.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.bills.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.EmptyView.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.BillList.bind(this)();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.currentBreakpoint !== BreakpointType.LG) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.BottomNav.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
        Row.pop();
    }
    SideNav(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(200);
            Column.height('100%');
            Column.backgroundColor('#FFFFFF');
            Column.shadow({ radius: 4, color: '#1F000000', offsetX: 2 });
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('记账本');
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.margin({ top: 40, bottom: 30 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🏠 账单');
            Text.fontSize(16);
            Text.fontColor(this.currentIndex === 0 ? '#E74C3C' : '#666666');
            Text.fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Normal);
            Text.padding(12);
            Text.borderRadius(8);
            Text.backgroundColor(this.currentIndex === 0 ? '#FFF0F0' : Color.Transparent);
            Text.width('80%');
            Text.textAlign(TextAlign.Center);
            Text.onClick(() => {
                this.currentIndex = 0;
            });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ top: 8 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📊 统计');
            Text.fontSize(16);
            Text.fontColor(this.currentIndex === 1 ? '#E74C3C' : '#666666');
            Text.fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Normal);
            Text.padding(12);
            Text.borderRadius(8);
            Text.backgroundColor(this.currentIndex === 1 ? '#FFF0F0' : Color.Transparent);
            Text.width('80%');
            Text.textAlign(TextAlign.Center);
            Text.onClick(() => {
                router.pushUrl({ url: 'pages/Statistics' });
            });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ bottom: 40 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('+ 记一笔');
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
            Text.padding({ left: 20, right: 20, top: 10, bottom: 10 });
            Text.borderRadius(20);
            Text.backgroundColor('#E74C3C');
            Text.onClick(() => {
                router.pushUrl({ url: 'pages/AddBill' });
            });
        }, Text);
        Text.pop();
        Column.pop();
        Column.pop();
    }
    MonthHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(56);
            Row.backgroundColor('#FFFFFF');
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('<');
            Text.fontSize(20);
            Text.fontColor('#333333');
            Text.padding({ left: 15, right: 10 });
            Text.onClick(() => this.prevMonth());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.currentMonth);
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('>');
            Text.fontSize(20);
            Text.fontColor('#333333');
            Text.padding({ left: 10, right: 15 });
            Text.onClick(() => this.nextMonth());
        }, Text);
        Text.pop();
        Row.pop();
    }
    MonthSummary(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.margin({ top: 1 });
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
            Text.create('支出');
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${this.monthExpense.toFixed(2)}`);
            Text.fontSize(18);
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
            Text.create('收入');
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${this.monthIncome.toFixed(2)}`);
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#27AE60');
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
            Text.create('结余');
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`¥${(this.monthIncome - this.monthExpense).toFixed(2)}`);
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
    }
    EmptyView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.layoutWeight(1);
            Column.justifyContent(FlexAlign.Start);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📋');
            Text.fontSize(48);
            Text.margin({ top: 80 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('暂无账单记录');
            Text.fontSize(16);
            Text.fontColor('#999999');
            Text.margin({ top: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('点击下方 + 开始记账');
            Text.fontSize(14);
            Text.fontColor('#CCCCCC');
            Text.margin({ top: 8 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    BillList(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.layoutWeight(1);
            Scroll.width('100%');
            Scroll.margin({ top: 8 });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.constraintSize({ maxWidth: breakpointSystem.getContentMaxWidth() });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                this.DateGroup.bind(this)(item[0], item[1]);
            };
            this.forEachUpdateFunction(elmtId, Array.from(this.getGroupedBills().entries()), forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Column.pop();
        Scroll.pop();
    }
    DateGroup(date: string, bills: BillInfo[], parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(8);
            Column.margin({ left: 12, right: 12, top: 6 });
            Column.clip(true);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 16, right: 16, top: 8, bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(date);
            Text.fontSize(14);
            Text.fontColor('#666666');
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`支出 ¥${this.getDayTotal(bills, BillType.EXPENSE).toFixed(2)}`);
            Text.fontSize(12);
            Text.fontColor('#E74C3C');
            Text.margin({ right: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`收入 ¥${this.getDayTotal(bills, BillType.INCOME).toFixed(2)}`);
            Text.fontSize(12);
            Text.fontColor('#27AE60');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const bill = _item;
                this.BillItem.bind(this)(bill);
            };
            this.forEachUpdateFunction(elmtId, bills, forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Column.pop();
    }
    BillItem(bill: BillInfo, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 16, right: 16, top: 10, bottom: 10 });
            Row.onClick(() => {
                billDataManager.deleteBill(bill.id);
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(bill.categoryIcon);
            Text.fontSize(28);
            Text.margin({ right: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.alignItems(HorizontalAlign.Start);
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(bill.category);
            Text.fontSize(15);
            Text.fontColor('#333333');
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (bill.note) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(bill.note);
                        Text.fontSize(12);
                        Text.fontColor('#999999');
                        Text.margin({ top: 2 });
                        Text.maxLines(1);
                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${bill.type === BillType.EXPENSE ? '-' : '+'}¥${bill.amount.toFixed(2)}`);
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(bill.type === BillType.EXPENSE ? '#E74C3C' : '#27AE60');
        }, Text);
        Text.pop();
        Row.pop();
    }
    BottomNav(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(60);
            Row.backgroundColor('#FFFFFF');
            Row.shadow({ radius: 2, color: '#1F000000', offsetY: -1 });
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.padding({ top: 6, bottom: 6 });
            Column.onClick(() => {
                this.currentIndex = 0;
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🏠');
            Text.fontSize(22);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('账单');
            Text.fontSize(12);
            Text.fontColor(this.currentIndex === 0 ? '#E74C3C' : '#999999');
            Text.margin({ top: 2 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(48);
            Column.height(48);
            Column.borderRadius(24);
            Column.backgroundColor('#E74C3C');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ top: -20 });
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/AddBill' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('+');
            Text.fontSize(28);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FFFFFF');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.padding({ top: 6, bottom: 6 });
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/Statistics' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📊');
            Text.fontSize(22);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('统计');
            Text.fontSize(12);
            Text.fontColor(this.currentIndex === 1 ? '#E74C3C' : '#999999');
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
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.accountbook", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
