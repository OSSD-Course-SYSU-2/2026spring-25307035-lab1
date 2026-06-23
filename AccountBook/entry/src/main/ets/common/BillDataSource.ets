import { BillInfo, BillType } from '../model/BillModel';

// 新增账单参数接口（不含id和createTime）
export interface AddBillParam {
  type: BillType;
  category: string;
  categoryIcon: string;
  amount: number;
  note: string;
  date: string;
}

// 账单数据管理单例
class BillDataManager {
  private bills: BillInfo[] = [];
  private listeners: (() => void)[] = [];
  private nextId: number = 1;

  // 获取所有账单
  getAllBills(): BillInfo[] {
    return this.bills.sort((a, b) => b.createTime - a.createTime);
  }

  // 按月份获取账单
  getBillsByMonth(yearMonth: string): BillInfo[] {
    return this.bills.filter(bill => bill.date.startsWith(yearMonth))
      .sort((a, b) => b.createTime - a.createTime);
  }

  // 添加账单
  addBill(param: AddBillParam): BillInfo {
    const newBill: BillInfo = {
      id: this.nextId++,
      type: param.type,
      category: param.category,
      categoryIcon: param.categoryIcon,
      amount: param.amount,
      note: param.note,
      date: param.date,
      createTime: Date.now()
    };
    this.bills.push(newBill);
    this.notify();
    return newBill;
  }

  // 删除账单
  deleteBill(id: number): boolean {
    const index = this.bills.findIndex(bill => bill.id === id);
    if (index !== -1) {
      this.bills.splice(index, 1);
      this.notify();
      return true;
    }
    return false;
  }

  // 计算总支出
  getTotalExpense(bills?: BillInfo[]): number {
    const list: BillInfo[] = bills !== undefined ? bills : this.bills;
    return list
      .filter(bill => bill.type === BillType.EXPENSE)
      .reduce((sum, bill) => sum + bill.amount, 0);
  }

  // 计算总收入
  getTotalIncome(bills?: BillInfo[]): number {
    const list: BillInfo[] = bills !== undefined ? bills : this.bills;
    return list
      .filter(bill => bill.type === BillType.INCOME)
      .reduce((sum, bill) => sum + bill.amount, 0);
  }

  // 注册监听
  addListener(listener: () => void): void {
    this.listeners.push(listener);
  }

  // 移除监听
  removeListener(listener: () => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  // 通知更新
  private notify(): void {
    this.listeners.forEach(listener => listener());
  }
}

// 导出单例
export const billDataManager = new BillDataManager();
