if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface AddBill_Params {
    currentType?: BillType;
    selectedCategory?: CategoryInfo;
    amount?: string;
    note?: string;
    date?: string;
}
import { BillType, EXPENSE_CATEGORIES, INCOME_CATEGORIES } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import type { CategoryInfo } from "@bundle:com.example.accountbook/entry/ets/model/BillModel";
import { billDataManager } from "@bundle:com.example.accountbook/entry/ets/common/BillDataSource";
import type { AddBillParam } from "@bundle:com.example.accountbook/entry/ets/common/BillDataSource";
import router from "@ohos:router";
class AddBill extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentType = new ObservedPropertySimplePU(BillType.EXPENSE, this, "currentType");
        this.__selectedCategory = new ObservedPropertyObjectPU(EXPENSE_CATEGORIES[0], this, "selectedCategory");
        this.__amount = new ObservedPropertySimplePU('', this, "amount");
        this.__note = new ObservedPropertySimplePU('', this, "note");
        this.__date = new ObservedPropertySimplePU('', this, "date");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: AddBill_Params) {
        if (params.currentType !== undefined) {
            this.currentType = params.currentType;
        }
        if (params.selectedCategory !== undefined) {
            this.selectedCategory = params.selectedCategory;
        }
        if (params.amount !== undefined) {
            this.amount = params.amount;
        }
        if (params.note !== undefined) {
            this.note = params.note;
        }
        if (params.date !== undefined) {
            this.date = params.date;
        }
    }
    updateStateVars(params: AddBill_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentType.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedCategory.purgeDependencyOnElmtId(rmElmtId);
        this.__amount.purgeDependencyOnElmtId(rmElmtId);
        this.__note.purgeDependencyOnElmtId(rmElmtId);
        this.__date.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentType.aboutToBeDeleted();
        this.__selectedCategory.aboutToBeDeleted();
        this.__amount.aboutToBeDeleted();
        this.__note.aboutToBeDeleted();
        this.__date.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentType: ObservedPropertySimplePU<BillType>;
    get currentType() {
        return this.__currentType.get();
    }
    set currentType(newValue: BillType) {
        this.__currentType.set(newValue);
    }
    private __selectedCategory: ObservedPropertyObjectPU<CategoryInfo>;
    get selectedCategory() {
        return this.__selectedCategory.get();
    }
    set selectedCategory(newValue: CategoryInfo) {
        this.__selectedCategory.set(newValue);
    }
    private __amount: ObservedPropertySimplePU<string>;
    get amount() {
        return this.__amount.get();
    }
    set amount(newValue: string) {
        this.__amount.set(newValue);
    }
    private __note: ObservedPropertySimplePU<string>;
    get note() {
        return this.__note.get();
    }
    set note(newValue: string) {
        this.__note.set(newValue);
    }
    private __date: ObservedPropertySimplePU<string>;
    get date() {
        return this.__date.get();
    }
    set date(newValue: string) {
        this.__date.set(newValue);
    }
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.TopBar.bind(this)();
        this.TypeSwitch.bind(this)();
        this.AmountInput.bind(this)();
        this.CategoryGrid.bind(this)();
        this.ExtraInfo.bind(this)();
        this.SaveButton.bind(this)();
        Column.pop();
    }
    TopBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(56);
            Row.backgroundColor('#FFFFFF');
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('取消');
            Text.fontSize(16);
            Text.fontColor('#666666');
            Text.padding({ left: 16 });
            Text.onClick(() => {
                router.back();
            });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('记一笔');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('   ');
            Text.fontSize(16);
            Text.padding({ right: 16 });
        }, Text);
        Text.pop();
        Row.pop();
    }
    TypeSwitch(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.Center);
            Row.padding({ top: 16, bottom: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.margin({ top: 1 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('支出');
            Text.fontSize(16);
            Text.fontWeight(this.currentType === BillType.EXPENSE ? FontWeight.Bold : FontWeight.Normal);
            Text.fontColor(this.currentType === BillType.EXPENSE ? '#FFFFFF' : '#E74C3C');
            Text.backgroundColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#FFFFFF');
            Text.borderRadius(20);
            Text.padding({ left: 24, right: 24, top: 8, bottom: 8 });
            Text.onClick(() => this.switchType(BillType.EXPENSE));
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('收入');
            Text.fontSize(16);
            Text.fontWeight(this.currentType === BillType.INCOME ? FontWeight.Bold : FontWeight.Normal);
            Text.fontColor(this.currentType === BillType.INCOME ? '#FFFFFF' : '#27AE60');
            Text.backgroundColor(this.currentType === BillType.INCOME ? '#27AE60' : '#FFFFFF');
            Text.borderRadius(20);
            Text.padding({ left: 24, right: 24, top: 8, bottom: 8 });
            Text.onClick(() => this.switchType(BillType.INCOME));
        }, Text);
        Text.pop();
        Row.pop();
    }
    AmountInput(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 20, right: 20, top: 16, bottom: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.margin({ top: 8 });
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('¥');
            Text.fontSize(32);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#27AE60');
            Text.margin({ right: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '0.00', text: this.amount });
            TextInput.type(InputType.Number);
            TextInput.fontSize(32);
            TextInput.fontWeight(FontWeight.Bold);
            TextInput.fontColor('#333333');
            TextInput.layoutWeight(1);
            TextInput.backgroundColor(Color.Transparent);
            TextInput.onChange((value: string) => {
                this.amount = value;
            });
        }, TextInput);
        Row.pop();
    }
    CategoryGrid(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.margin({ top: 8 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择分类');
            Text.fontSize(14);
            Text.fontColor('#999999');
            Text.margin({ bottom: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Flex.create({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start });
            Flex.width('100%');
        }, Flex);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const category = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('20%');
                    Column.padding({ top: 8, bottom: 8 });
                    Column.justifyContent(FlexAlign.Center);
                    Column.alignItems(HorizontalAlign.Center);
                    Column.borderRadius(8);
                    Column.backgroundColor(this.selectedCategory.name === category.name ? '#FFF0F0' : Color.Transparent);
                    Column.border({
                        width: this.selectedCategory.name === category.name ? 1 : 0,
                        color: '#E74C3C',
                        radius: 8
                    });
                    Column.onClick(() => {
                        this.selectedCategory = category;
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(category.icon);
                    Text.fontSize(28);
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(category.name);
                    Text.fontSize(12);
                    Text.fontColor(this.selectedCategory.name === category.name ? '#E74C3C' : '#666666');
                    Text.margin({ top: 4 });
                }, Text);
                Text.pop();
                Column.pop();
            };
            this.forEachUpdateFunction(elmtId, this.getCategories(), forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        Flex.pop();
        Column.pop();
    }
    ExtraInfo(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding({ left: 16, right: 16 });
            Column.backgroundColor('#FFFFFF');
            Column.margin({ top: 8 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ top: 12, bottom: 12 });
            Row.borderWidth({ bottom: 0.5 });
            Row.borderColor('#EEEEEE');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('日期');
            Text.fontSize(15);
            Text.fontColor('#666666');
            Text.width(50);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ text: this.date });
            TextInput.fontSize(15);
            TextInput.fontColor('#333333');
            TextInput.layoutWeight(1);
            TextInput.backgroundColor(Color.Transparent);
            TextInput.onChange((value: string) => {
                this.date = value;
            });
        }, TextInput);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ top: 12, bottom: 12 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('备注');
            Text.fontSize(15);
            Text.fontColor('#666666');
            Text.width(50);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '添加备注', text: this.note });
            TextInput.fontSize(15);
            TextInput.fontColor('#333333');
            TextInput.layoutWeight(1);
            TextInput.backgroundColor(Color.Transparent);
            TextInput.onChange((value: string) => {
                this.note = value;
            });
        }, TextInput);
        Row.pop();
        Column.pop();
    }
    SaveButton(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('保存');
            Button.width('90%');
            Button.height(48);
            Button.fontSize(18);
            Button.fontWeight(FontWeight.Bold);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor(this.currentType === BillType.EXPENSE ? '#E74C3C' : '#27AE60');
            Button.borderRadius(24);
            Button.margin({ top: 24 });
            Button.onClick(() => this.saveBill());
        }, Button);
        Button.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "AddBill";
    }
}
registerNamedRoute(() => new AddBill(undefined, {}), "", { bundleName: "com.example.accountbook", moduleName: "entry", pagePath: "pages/AddBill", pageFullPath: "entry/src/main/ets/pages/AddBill", integratedHsp: "false", moduleType: "followWithHap" });
